import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../audio/game_audio_service.dart';
import '../game/mini_game_logic.dart';
import '../theme/game_arena_theme.dart';
import 'truth_or_dare_screen.dart';
import 'school_maze_screen.dart';
import 'color_blocks_screen.dart';

const _navy = ArenaColors.background;
const _panel = ArenaColors.surface;
const _red = Color(0xFFFF4D6D);
const _blue = ArenaColors.primary;
const _gold = ArenaColors.gold;

void _showWinnerDialog(BuildContext context, String player, String game) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF202D55), Color(0xFF101A35)],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: ArenaColors.gold.withValues(alpha: .72)),
          boxShadow: [
            BoxShadow(
              color: ArenaColors.gold.withValues(alpha: .18),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              color: ArenaColors.gold,
              size: 54,
            ),
            const SizedBox(height: 12),
            const Text(
              'CONGRATULATIONS!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: .6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$player wins $game!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ArenaColors.textMuted,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.check_rounded),
              label: const Text('Awesome!'),
            ),
          ],
        ),
      ),
    ),
  );
}

void _announceWinner(BuildContext context, String player, String game) {
  GameAudioService.instance.play(GameSound.victory);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) _showWinnerDialog(context, player, game);
  });
}

class MiniGamesScreen extends StatefulWidget {
  const MiniGamesScreen({super.key});

  @override
  State<MiniGamesScreen> createState() => _MiniGamesScreenState();
}

class _MiniGamesScreenState extends State<MiniGamesScreen> {
  final _one = TextEditingController(text: 'Player 1');
  final _two = TextEditingController(text: 'Player 2');
  @override
  void dispose() {
    _one.dispose();
    _two.dispose();
    super.dispose();
  }

