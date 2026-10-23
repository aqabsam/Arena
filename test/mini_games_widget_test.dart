import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_arena/screens/mini_games_screen.dart';
import 'package:game_arena/screens/truth_or_dare_screen.dart';

void main() {
  const gameTitles = [
    'Tic-Tac-Toe',
    'Rock Paper Scissors',
    'Connect Four',
    'Dots and Boxes',
    'Memory Match',
    'Number Duel',
    'Quick Tap',
    'Stick Takeaway',
  ];

  testWidgets('all eight classic mini games open as playable match screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: MiniGamesScreen()));
    for (final title in gameTitles) {
      await tester.tap(find.text(title).first);
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Leave match?'), findsOneWidget);
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();
      expect(find.text('Mini Games'), findsOneWidget);
    }
  });

  testWidgets('mini games fit a narrow phone viewport', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: MiniGamesScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final title in gameTitles) {
      final card = find.text(title).first;
      await tester.ensureVisible(card);
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: '$title overflowed at 320 × 640',
      );
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('player indicators use red for Player 1 and blue for Player 2', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MiniGamesScreen()));
    final playerIcons = tester.widgetList<Icon>(
      find.byIcon(Icons.person_rounded),
    );
    expect(playerIcons.map((icon) => icon.color).toList(), <Color?>[
      const Color(0xFFFF4D6D),
      const Color(0xFF3C9EFF),
    ]);
  });

  testWidgets('Truth or Dare completes a local match and shows results', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: TruthOrDareScreen()));
    await tester.tap(find.text('Start game'));
    await tester.pumpAndSettle();

    for (var turn = 0; turn < 6; turn++) {
      await tester.ensureVisible(find.text('Spin to choose'));
      await tester.tap(find.text('Spin to choose'));
      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Truth').last);
      await tester.tap(find.text('Truth').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Complete'));
      await tester.tap(find.text('Complete'));
      await tester.pumpAndSettle();
    }

    expect(find.text('That’s a wrap!'), findsOneWidget);
    expect(find.text('6 turns · 3 rounds · 2 players'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
