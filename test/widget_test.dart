// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:game_arena/game/game_session.dart';
import 'package:game_arena/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Game Arena loads the home screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final session = GameSession();
    await tester.runAsync(session.loadCategories);
    await tester.pumpWidget(GameArenaApp(session: session));

    expect(find.text('GAME'), findsOneWidget);
    expect(find.text('Bid Challenge'), findsOneWidget);
    expect(find.text('11 quick games for two players'), findsOneWidget);
  });
}