  void _launch(_GameInfo game) {
    GameAudioService.instance.play(GameSound.gameStart);
    if (game.id == 'truth_dare') {
      Navigator.of(context).push(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (_, _, _) => const TruthOrDareScreen(),
          transitionsBuilder: (_, animation, _, child) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(.035, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          ),
        ),
      );
      return;
    }
    if (game.id == 'school_maze' || game.id == 'color_blocks') {
      Navigator.of(context).push(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (_, _, _) => game.id == 'school_maze'
              ? const SchoolMazeScreen()
              : const ColorBlocksScreen(),
          transitionsBuilder: (_, animation, _, child) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(.035, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          ),
        ),
      );
      return;
    }
    final first = _one.text.trim().isEmpty ? 'Player 1' : _one.text.trim();
    final second = _two.text.trim().isEmpty ? 'Player 2' : _two.text.trim();
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 210),
        pageBuilder: (_, _, _) =>
            _MiniGameScreen(game: game, players: [first, second]),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(.035, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _navy,
    appBar: AppBar(
      title: const Text(
        'ARCADE',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
      centerTitle: false,
    ),
    body: Stack(
      children: [
        const Positioned(
          top: -80,
          right: -120,
          child: _GlowOrb(size: 280, color: ArenaColors.purple),
        ),
        const Positioned(
          top: 360,
          left: -180,
          child: _GlowOrb(size: 300, color: ArenaColors.primary),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 760
                  ? 3
                  : constraints.maxWidth < 430
                  ? 1
                  : 2;
              final remaining = _games.skip(1).toList();
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _MiniGamesHeader(),
                        const SizedBox(height: 18),
                        _FeaturedGameCard(
                          game: _games.first,
                          onTap: () => _launch(_games.first),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: ArenaColors.surface.withValues(alpha: .94),
                            borderRadius: BorderRadius.circular(
                              ArenaRadii.card,
                            ),
                            border: Border.all(color: ArenaColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.people_alt_rounded,
                                    color: ArenaColors.cyan,
                                    size: 19,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'PLAYERS',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.4,
                                      color: ArenaColors.textMuted,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    'SAME DEVICE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: ArenaColors.success,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: .6,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (constraints.maxWidth < 360)
                                Column(
                                  children: [
                                    _nameField(_one, 'Player 1', _red),
                                    const SizedBox(height: 8),
                                    _nameField(_two, 'Player 2', _blue),
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                    Expanded(
                                      child: _nameField(_one, 'Player 1', _red),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _nameField(
                                        _two,
                                        'Player 2',
                                        _blue,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 23),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'THE ARCADE',
                                    style: TextStyle(
                                      color: ArenaColors.cyan,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.8,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'More to play',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${remaining.length} GAMES',
                              style: const TextStyle(
                                color: ArenaColors.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: remaining.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: constraints.maxWidth < 370
                                    ? 188
                                    : 202,
                              ),
                          itemBuilder: (context, index) => _GameCard(
                            game: remaining[index],
                            onTap: () => _launch(remaining[index]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );

  Widget _nameField(
    TextEditingController controller,
    String label,
    Color color,
  ) => TextField(
    controller: controller,
    textCapitalization: TextCapitalization.words,
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: _panel,
      prefixIcon: Icon(Icons.person_rounded, color: color),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ArenaRadii.control),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    ),
  );
}

class _GameInfo {
  const _GameInfo(this.id, this.title, this.description, this.icon, this.color);
  final String id, title, description;
  final IconData icon;
  final Color color;
}

const _games = <_GameInfo>[
  _GameInfo(
    'ttt',
    'Tic-Tac-Toe',
    'Classic 3 × 3 strategy',
    Icons.grid_3x3_rounded,
    ArenaColors.purple,
  ),
  _GameInfo(
    'rps',
    'Rock Paper Scissors',
    'Secret picks, best of 3 or 5',
    Icons.back_hand_rounded,
    Color(0xFFFFA85E),
  ),
  _GameInfo(
    'connect',
    'Connect Four',
    'Connect four discs to win',
    Icons.circle_rounded,
    ArenaColors.cyan,
  ),
  _GameInfo(
    'dots',
    'Dots and Boxes',
    'Claim boxes and take turns',
    Icons.apps_rounded,
    ArenaColors.success,
  ),
  _GameInfo(
    'memory',
    'Memory Match',
    'Find pairs and score points',
    Icons.style_rounded,
    Color(0xFFEE85C3),
  ),
  _GameInfo(
    'number',
    'Number Duel',
    'Guess the hidden number',
    Icons.pin_rounded,
    Color(0xFF76B4FF),
  ),
  _GameInfo(
    'tap',
    'Quick Tap',
    'Test your reaction speed',
    Icons.touch_app_rounded,
    ArenaColors.gold,
  ),
  _GameInfo(
    'nim',
    'Stick Takeaway',
    'Take 1–3; last stick wins',
    Icons.remove_circle_outline_rounded,
    ArenaColors.playerTwo,
  ),
  _GameInfo(
    'truth_dare',
    'Truth or Dare',
    'Spin, pick a player, and play',
    Icons.local_fire_department_rounded,
    Color(0xFFFF718C),
  ),
  _GameInfo(
    'school_maze',
    'School-to-Home Maze Race',
    'Race through the maze and get home',
    Icons.route_rounded,
    Color(0xFF63DDA8),
  ),
  _GameInfo(
    'color_blocks',
    'Color Blocks Puzzle',
    'Match, connect, and clear the grid',
    Icons.grid_view_rounded,
    Color(0xFFFFC857),
  ),
];

class _MiniGamesHeader extends StatelessWidget {
  const _MiniGamesHeader();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 47,
          height: 47,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ArenaColors.primary, ArenaColors.purple],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: ArenaColors.primary.withValues(alpha: .18),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.sports_esports_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GAME ARENA  /  LOCAL PLAY',
                style: TextStyle(
                  color: ArenaColors.cyan,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.45,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Mini Games',
                style: TextStyle(
                  fontSize: 25,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.5,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Quick matches. Friendly rivalries.',
                style: TextStyle(color: ArenaColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            color: ArenaColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ArenaColors.border),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 13,
                color: ArenaColors.success,
              ),
              SizedBox(width: 5),
              Text(
                'OFFLINE',
                style: TextStyle(
                  fontSize: 8,
                  letterSpacing: .5,
                  fontWeight: FontWeight.w900,
                  color: ArenaColors.success,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: .12),
            color.withValues(alpha: .025),
            Colors.transparent,
          ],
        ),
      ),
    ),
  );
}

class _FeaturedGameCard extends StatelessWidget {
  const _FeaturedGameCard({required this.game, required this.onTap});
  final _GameInfo game;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(23),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1B2850), Color(0xFF121A31), Color(0xFF10182B)],
      ),
      border: Border.all(color: ArenaColors.purple.withValues(alpha: .56)),
      boxShadow: [
        BoxShadow(
          color: ArenaColors.purple.withValues(alpha: .12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const _TicTacToeArtwork(size: 96),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ArenaColors.purple.withValues(alpha: .18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'FEATURED',
                            style: TextStyle(
                              color: Color(0xFFC1B1FF),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Flexible(
                          child: Text(
                            '2 PLAYERS · SAME DEVICE',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ArenaColors.textMuted,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      game.title,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'A quick classic. Outsmart your rival.',
                      maxLines: 2,
                      style: TextStyle(
                        color: ArenaColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 39,
                      child: FilledButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: const Text(
                          'Play now',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: ArenaColors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _TicTacToeArtwork extends StatelessWidget {
  const _TicTacToeArtwork({required this.size});
  final double size;
  @override
  Widget build(BuildContext context) {
    const marks = <int, String>{0: '×', 4: '○', 8: '×'};
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF242F64), Color(0xFF111A37)],
        ),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: ArenaColors.purple.withValues(alpha: .45)),
        boxShadow: [
          BoxShadow(
            color: ArenaColors.purple.withValues(alpha: .14),
            blurRadius: 18,
          ),
        ],
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
        ),
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .035),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Text(
              marks[index] ?? '',
              style: TextStyle(
                color: index == 4 ? ArenaColors.cyan : const Color(0xFFC0A7FF),
                fontSize: 23,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatefulWidget {
  const _GameCard({required this.game, required this.onTap});
  final _GameInfo game;
  final VoidCallback onTap;
  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> {
  bool pressed = false;
  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: pressed ? .975 : 1,
    duration: const Duration(milliseconds: 120),
    child: Material(
      color: ArenaColors.surface,
      borderRadius: BorderRadius.circular(ArenaRadii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(ArenaRadii.card),
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => pressed = true),
        onTapCancel: () => setState(() => pressed = false),
        onTapUp: (_) => setState(() => pressed = false),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ArenaRadii.card),
            border: Border.all(color: ArenaColors.border),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ArenaColors.surfaceRaised,
                widget.game.color.withValues(alpha: .09),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: widget.game.color.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      widget.game.icon,
                      color: widget.game.color,
                      size: 25,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: ArenaColors.success,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.game.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Expanded(
                child: Text(
                  widget.game.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
              Row(
                children: [
                  const Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.people_alt_rounded,
                          color: ArenaColors.textMuted,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '2 players',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ArenaColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Semantics(
                    label: 'Play ${widget.game.title}',
                    button: true,
                    child: Container(
                      width: 29,
                      height: 29,
                      decoration: BoxDecoration(
                        color: widget.game.color.withValues(alpha: .16),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.game.color.withValues(alpha: .42),
                        ),
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: widget.game.color,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _MiniGameScreen extends StatelessWidget {
  const _MiniGameScreen({required this.game, required this.players});
  final _GameInfo game;
  final List<String> players;
  @override
  Widget build(BuildContext context) => _MatchFrame(
    title: game.title,
    child: switch (game.id) {
      'ttt' => _TicTacToe(players: players),
      'rps' => _RockPaperScissors(players: players),
      'connect' => _ConnectFour(players: players),
      'dots' => _DotsAndBoxes(players: players),
      'memory' => _MemoryMatch(players: players),
      'number' => _NumberDuel(players: players),
      'tap' => _QuickTap(players: players),
      _ => _Nim(players: players),
    },
  );
}

class _MatchFrame extends StatelessWidget {
  const _MatchFrame({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _navy,
    appBar: AppBar(
      title: Text(title),
      centerTitle: true,
      titleSpacing: 0,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 14),
          child: Icon(
            Icons.wifi_off_rounded,
            size: 17,
            color: ArenaColors.success,
          ),
        ),
      ],
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () async {
          final leave = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: ArenaColors.surfaceRaised,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: ArenaColors.border),
              ),
              title: const Text('Leave match?'),
              content: const Text('Your current match will end.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Stay'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Exit'),
                ),
              ],
            ),
          );
          if (leave == true && context.mounted) Navigator.pop(context);
        },
      ),
    ),
    body: Stack(
      children: [
        const Positioned(
          top: -100,
          right: -150,
          child: _GlowOrb(size: 300, color: ArenaColors.purple),
        ),
        SafeArea(child: child),
      ],
    ),
  );
}

Widget _playersScore(
  List<String> names,
  int turn, {
  List<int> scores = const [0, 0],
}) => Row(
  children: [
    _scoreChip(names[0], scores[0], _red, turn == 1, player: 1),
    const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'VS',
        style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900),
      ),
    ),
    _scoreChip(names[1], scores[1], _blue, turn == 2, player: 2),
  ],
);
Widget _scoreChip(
  String name,
  int score,
  Color color,
  bool active, {
  required int player,
}) => Expanded(
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 220),
    curve: Curves.easeOutCubic,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: active ? .19 : .08),
          ArenaColors.surface.withValues(alpha: .96),
        ],
      ),
      borderRadius: BorderRadius.circular(ArenaRadii.panel),
      border: Border.all(
        color: color.withValues(alpha: active ? .9 : .26),
        width: active ? 1.5 : 1,
      ),
      boxShadow: active
          ? [
              BoxShadow(
                color: color.withValues(alpha: .12),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ]
          : const [],
    ),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: .17),
            border: Border.all(color: color.withValues(alpha: .55)),
          ),
          child: Center(
            child: Text(
              name.trim().isEmpty
                  ? '$player'
                  : name.trim().characters.first.toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: active ? Colors.white : Colors.white70,
                ),
              ),
              Text(
                active ? 'YOUR TURN' : 'PLAYER $player',
                style: TextStyle(
                  color: color.withValues(alpha: .9),
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                ),
              ),
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Text(
            '$score',
            key: ValueKey(score),
            style: TextStyle(
              color: color,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  ),
);
Widget _actionButton(
  String label,
  VoidCallback onPressed, {
  IconData icon = Icons.refresh_rounded,
}) => OutlinedButton.icon(
  onPressed: onPressed,
  icon: Icon(icon),
  label: Text(label),
  style: OutlinedButton.styleFrom(
    foregroundColor: Colors.white,
    side: const BorderSide(color: ArenaColors.border),
    minimumSize: const Size(0, 46),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ArenaRadii.control),
    ),
  ),
);
Widget _resultText(String text, {Color color = _gold}) => AnimatedSwitcher(
  duration: const Duration(milliseconds: 180),
  child: Container(
    key: ValueKey(text),
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .075),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: color.withValues(alpha: .16)),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w800,
        fontSize: 15,
        height: 1.15,
      ),
    ),
  ),
);

