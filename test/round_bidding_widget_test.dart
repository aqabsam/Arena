import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_arena/game/game_session.dart';
import 'package:game_arena/models/game_models.dart';
import 'package:game_arena/screens/round_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'open auction advances turns and allows purchase of current bid',
    (tester) async {
      final session = GameSession();
      session.teamSize = 1;
      session.setPlayersFromTeamSize(1, <String>['Alex', 'Sam']);
      final category = const GameCategory(
        id: 'marvel',
        name: 'Marvel',
        items: <GameItem>[
          GameItem(
            id: 'marvel_iron_man',
            name: 'Iron Man',
            categoryId: 'marvel',
          ),
        ],
      );
      session.categories = <GameCategory>[category];
      session.selectedCategory = category;
      session.startGame();

      await tester.pumpWidget(MaterialApp(home: RoundScreen(session: session)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.textContaining("Alex's turn"), findsOneWidget);
      expect(find.text('Sam · TURN'), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName ==
                  'assets/images/marvel/iron_man.webp',
        ),
        findsOneWidget,
      );

      await tester.ensureVisible(find.byKey(const Key('submit-auction-bid')));
      await tester.tap(find.byKey(const Key('submit-auction-bid')));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining("Sam's turn"), findsOneWidget);
      expect(find.text('Alex · TURN'), findsNothing);
      expect(find.textContaining('Current bid: ₹10'), findsOneWidget);
      await tester.ensureVisible(find.text('+5 Coins'));
      await tester.tap(find.text('+5 Coins'));
      await tester.ensureVisible(find.byKey(const Key('submit-auction-bid')));
      await tester.tap(find.byKey(const Key('submit-auction-bid')));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining("Alex's turn"), findsOneWidget);
      expect(find.textContaining('Current bid: ₹15'), findsOneWidget);
      expect(find.byKey(const Key('purchase-current-bid')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('purchase-current-bid')));
      await tester.tap(find.byKey(const Key('purchase-current-bid')));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('All auctions are complete.'), findsOneWidget);
      expect(
        find.text('SOLD · Iron Man → Team B · Sam for 15 coins'),
        findsOneWidget,
      );
      expect(session.activeGame!.players.map((player) => player.coins), <int>[
        100,
        85,
      ]);
    },
  );
}
