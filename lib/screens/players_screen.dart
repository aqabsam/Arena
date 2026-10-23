import 'package:flutter/material.dart';

import '../audio/game_audio_service.dart';
import '../game/game_session.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key, required this.session});

  final GameSession session;

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  late final List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = List<TextEditingController>.generate(
      widget.session.teamSize * 2,
      (index) => TextEditingController(text: widget.session.playerNames[index]),
    );
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startGame() {
    GameAudioService.instance.play(GameSound.gameStart);
    final names = controllers
        .map((controller) => controller.text.trim())
        .toList();
    if (names.any((name) => name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a name for every player.')),
      );
      return;
    }
    if (names.map((name) => name.toLowerCase()).toSet().length !=
        names.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Player names must be unique.')),
      );
      return;
    }
    widget.session.playerNames = names;
    widget.session.startGame();
    Navigator.of(context).pushReplacementNamed('/round');
  }

  @override
  Widget build(BuildContext context) {
    final teamSize = widget.session.teamSize;
    return Scaffold(
      appBar: AppBar(title: const Text('Bid Challenge')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F73FF), Color(0xFF5737FF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: <Widget>[
                    const Text(
                      'Enter Players',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$teamSize players per team · 100 virtual coins each',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: _TeamPlayersColumn(
                        title: 'Team A',
                        color: const Color(0xFF1689FF),
                        controllers: controllers
                            .take(teamSize)
                            .toList(growable: false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TeamPlayersColumn(
                        title: 'Team B',
                        color: const Color(0xFFFF3159),
                        controllers: controllers
                            .skip(teamSize)
                            .toList(growable: false),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A43F2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: const Text(
                    'Start Game',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamPlayersColumn extends StatelessWidget {
  const _TeamPlayersColumn({
    required this.title,
    required this.color,
    required this.controllers,
  });

  final String title;
  final Color color;
  final List<TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F4B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.65)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(7),
              itemCount: controllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: controllers[index],
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(
                          color: Color(0xFF20315B),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 11,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFEAF0FF),
                          hintText: 'Player ${index + 1}',
                          hintStyle: const TextStyle(
                            color: Color(0xFF6D7897),
                            fontSize: 11,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