class _TicTacToe extends StatefulWidget {
  const _TicTacToe({required this.players});
  final List<String> players;
  @override
  State<_TicTacToe> createState() => _TicTacToeState();
}

class _TicTacToeState extends State<_TicTacToe> {
  final game = TicTacToeState();
  final wins = [0, 0];
  int draws = 0;
  void play(int i) {
    if (!game.play(i)) {
      GameAudioService.instance.play(GameSound.incorrect);
      return;
    }
    GameAudioService.instance.play(GameSound.selection);
    setState(() {
      if (game.winner != 0) wins[game.winner - 1]++;
      if (game.draw) draws++;
    });
    if (game.winner != 0) {
      _announceWinner(context, widget.players[game.winner - 1], 'Tic-Tac-Toe');
    }
  }

  void restart() => setState(game.reset);
  void newMatch() => setState(() {
    game.reset();
    wins.setAll(0, [0, 0]);
    draws = 0;
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        _playersScore(
          widget.players,
          game.winner == 0 ? game.currentPlayer : game.winner,
          scores: wins,
        ),
        const SizedBox(height: 8),
        Text('Draws: $draws', style: const TextStyle(color: Colors.white60)),
        _resultText(
          game.winner != 0
              ? '${widget.players[game.winner - 1]} wins!'
              : game.draw
              ? 'It is a draw!'
              : "${widget.players[game.currentPlayer - 1]}'s turn  •  ${game.currentPlayer == 1 ? 'X' : 'O'}",
          color: game.winner == 2 ? _blue : _gold,
        ),
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, i) {
                  final value = game.board[i];
                  final winning = game.winningLine.contains(i);
                  return InkWell(
                    onTap: () => play(i),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: winning
                            ? const Color(0xFF174A49)
                            : ArenaColors.surface,
                        border: Border.all(
                          color: winning
                              ? ArenaColors.success
                              : ArenaColors.border,
                          width: winning ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: AnimatedScale(
                          scale: value == 0 ? 0 : 1,
                          duration: const Duration(milliseconds: 150),
                          child: value == 0
                              ? const SizedBox.shrink()
                              : LayoutBuilder(
                                  builder: (context, constraints) =>
                                      CustomPaint(
                                        size: Size.square(
                                          min(constraints.maxWidth * .58, 68),
                                        ),
                                        painter: _MarkPainter(
                                          player: value,
                                          color: value == 1 ? _red : _blue,
                                        ),
                                      ),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            _actionButton('Restart Board', restart),
            _actionButton('New Match', newMatch, icon: Icons.flag_rounded),
          ],
        ),
      ],
    ),
  );
}

class _RockPaperScissors extends StatefulWidget {
  const _RockPaperScissors({required this.players});
  final List<String> players;
  @override
  State<_RockPaperScissors> createState() => _RockPaperScissorsState();
}

class _RockPaperScissorsState extends State<_RockPaperScissors> {
  final picks = <Hand>[];
  final score = [0, 0];
  int stage = 0, rounds = 0, target = 2;
  String message = '';
  bool get finished =>
      target != 999 && (score[0] >= target || score[1] >= target);
  void choose(Hand hand) {
    GameAudioService.instance.play(GameSound.selection);
    setState(() {
      picks.add(hand);
      if (picks.length == 1) {
        stage = 1;
      } else {
        stage = 3;
        final result = resolveHands(picks[0], picks[1]);
        if (result > 0) score[result - 1]++;
        rounds++;
        message = result == 0
            ? 'Round tied!'
            : '${widget.players[result - 1]} wins the round!';
      }
    });
    if (picks.length == 2) {
      final result = resolveHands(picks[0], picks[1]);
      if (result > 0) {
        _announceWinner(context, widget.players[result - 1], 'this round');
      }
    }
  }

