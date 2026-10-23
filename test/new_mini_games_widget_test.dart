import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_arena/screens/color_blocks_screen.dart';
import 'package:game_arena/screens/mini_games_screen.dart';
import 'package:game_arena/screens/school_maze_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  testWidgets(
    'maze starts, accepts a solved route, and progresses to next level',
    (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: SchoolMazeScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Find your way home!'), findsOneWidget);
      await tester.tap(find.text('Start adventure'));
      await tester.pump(const Duration(seconds: 4));
      await _solveCurrentMaze(tester);
      expect(find.textContaining('Player 1 finished in'), findsOneWidget);
      await tester.ensureVisible(find.text('Next level'));
      await tester.tap(find.text('Next level'));
      await tester.pump(const Duration(seconds: 4));
      expect(find.text('2/4'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('color blocks modes render and clearing a row scores points', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: ColorBlocksScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Color Match').first, findsOneWidget);

    for (final mode in [
      'Connect',
      'Clear Rows',
      'Color Quest',
      'Color Match',
    ]) {
      final chip = find.text(mode).last;
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await tester.tap(find.text('Clear Rows').last);
    await tester.pumpAndSettle();
    for (var cell = 42; cell < 49; cell++) {
      final block = find.byKey(ValueKey('color-block-$cell'));
      await tester.ensureVisible(block);
      await tester.tap(block);
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('100').first, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('maze race uses one maze and ranks both players', (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: SchoolMazeScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Local multiplayer race'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Player 1');
    await tester.ensureVisible(find.text('Start race'));
    await tester.tap(find.text('Start race'));
    await tester.pumpAndSettle();
    expect(find.text('Racer names must be unique.'), findsOneWidget);
    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
        .hideCurrentSnackBar();
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Player 2');
    await tester.ensureVisible(find.text('Start race'));
    await tester.tap(find.text('Start race'));
    await tester.pump(const Duration(seconds: 4));
    final firstMaze = await _mazeLabels(tester, 7);
    await _solveCurrentMaze(tester, keyboard: true);
    expect(find.textContaining('Player 1 finished in'), findsOneWidget);
    await tester.ensureVisible(find.text('Next racer'));
    await tester.tap(find.text('Next racer'));
    await tester.pump(const Duration(seconds: 4));
    expect(await _mazeLabels(tester, 7), firstMaze);
    await _solveCurrentMaze(tester);
    expect(find.textContaining('wins the race!'), findsOneWidget);
    expect(find.text('Player 1'), findsOneWidget);
    expect(find.text('Player 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('both games launch from Mini Games and return to the arcade', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: MiniGamesScreen()));
    await tester.pumpAndSettle();
    for (final title in ['School-to-Home Maze Race', 'Color Blocks Puzzle']) {
      final cardTitle = find.text(title).first;
      await tester.ensureVisible(cardTitle);
      await tester.tap(cardTitle);
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
      await tester.pumpAndSettle();
      expect(find.text('Mini Games'), findsOneWidget);
    }
  });
}

Future<List<String?>> _mazeLabels(WidgetTester tester, int size) async {
  return [
    for (var cell = 0; cell < size * size; cell++)
      tester
          .widget<Semantics>(find.byKey(ValueKey('maze-cell-$cell')))
          .properties
          .label,
  ];
}

Future<void> _solveCurrentMaze(
  WidgetTester tester, {
  bool keyboard = false,
}) async {
  const size = 7;
  const start = size + 1;
  const home = size * size - size - 2;
  final labels = await _mazeLabels(tester, size);
  final open = <int>{};
  for (var cell = 0; cell < labels.length; cell++) {
    if (labels[cell] != 'wall') open.add(cell);
  }
  final previous = <int, int?>{start: null};
  final queue = Queue<int>()..add(start);
  while (queue.isNotEmpty && !previous.containsKey(home)) {
    final cell = queue.removeFirst();
    for (final next in [cell - size, cell + size, cell - 1, cell + 1]) {
      if (!open.contains(next) || previous.containsKey(next)) continue;
      if ((next ~/ size - cell ~/ size).abs() +
              (next % size - cell % size).abs() !=
          1) {
        continue;
      }
      previous[next] = cell;
      queue.add(next);
    }
  }
  expect(previous.containsKey(home), isTrue);
  final route = <int>[];
  for (int? cell = home; cell != null; cell = previous[cell]) {
    route.add(cell);
  }
  final ordered = route.reversed.toList();
  for (var i = 1; i < ordered.length; i++) {
    final delta = ordered[i] - ordered[i - 1];
    final key = delta == -size
        ? LogicalKeyboardKey.arrowUp
        : delta == size
        ? LogicalKeyboardKey.arrowDown
        : delta == -1
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;
    if (keyboard) {
      await tester.sendKeyEvent(key);
    } else {
      final icon = delta == -size
          ? Icons.keyboard_arrow_up_rounded
          : delta == size
          ? Icons.keyboard_arrow_down_rounded
          : delta == -1
          ? Icons.chevron_left_rounded
          : Icons.chevron_right_rounded;
      await tester.ensureVisible(find.byIcon(icon));
      await tester.tap(find.byIcon(icon));
    }
    await tester.pump(const Duration(milliseconds: 110));
  }
}
