import 'package:flutter/material.dart';

import 'audio/game_audio_service.dart';
import 'game/game_session.dart';
import 'screens/category_screen.dart';
import 'screens/home_screen.dart';
import 'screens/players_screen.dart';
import 'screens/round_screen.dart';
import 'screens/score_screen.dart';
import 'screens/team_size_screen.dart';
import 'theme/game_arena_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final session = GameSession();
  await session.loadCategories();
  await GameAudioService.instance.initialize();
  runApp(GameArenaApp(session: session));
}

class GameArenaApp extends StatelessWidget {
  const GameArenaApp({super.key, required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Arena',
      debugShowCheckedModeBanner: false,
      theme: buildArenaTheme(),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (context) => HomeScreen(session: session),
        '/category': (context) => CategoryScreen(session: session),
        '/team-size': (context) => TeamSizeScreen(session: session),
        '/players': (context) => PlayersScreen(session: session),
        '/round': (context) => RoundScreen(session: session),
        '/score': (context) => ScoreScreen(session: session),
      },
    );
  }
}