  void next() {
    setState(() {
      picks.clear();
      stage = 0;
      message = '';
    });
  }

  void reset() => setState(() {
    picks.clear();
    score.setAll(0, [0, 0]);
    stage = 0;
    rounds = 0;
    message = '';
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        _playersScore(
          widget.players,
          stage == 1 || stage == 2 ? 2 : 1,
          scores: score,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Mode: '),
            DropdownButton<int>(
              value: target,
              items: const [
                DropdownMenuItem(value: 2, child: Text('Best of 3')),
                DropdownMenuItem(value: 3, child: Text('Best of 5')),
                DropdownMenuItem(value: 999, child: Text('Unlimited')),
              ],
              onChanged: (v) => setState(() {
                target = v ?? 2;
                picks.clear();
                score.setAll(0, [0, 0]);
                stage = 0;
                rounds = 0;
                message = '';
              }),
            ),
          ],
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (finished)
                  _resultText(
                    '${widget.players[score[0] > score[1] ? 0 : 1]} wins the match!',
                  )
                else if (stage == 1) ...[
                  const Icon(
                    Icons.visibility_off_rounded,
                    color: _gold,
                    size: 52,
                  ),
                  _resultText('Pass the device to ${widget.players[1]}'),
                  const Text(
                    'Player 1’s pick is hidden. Pass the device before continuing.',
                    style: TextStyle(color: Colors.white60),
                  ),
                  FilledButton(
                    onPressed: () => setState(() => stage = 2),
                    child: Text('${widget.players[1]} is ready'),
                  ),
                ] else if (stage == 2) ...[
                  _resultText('${widget.players[1]}, choose privately'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: Hand.values
                        .map(
                          (hand) => _HandPickCard(
                            hand: hand,
                            onTap: () => choose(hand),
                          ),
                        )
                        .toList(),
                  ),
                ] else if (stage == 3) ...[
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: Row(
                      key: ValueKey(rounds),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _HandReveal(
                          name: widget.players[0],
                          hand: picks[0],
                          color: _red,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'VS',
                            style: TextStyle(
                              color: ArenaColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        _HandReveal(
                          name: widget.players[1],
                          hand: picks[1],
                          color: _blue,
                        ),
                      ],
                    ),
                  ),
                  _resultText(message),
                  Text(
                    'Round $rounds',
                    style: const TextStyle(color: Colors.white60),
                  ),
                ] else ...[
                  _resultText('${widget.players[0]}, choose privately'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: Hand.values
                        .map(
                          (hand) => _HandPickCard(
                            hand: hand,
                            onTap: finished ? null : () => choose(hand),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (stage == 3)
                  FilledButton(
                    onPressed: finished ? reset : next,
                    child: Text(finished ? 'Play Again' : 'Next Round'),
                  ),
              ],
            ),
          ),
        ),
        if (stage != 3) _actionButton('Restart Match', reset),
      ],
    ),
  );
}

IconData _handIcon(Hand hand) => switch (hand) {
  Hand.rock => Icons.landscape_rounded,
  Hand.paper => Icons.description_rounded,
  Hand.scissors => Icons.content_cut_rounded,
};

class _HandPickCard extends StatelessWidget {
  const _HandPickCard({required this.hand, required this.onTap});
  final Hand hand;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 92,
    height: 112,
    child: Material(
      color: ArenaColors.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: ArenaColors.border),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [ArenaColors.surfaceRaised, ArenaColors.surface],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_handIcon(hand), color: ArenaColors.cyan, size: 34),
              const SizedBox(height: 9),
              Text(
                hand.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .8,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _HandReveal extends StatelessWidget {
  const _HandReveal({
    required this.name,
    required this.hand,
    required this.color,
  });
  final String name;
  final Hand hand;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 94,
    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: color.withValues(alpha: .35)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_handIcon(hand), color: color, size: 34),
        const SizedBox(height: 7),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
        ),
        Text(
          hand.name,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.player, required this.color});
  final int player;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final inset = size.shortestSide * .2;
    if (player == 1) {
      canvas.drawLine(
        Offset(inset, inset),
        Offset(size.width - inset, size.height - inset),
        paint,
      );
      canvas.drawLine(
        Offset(size.width - inset, inset),
        Offset(inset, size.height - inset),
        paint,
      );
    } else {
      canvas.drawCircle(
        size.center(Offset.zero),
        size.shortestSide * .3,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MarkPainter oldDelegate) =>
      player != oldDelegate.player || color != oldDelegate.color;
}

class _ConnectFour extends StatefulWidget {
  const _ConnectFour({required this.players});
  final List<String> players;
  @override
  State<_ConnectFour> createState() => _ConnectFourState();
}

