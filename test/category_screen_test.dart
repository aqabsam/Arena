import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_arena/game/game_session.dart';
import 'package:game_arena/models/game_models.dart';
import 'package:game_arena/screens/category_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('category grid adapts to mobile, tablet, and desktop widths', (
    tester,
  ) async {
    final session = GameSession();
    session.categories = <GameCategory>[
      const GameCategory(
        id: 'random',
        name: 'Random / Mixed',
        items: <GameItem>[],
        isRandomMix: true,
      ),
      for (final id in <String>[
        'marvel',
        'dc',
        'wwe',
        'bollywood',
        'hollywood',
        'pokemon',
        'singers',
        'youtubers',
        'animals',
        'cars',
        'bikes',
        'food',
      ])
        GameCategory(
          id: id,
          name: id[0].toUpperCase() + id.substring(1),
          items: <GameItem>[
            GameItem(id: '${id}_item', name: 'Sample item', categoryId: id),
          ],
        ),
    ];
    session.selectedCategory = session.categories[1];

    final viewports = <({Size size, int columns})>[
      (size: const Size(320, 640), columns: 1),
      (size: const Size(390, 844), columns: 2),
      (size: const Size(800, 900), columns: 3),
      (size: const Size(1440, 960), columns: 5),
    ];

    for (final viewport in viewports) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = viewport.size;
      await tester.pumpWidget(
        MaterialApp(home: CategoryScreen(session: session)),
      );
      await tester.pumpAndSettle();

      final grid = tester.widget<GridView>(
        find.byKey(const ValueKey<String>('category-grid')),
      );
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      tester
          .state<ScrollableState>(
            find.descendant(
              of: find.byKey(const ValueKey<String>('category-grid')),
              matching: find.byType(Scrollable),
            ),
          )
          .position
          .jumpTo(0);
      await tester.pump();
      expect(delegate.crossAxisCount, viewport.columns);
      expect(
        find.byKey(const ValueKey<String>('category-card-marvel')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.text('Classmates'), findsNothing);

      await tester.drag(
        find.byKey(const ValueKey<String>('category-grid')),
        const Offset(0, -420),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Viewport ${viewport.size}',
      );
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
