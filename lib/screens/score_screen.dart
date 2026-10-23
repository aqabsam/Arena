import 'package:flutter/material.dart';

import '../game/bid_challenge_game.dart';
import '../game/game_session.dart';
import '../models/game_models.dart';

class ScoreScreen extends StatelessWidget {
  const ScoreScreen({super.key, required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final leaderboard = session.activeGame?.leaderboard() ?? <GamePlayer>[];
    final game = session.activeGame;
    final teamAScore = game?.teamScore('Team A') ?? 0;
    final teamBScore = game?.teamScore('Team B') ?? 0;
    final isComplete = game?.isComplete ?? false;
    final winningTeam = switch (isComplete ? game!.teamWinner : null) {
      TeamWinner.teamA => 'Team A',
      TeamWinner.teamB => 'Team B',
      TeamWinner.draw || null => null,
    };
    final teamAPlayers =
        game?.players.take(session.teamSize).toList() ?? const <GamePlayer>[];
    final teamBPlayers =
        game?.players.skip(session.teamSize).toList() ?? const <GamePlayer>[];
    final teamACharacters = teamAPlayers
        .expand((player) => player.purchasedItems)
        .map((item) => item.name)
        .toList(growable: false);
    final teamBCharacters = teamBPlayers
        .expand((player) => player.purchasedItems)
        .map((item) => item.name)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFF071B46),
      appBar: AppBar(title: const Text('Bid Challenge')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: <Widget>[
            if (game != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF375F), Color(0xFFFF8A25)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFB72A57),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    const Icon(
                      Icons.emoji_events_rounded,
                      size: 44,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isComplete ? 'FINAL RESULT' : 'MATCH IN PROGRESS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      !isComplete
                          ? 'Keep Playing!'
                          : winningTeam == null
                          ? 'It’s a Draw!'
                          : '$winningTeam Wins!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 34,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Team A $teamAScore · Team B $teamBScore points',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                _TeamScoreCard(
                  name: 'Team A',
                  score: teamAScore,
                  coins: game?.teamCoins('Team A') ?? 0,
                  characters: teamACharacters,
                  color: const Color(0xFF1689FF),
                ),
                const SizedBox(width: 10),
                _TeamScoreCard(
                  name: 'Team B',
                  score: teamBScore,
                  coins: game?.teamCoins('Team B') ?? 0,
                  characters: teamBCharacters,
                  color: const Color(0xFFFF3159),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Team score = remaining coins + 10 points per item won.',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'PLAYER STANDINGS',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: leaderboard.length,
                itemBuilder: (context, index) {
                  final player = leaderboard[index];
                  final isWinner = index == 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isWinner
                          ? const Color(0xFF2449A8)
                          : const Color(0xFF152A60),
                      borderRadius: BorderRadius.circular(18),
                      border: isWinner
                          ? Border.all(color: Color(0xFFFFD75A), width: 1.5)
                          : null,
                    ),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: isWinner
                              ? const Color(0xFFFFD75A)
                              : const Color(0xFF3D8BFF),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                player.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                player.purchasedItems.isEmpty
                                    ? '${player.itemsWon} items won'
                                    : '${player.itemsWon} items won · ${player.purchasedItems.map((item) => item.name).join(', ')}',
                                style: const TextStyle(color: Colors.white70),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${player.coins} coins',
                          style: const TextStyle(
                            color: Color(0xFFFFD75A),
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      session.restartGame();
                      Navigator.of(context).pushReplacementNamed('/round');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF5A43F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Play Again',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF173B88),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamScoreCard extends StatelessWidget {
  const _TeamScoreCard({
    required this.name,
    required this.score,
    required this.coins,
    required this.characters,
    required this.color,
  });

  final String name;
  final int score;
  final int coins;
  final List<String> characters;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: <Widget>[
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '$score points',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$coins coins remaining',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              characters.isEmpty
                  ? 'Characters acquired: none'
                  : 'Characters acquired: ${characters.join(', ')}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