class _ConnectFourState extends State<_ConnectFour> {
  final game = ConnectFourState();
  void reset() => setState(game.reset);
  void drop(int column) {
    if (!game.drop(column)) {
      GameAudioService.instance.play(GameSound.incorrect);
      return;
    }
    GameAudioService.instance.play(GameSound.selection);
    setState(() {});
    if (game.winner != 0) {
      _announceWinner(context, widget.players[game.winner - 1], 'Connect Four');
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      children: [
        _playersScore(
          widget.players,
          game.winner == 0 ? game.currentPlayer : game.winner,
        ),
        _resultText(
          game.winner != 0
              ? '${widget.players[game.winner - 1]} wins!'
              : game.draw
              ? 'Board full — draw!'
              : "${widget.players[game.currentPlayer - 1]}'s turn",
          color: game.winner == 2 ? _blue : _gold,
        ),
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 7 / 6,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1D4A86), Color(0xFF122950)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ArenaColors.cyan.withValues(alpha: .42),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ArenaColors.primary.withValues(alpha: .14),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: List.generate(
                    6,
                    (r) => Expanded(
                      child: Row(
                        children: List.generate(
                          7,
                          (c) => Expanded(
                            child: GestureDetector(
                              onTap: () => drop(c),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, animation) =>
                                      SlideTransition(
                                        position:
                                            Tween<Offset>(
                                              begin: const Offset(0, -.85),
                                              end: Offset.zero,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOutCubic,
                                              ),
                                            ),
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      ),
                                  child: _ConnectDisc(
                                    key: ValueKey(game.board[r][c]),
                                    player: game.board[r][c],
                                    highlighted: game.winningCells.contains(
                                      '$r,$c',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        _actionButton('Restart Match', reset),
      ],
    ),
  );
}

class _ConnectDisc extends StatelessWidget {
  const _ConnectDisc({
    super.key,
    required this.player,
    required this.highlighted,
  });
  final int player;
  final bool highlighted;
  @override
  Widget build(BuildContext context) {
    final color = player == 1 ? _red : _blue;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: player == 0
            ? const RadialGradient(
                center: Alignment(-.35, -.45),
                colors: [Color(0xFF21304B), Color(0xFF0B1324)],
              )
            : RadialGradient(
                center: const Alignment(-.35, -.45),
                colors: [
                  Color.lerp(color, Colors.white, .3)!,
                  color,
                  Color.lerp(color, Colors.black, .35)!,
                ],
              ),
        border: Border.all(
          color: highlighted
              ? ArenaColors.gold
              : color.withValues(alpha: player == 0 ? .22 : .88),
          width: highlighted ? 3 : 1,
        ),
        boxShadow: player == 0
            ? const []
            : [
                BoxShadow(
                  color: color.withValues(alpha: .22),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
      ),
    );
  }
}

class _DotsAndBoxes extends StatefulWidget {
  const _DotsAndBoxes({required this.players});
  final List<String> players;
  @override
  State<_DotsAndBoxes> createState() => _DotsAndBoxesState();
}

class _DotsAndBoxesState extends State<_DotsAndBoxes> {
  final game = DotsBoxesState();
  final edgeOwners = <String, int>{};
  void _draw(String orientation, int row, int column) {
    if (game.finished) return;
    final player = game.currentPlayer;
    final key = orientation == 'h' ? game.h(row, column) : game.v(row, column);
    if (game.draw(orientation, row, column)) edgeOwners[key] = player;
    setState(() {});
    if (game.finished) {
      final scores = [
        game.boxes.values.where((v) => v == 1).length,
        game.boxes.values.where((v) => v == 2).length,
      ];
      if (scores[0] != scores[1]) {
        _announceWinner(
          context,
          widget.players[scores[0] > scores[1] ? 0 : 1],
          'Dots and Boxes',
        );
      }
    }
  }

  void reset() => setState(() {
    game.reset();
    edgeOwners.clear();
  });
  @override
  Widget build(BuildContext context) {
    final scores = [
      game.boxes.values.where((v) => v == 1).length,
      game.boxes.values.where((v) => v == 2).length,
    ];
    final turn = game.currentPlayer;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _playersScore(widget.players, turn, scores: scores),
          _resultText(
            game.finished
                ? (scores[0] == scores[1]
                      ? 'Match drawn!'
                      : '${widget.players[scores[0] > scores[1] ? 0 : 1]} wins!')
                : "${widget.players[turn - 1]}'s turn  •  claim a box for another turn",
            color: turn == 1 ? _red : _blue,
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ArenaColors.surface.withValues(alpha: .68),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: ArenaColors.border),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 49,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                        ),
                    itemBuilder: (context, index) {
                      final r = index ~/ 7, c = index % 7;
                      if (r.isEven && c.isEven) {
                        return Center(
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: ArenaColors.cyan.withValues(
                                    alpha: .22,
                                  ),
                                  blurRadius: 7,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      if (r.isOdd && c.isOdd) {
                        final owner = game.boxes['${r ~/ 2},${c ~/ 2}'];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: owner == 1
                                ? _red.withValues(alpha: .22)
                                : owner == 2
                                ? _blue.withValues(alpha: .22)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: owner == null
                              ? null
                              : Center(
                                  child: Text(
                                    widget.players[owner - 1].characters.first,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        );
                      }
                      if (r.isEven) {
                        final rr = r ~/ 2, cc = c ~/ 2;
                        final key = game.h(rr, cc);
                        final active = game.edges.contains(key);
                        return Center(
                          child: GestureDetector(
                            onTap: () => _draw('h', rr, cc),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              width: double.infinity,
                              height: active ? 7 : 5,
                              decoration: BoxDecoration(
                                color: active
                                    ? (edgeOwners[key] == 1 ? _red : _blue)
                                    : ArenaColors.border,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: active
                                    ? [
                                        BoxShadow(
                                          color:
                                              (edgeOwners[key] == 1
                                                      ? _red
                                                      : _blue)
                                                  .withValues(alpha: .22),
                                          blurRadius: 5,
                                        ),
                                      ]
                                    : const [],
                              ),
                            ),
                          ),
                        );
                      }
                      final rr = r ~/ 2, cc = c ~/ 2;
                      final key = game.v(rr, cc);
                      final active = game.edges.contains(key);
                      return Center(
                        child: GestureDetector(
                          onTap: () => _draw('v', rr, cc),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            width: active ? 7 : 5,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: active
                                  ? (edgeOwners[key] == 1 ? _red : _blue)
                                  : ArenaColors.border,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                        color:
                                            (edgeOwners[key] == 1
                                                    ? _red
                                                    : _blue)
                                                .withValues(alpha: .22),
                                        blurRadius: 5,
                                      ),
                                    ]
                                  : const [],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          _actionButton('Restart Match', reset),
        ],
      ),
    );
  }
}

class _MemoryMatch extends StatefulWidget {
  const _MemoryMatch({required this.players});
  final List<String> players;
  @override
  State<_MemoryMatch> createState() => _MemoryMatchState();
}

class _MemoryMatchState extends State<_MemoryMatch> {
  static const faces = <IconData>[
    Icons.local_pizza_rounded,
    Icons.star_rounded,
    Icons.pets_rounded,
    Icons.casino_rounded,
    Icons.rocket_launch_rounded,
    Icons.diamond_rounded,
  ];
  static const faceColors = <Color>[
    Color(0xFFFFA85E),
    ArenaColors.gold,
    ArenaColors.success,
    ArenaColors.cyan,
    ArenaColors.playerTwo,
    Color(0xFF76B4FF),
  ];
  List<IconData> cards = [];
  Set<int> matched = {};
  List<int> flipped = [];
  final score = [0, 0];
  int turn = 1;
  bool busy = false;
  Timer? revealTimer;
  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    revealTimer?.cancel();
    cards = [...faces, ...faces]..shuffle(Random());
    matched = {};
    flipped = [];
    score.setAll(0, [0, 0]);
    turn = 1;
    busy = false;
  }

  void tap(int i) {
    if (busy || matched.contains(i) || flipped.contains(i)) return;
    GameAudioService.instance.play(GameSound.tap);
    setState(() {
      flipped.add(i);
      if (flipped.length == 2) {
        busy = true;
        final pair = List<int>.from(flipped);
        revealTimer = Timer(const Duration(milliseconds: 750), () {
          if (!mounted) return;
          setState(() {
            if (cards[pair[0]] == cards[pair[1]]) {
              matched.addAll(pair);
              score[turn - 1]++;
              GameAudioService.instance.play(GameSound.correct);
            } else {
              turn = 3 - turn;
              GameAudioService.instance.play(GameSound.incorrect);
            }
            flipped.clear();
            busy = false;
          });
          if (matched.length == cards.length && score[0] != score[1]) {
            _announceWinner(
              context,
              widget.players[score[0] > score[1] ? 0 : 1],
              'Memory Match',
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    revealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        _playersScore(widget.players, turn, scores: score),
        _resultText(
          matched.length == cards.length
              ? (score[0] == score[1]
                    ? 'Match tied!'
                    : '${widget.players[score[0] > score[1] ? 0 : 1]} wins!')
              : "${widget.players[turn - 1]}'s turn",
          color: turn == 1 ? _red : _blue,
        ),
        Expanded(
          child: Center(
            child: GridView.builder(
              itemCount: cards.length,
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.25,
              ),
              itemBuilder: (context, i) {
                final open = matched.contains(i) || flipped.contains(i);
                final faceIndex = faces.indexOf(cards[i]);
                final faceColor = faceColors[faceIndex];
                return Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: matched.length == cards.length ? null : () => tap(i),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        gradient: open
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  faceColor.withValues(alpha: .2),
                                  ArenaColors.surfaceRaised,
                                ],
                              )
                            : const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF1B2B4B),
                                  ArenaColors.surface,
                                ],
                              ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: matched.contains(i)
                              ? ArenaColors.success
                              : open
                              ? faceColor.withValues(alpha: .72)
                              : ArenaColors.border,
                          width: matched.contains(i) ? 1.7 : 1,
                        ),
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: open
                              ? Icon(
                                  cards[i],
                                  key: ValueKey(cards[i]),
                                  size: 32,
                                  color: faceColor,
                                )
                              : const Icon(
                                  Icons.auto_awesome_rounded,
                                  key: ValueKey('card-back'),
                                  size: 24,
                                  color: ArenaColors.textMuted,
                                ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        _actionButton('Restart Match', () => setState(_newGame)),
      ],
    ),
  );
}

class _NumberDuel extends StatefulWidget {
  const _NumberDuel({required this.players});
  final List<String> players;
  @override
  State<_NumberDuel> createState() => _NumberDuelState();
}

class _NumberDuelState extends State<_NumberDuel> {
  final minCtrl = TextEditingController(text: '1'),
      maxCtrl = TextEditingController(text: '100'),
      secretCtrl = TextEditingController(),
      guessCtrl = TextEditingController();
  int min = 1, max = 100, secret = 0, setter = 1, guesses = 0, round = 1;
  bool secretReady = false, guessing = false, roundOver = false;
  String hint = '';
  final score = [0, 0];

  Widget _duelPanel({
    required IconData icon,
    required String title,
    required String description,
    required Widget child,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [ArenaColors.surfaceRaised, ArenaColors.surface],
      ),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: ArenaColors.cyan.withValues(alpha: .3)),
      boxShadow: [
        BoxShadow(
          color: ArenaColors.primary.withValues(alpha: .12),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: ArenaColors.cyan.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: ArenaColors.cyan),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      color: ArenaColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        child,
      ],
    ),
  );
  @override
  void dispose() {
    minCtrl.dispose();
    maxCtrl.dispose();
    secretCtrl.dispose();
    guessCtrl.dispose();
    super.dispose();
  }

  void setSecret() {
    final low = int.tryParse(minCtrl.text) ?? 1,
        high = int.tryParse(maxCtrl.text) ?? 100,
        value = int.tryParse(secretCtrl.text);
    if (high <= low || value == null || value < low || value > high) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enter a secret between $low and $high; maximum must be higher.',
          ),
        ),
      );
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      min = low;
      max = high;
      secret = value;
      guesses = 0;
      secretReady = true;
      guessing = false;
      hint = '';
    });
  }

  // Player one is the initial setter; then roles alternate each round.
  int get guesser => 3 - setter;
  void submitGuess() {
    final value = int.tryParse(guessCtrl.text);
    if (value == null || value < min || value > max) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Guess a number from $min to $max.')),
      );
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      guesses++;
      if (value == secret) {
        score[guesser - 1]++;
        roundOver = true;
        hint =
            '${widget.players[guesser - 1]} found it in $guesses ${guesses == 1 ? 'guess' : 'guesses'}! The number was $secret.';
      } else {
        hint = value < secret ? 'Higher ↑' : 'Lower ↓';
      }
      guessCtrl.clear();
    });
    if (value == secret) {
      _announceWinner(context, widget.players[guesser - 1], 'Number Duel');
    }
  }

  void nextRound() => setState(() {
    setter = 3 - setter;
    round++;
    secretReady = false;
    guessing = false;
    roundOver = false;
    secretCtrl.clear();
    hint = '';
  });
  void reset() => setState(() {
    min = 1;
    max = 100;
    setter = 1;
    guesses = 0;
    round = 1;
    secretReady = false;
    guessing = false;
    roundOver = false;
    score.setAll(0, [0, 0]);
    hint = '';
    secretCtrl.clear();
    guessCtrl.clear();
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        _playersScore(
          widget.players,
          secretReady ? guesser : setter,
          scores: score,
        ),
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: (setter == 1 ? _red : _blue).withValues(alpha: .12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: (setter == 1 ? _red : _blue).withValues(alpha: .35),
            ),
          ),
          child: Text(
            'ROUND $round  ·  ${widget.players[setter - 1]} SETS THE NUMBER',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: setter == 1 ? _red : _blue,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: .5,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!secretReady)
                    _duelPanel(
                      icon: Icons.tune_rounded,
                      title: 'Set the challenge',
                      description: 'Choose a range and a secret number.',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: minCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Minimum',
                                    prefixIcon: Icon(Icons.south_rounded),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: maxCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Maximum',
                                    prefixIcon: Icon(Icons.north_rounded),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: secretCtrl,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Secret number',
                              helperText: 'Hidden until the round ends',
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: setSecret,
                              icon: const Icon(Icons.lock_rounded),
                              label: const Text('Lock Secret & Pass Device'),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (!guessing)
                    _duelPanel(
                      icon: Icons.phonelink_lock_rounded,
                      title: 'Pass the device',
                      description: 'The secret is safely locked away.',
                      child: Column(
                        children: [
                          const Icon(
                            Icons.visibility_off_rounded,
                            color: _gold,
                            size: 42,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Hand the phone to ${widget.players[guesser - 1]} when ready.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: ArenaColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => setState(() => guessing = true),
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: Text(
                                '${widget.players[guesser - 1]} is ready',
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (!roundOver)
                    _duelPanel(
                      icon: Icons.psychology_alt_rounded,
                      title: 'Make your guess',
                      description:
                          '${widget.players[guesser - 1]} · numbers $min to $max',
                      child: Column(
                        children: [
                          TextField(
                            controller: guessCtrl,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => submitGuess(),
                            decoration: const InputDecoration(
                              labelText: 'Enter your guess',
                              prefixIcon: Icon(Icons.numbers_rounded),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: submitGuess,
                              icon: const Icon(Icons.casino_rounded),
                              label: const Text('Submit Guess'),
                            ),
                          ),
                          if (hint.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ArenaColors.gold.withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: ArenaColors.gold.withValues(alpha: .3),
                                ),
                              ),
                              child: Text(
                                hint,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: _gold,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            '$guesses ${guesses == 1 ? 'guess' : 'guesses'} so far',
                            style: const TextStyle(
                              color: ArenaColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    _duelPanel(
                      icon: Icons.emoji_events_rounded,
                      title: 'Number found!',
                      description: 'Round $round complete',
                      child: Column(
                        children: [
                          Text(
                            hint,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: nextRound,
                              icon: const Icon(Icons.swap_horiz_rounded),
                              label: const Text('Next Round · Switch Roles'),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        _actionButton('Restart Match', reset),
      ],
    ),
  );
}

class _QuickTap extends StatefulWidget {
  const _QuickTap({required this.players});
  final List<String> players;
  @override
  State<_QuickTap> createState() => _QuickTapState();
}

class _QuickTapState extends State<_QuickTap> {
  final rng = Random();
  Timer? timer;
  Timer? signalTimer;
  bool waiting = false, go = false, ended = false;
  int countdown = 3, rounds = 0;
  final score = [0, 0];
  final history = <String>[];
  Stopwatch? watch;
  String message = 'Start a round when both players are ready.';
  void start() {
    timer?.cancel();
    signalTimer?.cancel();
    setState(() {
      waiting = true;
      go = false;
      ended = false;
      countdown = 3;
      message = 'Get ready…';
    });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        countdown--;
        if (countdown <= 0) {
          t.cancel();
          signalTimer = Timer(
            Duration(milliseconds: 900 + rng.nextInt(2600)),
            () {
              if (!mounted || ended) return;
              setState(() {
                waiting = false;
                go = true;
                watch = Stopwatch()..start();
                message = 'TAP NOW!';
              });
            },
          );
        }
      });
    });
  }

  void press(int player) {
    if (waiting) {
      GameAudioService.instance.play(GameSound.incorrect);
      timer?.cancel();
      signalTimer?.cancel();
      setState(() {
        waiting = false;
        ended = true;
        rounds++;
        score[2 - player]++;
        message =
            '${widget.players[player - 1]} tapped early! Point to ${widget.players[2 - player]}.';
        history.add(
          'Round $rounds: early tap by ${widget.players[player - 1]}',
        );
      });
      _announceWinner(
        context,
        widget.players[2 - player],
        'this reaction round',
      );
      return;
    }
    if (!go) return;
    GameAudioService.instance.play(GameSound.correct);
    watch!.stop();
    final ms = watch!.elapsedMilliseconds;
    setState(() {
      go = false;
      ended = true;
      rounds++;
      score[player - 1]++;
      message = '${widget.players[player - 1]} wins in ${ms}ms!';
      history.add('Round $rounds: ${widget.players[player - 1]} • ${ms}ms');
    });
    _announceWinner(context, widget.players[player - 1], 'this reaction round');
  }

  void reset() {
    timer?.cancel();
    signalTimer?.cancel();
    setState(() {
      waiting = false;
      go = false;
      ended = false;
      rounds = 0;
      score.setAll(0, [0, 0]);
      history.clear();
      message = 'Start a round when both players are ready.';
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    signalTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        _playersScore(widget.players, 0, scores: score),
        _resultText(message, color: go ? const Color(0xFF5BFFA6) : _gold),
        if (waiting || go)
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 124,
            height: 92,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: go
                    ? [Color(0xFF218A63), Color(0xFF123E40)]
                    : [ArenaColors.surfaceRaised, ArenaColors.surface],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: go
                    ? ArenaColors.success
                    : ArenaColors.cyan.withValues(alpha: .38),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (go ? ArenaColors.success : ArenaColors.cyan)
                      .withValues(alpha: .12),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  go
                      ? 'GO!'
                      : countdown > 0
                      ? '$countdown'
                      : '…',
                  key: ValueKey('$countdown-$go'),
                  style: TextStyle(
                    color: go ? Colors.white : ArenaColors.cyan,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          child: Row(
            children: [
              for (final p in [1, 2])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: GestureDetector(
                      onTap: () => press(p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        decoration: BoxDecoration(
                          color: go
                              ? const Color(0xFF24BA73)
                              : p == 1
                              ? _red.withValues(alpha: .25)
                              : _blue.withValues(alpha: .25),
                          border: Border.all(
                            color: p == 1 ? _red : _blue,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                size: 48,
                                color: p == 1 ? _red : _blue,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.players[p - 1],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                go ? 'TAP!' : 'Ready',
                                style: const TextStyle(color: Colors.white60),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (ended || (!waiting && !go))
          FilledButton(
            onPressed: start,
            child: Text(ended ? 'Next Reaction Round' : 'Start Round'),
          ),
        if (history.isNotEmpty)
          SizedBox(
            height: 55,
            child: ListView(
              children: history.reversed
                  .take(3)
                  .map(
                    (e) => Text(
                      e,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white60),
                    ),
                  )
                  .toList(),
            ),
          ),
        _actionButton('Restart Match', reset),
      ],
    ),
  );
}

class _TakeMoveButton extends StatelessWidget {
  const _TakeMoveButton({
    required this.amount,
    required this.enabled,
    required this.onTap,
  });
  final int amount;
  final bool enabled;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: enabled ? ArenaColors.surfaceRaised : ArenaColors.surface,
    borderRadius: BorderRadius.circular(ArenaRadii.control),
    child: InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(ArenaRadii.control),
      child: Container(
        constraints: const BoxConstraints(minWidth: 78, minHeight: 68),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ArenaRadii.control),
          border: Border.all(
            color: enabled
                ? ArenaColors.cyan.withValues(alpha: .5)
                : ArenaColors.border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$amount',
              style: TextStyle(
                color: enabled ? ArenaColors.cyan : ArenaColors.textMuted,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'TAKE',
              style: TextStyle(
                color: enabled ? Colors.white70 : ArenaColors.textMuted,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: .8,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Nim extends StatefulWidget {
  const _Nim({required this.players});
  final List<String> players;
  @override
  State<_Nim> createState() => _NimState();
}

class _NimState extends State<_Nim> {
  int size = 21;
  late NimState game = NimState(startingPile: size);
  void chooseSize(int value) => setState(() {
    size = value;
    game = NimState(startingPile: size);
  });
  void reset() => setState(() => game = NimState(startingPile: size));
  void take(int amount) {
    if (!game.take(amount)) {
      GameAudioService.instance.play(GameSound.incorrect);
      return;
    }
    GameAudioService.instance.play(GameSound.selection);
    setState(() {});
    if (game.winner != 0) {
      _announceWinner(
        context,
        widget.players[game.winner - 1],
        'Stick Takeaway',
      );
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        _playersScore(widget.players, game.currentPlayer),
        if (game.pile == size && game.winner == 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Pile: '),
              DropdownButton<int>(
                value: size,
                items: [15, 21, 25, 30]
                    .map(
                      (n) =>
                          DropdownMenuItem(value: n, child: Text('$n sticks')),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) chooseSize(v);
                },
              ),
            ],
          ),
        _resultText(
          game.winner != 0
              ? '${widget.players[game.winner - 1]} wins! Last stick taken.'
              : "${widget.players[game.currentPlayer - 1]}'s turn  •  take 1–3",
          color: game.currentPlayer == 1 ? _red : _blue,
        ),
        Expanded(
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 5,
              children: List.generate(
                game.pile,
                (i) => Container(
                  width: 14,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFB7F3FF),
                        Color(0xFF3D9BCB),
                        Color(0xFF247093),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ArenaColors.cyan.withValues(alpha: .16),
                        blurRadius: 7,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [1, 2, 3]
              .map(
                (n) => Padding(
                  padding: const EdgeInsets.all(5),
                  child: _TakeMoveButton(
                    amount: n,
                    enabled: game.winner == 0 && n <= game.pile,
                    onTap: () => take(n),
                  ),
                ),
              )
              .toList(),
        ),
        const Text(
          'Take turns removing 1, 2, or 3 sticks. The player who takes the last stick wins.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, fontSize: 12),
        ),
        const SizedBox(height: 8),
        _actionButton('Play Again', reset),
      ],
    ),
  );
}
