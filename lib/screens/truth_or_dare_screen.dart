import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/game_arena_theme.dart';

enum _SpinMode { bottle, arrow }

enum _Difficulty { easy, medium, spicy }

enum _ChallengeKind { truth, dare }

class _Prompt {
  const _Prompt(this.text, this.level);
  final String text;
  final _Difficulty level;
}

const _truths = <_Prompt>[
  _Prompt(
    'What is the funniest thing you believed as a little kid?',
    _Difficulty.easy,
  ),
  _Prompt('What song do you secretly know every word to?', _Difficulty.easy),
  _Prompt('What is your most unusual snack combination?', _Difficulty.easy),
  _Prompt('Which emoji do you use the most?', _Difficulty.easy),
  _Prompt(
    'What is the silliest thing that always makes you laugh?',
    _Difficulty.easy,
  ),
  _Prompt('What is a small talent you are proud of?', _Difficulty.easy),
  _Prompt(
    'If you could instantly learn a hobby, what would you pick?',
    _Difficulty.easy,
  ),
  _Prompt(
    'What is the most memorable gift you have received?',
    _Difficulty.easy,
  ),
  _Prompt('What fictional place would you visit for a day?', _Difficulty.easy),
  _Prompt('What is your funniest harmless mishap?', _Difficulty.easy),
  _Prompt(
    'What is something you were nervous to try but ended up liking?',
    _Difficulty.medium,
  ),
  _Prompt(
    'What is a kind thing someone did that you still remember?',
    _Difficulty.medium,
  ),
  _Prompt('What is one thing you wish you were better at?', _Difficulty.medium),
  _Prompt(
    'What is the most spontaneous fun thing you have done?',
    _Difficulty.medium,
  ),
  _Prompt(
    'Which of your friends would survive longest on a deserted island, and why?',
    _Difficulty.medium,
  ),
  _Prompt('What is a goal you hope to reach this year?', _Difficulty.medium),
  _Prompt(
    'What is one thing people often misunderstand about you?',
    _Difficulty.medium,
  ),
  _Prompt(
    'What is your most embarrassing (but funny) autocorrect moment?',
    _Difficulty.medium,
  ),
  _Prompt('What is a silly fear you have?', _Difficulty.medium),
  _Prompt('What is a compliment you still remember?', _Difficulty.medium),
  _Prompt(
    'What is the goofiest thing you have done to impress someone?',
    _Difficulty.spicy,
  ),
  _Prompt(
    'What is a harmless secret talent you have never shown this group?',
    _Difficulty.spicy,
  ),
  _Prompt(
    'If this group had a reality show, what would it be called?',
    _Difficulty.spicy,
  ),
  _Prompt(
    'Who here would you choose as your teammate for a talent show?',
    _Difficulty.spicy,
  ),
  _Prompt('What is the boldest outfit you have ever worn?', _Difficulty.spicy),
  _Prompt(
    'What is a funny excuse you have used to get out of a plan?',
    _Difficulty.spicy,
  ),
  _Prompt('Which person here makes you laugh the most?', _Difficulty.spicy),
  _Prompt(
    'What is your most dramatic overreaction to something tiny?',
    _Difficulty.spicy,
  ),
  _Prompt('What is the strangest dream you can remember?', _Difficulty.spicy),
  _Prompt(
    'What is one playful challenge you would give the whole group?',
    _Difficulty.spicy,
  ),
];

const _dares = <_Prompt>[
  _Prompt('Do your best robot dance for ten seconds.', _Difficulty.easy),
  _Prompt(
    'Speak in a cheerful announcer voice until your next turn.',
    _Difficulty.easy,
  ),
  _Prompt(
    'Make up a two-line song about the person on your left.',
    _Difficulty.easy,
  ),
  _Prompt(
    'Balance a small, safe object on your head for ten seconds.',
    _Difficulty.easy,
  ),
  _Prompt('Give everyone a high-five or a friendly wave.', _Difficulty.easy),
  _Prompt(
    'Make three different animal sounds and let the group guess.',
    _Difficulty.easy,
  ),
  _Prompt('Do your best movie hero pose.', _Difficulty.easy),
  _Prompt(
    'Say the alphabet backwards as far as you can in 15 seconds.',
    _Difficulty.easy,
  ),
  _Prompt('Walk across the room like you are on the moon.', _Difficulty.easy),
  _Prompt(
    'Invent a new handshake with the player next to you.',
    _Difficulty.easy,
  ),
  _Prompt(
    'Tell a short story using the words pizza, rocket, and penguin.',
    _Difficulty.medium,
  ),
  _Prompt(
    'Do a dramatic reading of the last message you sent (skip anything private).',
    _Difficulty.medium,
  ),
  _Prompt('Try to make the group laugh in 20 seconds.', _Difficulty.medium),
  _Prompt('Act out a well-known movie without speaking.', _Difficulty.medium),
  _Prompt(
    'Let the group choose a fun pose for you to hold for ten seconds.',
    _Difficulty.medium,
  ),
  _Prompt('Name five things that are blue in 10 seconds.', _Difficulty.medium),
  _Prompt(
    'Do a slow-motion celebration as if you just won a trophy.',
    _Difficulty.medium,
  ),
  _Prompt(
    'Speak with a gentle accent of your choice for one round.',
    _Difficulty.medium,
  ),
  _Prompt('Make up a slogan for this group.', _Difficulty.medium),
  _Prompt(
    'Pretend to host a cooking show about making a sandwich.',
    _Difficulty.medium,
  ),
  _Prompt(
    'Perform a tiny victory dance chosen by the group.',
    _Difficulty.spicy,
  ),
  _Prompt(
    'Imitate a famous character and let the group guess who it is.',
    _Difficulty.spicy,
  ),
  _Prompt(
    'Give a 15-second motivational speech about getting out of bed.',
    _Difficulty.spicy,
  ),
  _Prompt(
    'Do your best runway walk across the room and back.',
    _Difficulty.spicy,
  ),
  _Prompt(
    'Make up a quick rap that includes three player names.',
    _Difficulty.spicy,
  ),
  _Prompt(
    'Let the group pick a tongue twister for you to try three times.',
    _Difficulty.spicy,
  ),
  _Prompt(
    'Describe your day like a sports commentator for 20 seconds.',
    _Difficulty.spicy,
  ),
  _Prompt('Do an imaginary instrument solo for 15 seconds.', _Difficulty.spicy),
  _Prompt(
    'Act like a friendly news reporter covering this game.',
    _Difficulty.spicy,
  ),
  _Prompt(
    'Invent a silly award and present it to someone in the group.',
    _Difficulty.spicy,
  ),
];

class TruthOrDareScreen extends StatefulWidget {
  const TruthOrDareScreen({super.key});

  @override
  State<TruthOrDareScreen> createState() => _TruthOrDareScreenState();
}

class _TruthOrDareScreenState extends State<TruthOrDareScreen> {
  final _random = Random();
  final _controllers = <TextEditingController>[
    TextEditingController(text: 'Player 1'),
    TextEditingController(text: 'Player 2'),
  ];
  final _history = <String>[];
  _SpinMode _mode = _SpinMode.bottle;
  _Difficulty _difficulty = _Difficulty.easy;
  int? _selected;
  int? _lastSelected;
  int _turns = 0;
  int _round = 1;
  int _rotation = 0;
  bool _spinning = false;
  bool _started = false;
  bool _finished = false;
  _ChallengeKind? _kind;
  _Prompt? _challenge;
  Set<int> _roundPlayers = <int>{};

  List<String> get _players => _controllers.map((c) => c.text.trim()).toList();
  int get _playerCount => _controllers.length;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPlayer() {
    if (_controllers.length >= 20) return;
    setState(
      () => _controllers.add(
        TextEditingController(text: 'Player ${_controllers.length + 1}'),
      ),
    );
  }

  void _removePlayer(int index) {
    if (_controllers.length <= 2) return;
    setState(() => _controllers.removeAt(index).dispose());
  }

  bool _validate() {
    final names = _players;
    if (names.any((name) => name.isEmpty)) {
      _notice('Please enter a name for every player.');
      return false;
    }
    if (names.map((name) => name.toLowerCase()).toSet().length !=
        names.length) {
      _notice('Player names must be unique.');
      return false;
    }
    return true;
  }

  void _notice(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _exit() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ArenaColors.surfaceRaised,
        title: const Text('Exit Truth or Dare?'),
        content: const Text('Your current game and history will end.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep playing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.pop(context);
  }

  void _start() {
    if (!_validate()) return;
    setState(() {
      _selected = null;
      _lastSelected = null;
      _history.clear();
      _turns = 0;
      _round = 1;
      _roundPlayers = <int>{};
      _finished = false;
      _started = true;
      _kind = null;
      _challenge = null;
    });
  }

  void _spin() {
    if (_spinning || _finished) return;
    var choices = List<int>.generate(_playerCount, (index) => index);
    if (_lastSelected != null && choices.length > 1) {
      choices.remove(_lastSelected);
    }
    final winner = choices[_random.nextInt(choices.length)];
    final turns = 5 + _random.nextInt(4);
    setState(() {
      _spinning = true;
      _selected = null;
      _kind = null;
      _challenge = null;
      _rotation += turns * _playerCount + winner;
    });
    Timer(const Duration(milliseconds: 1750), () {
      if (!mounted) return;
      setState(() {
        _spinning = false;
        _selected = winner;
        _lastSelected = winner;
        _roundPlayers.add(winner);
      });
    });
  }

  void _choose(_ChallengeKind kind) {
    final pool = [..._truths, ..._dares]
        .where(
          (prompt) =>
              prompt.level == _difficulty &&
              (kind == _ChallengeKind.truth
                  ? _truths.contains(prompt)
                  : _dares.contains(prompt)),
        )
        .toList();
    setState(() {
      _kind = kind;
      _challenge = pool[_random.nextInt(pool.length)];
    });
  }

  void _another() {
    final kind = _kind;
    if (kind != null) _choose(kind);
  }

  void _complete({required bool skipped}) {
    if (_selected == null || _challenge == null || _kind == null) return;
    final player = _players[_selected!];
    final label = _kind == _ChallengeKind.truth ? 'Truth' : 'Dare';
    setState(() {
      _history.insert(
        0,
        'Round $_round · $player · $label · ${skipped ? 'Skipped' : 'Completed'}: ${_challenge!.text}',
      );
      _turns++;
      _selected = null;
      _kind = null;
      _challenge = null;
      if (_roundPlayers.length >= _playerCount) {
        _round++;
        _roundPlayers = <int>{};
      }
      if (_turns >= _playerCount * 3) _finished = true;
    });
  }

  void _restart() {
    setState(() {
      _history.clear();
      _turns = 0;
      _round = 1;
      _roundPlayers = <int>{};
      _lastSelected = null;
      _selected = null;
      _kind = null;
      _challenge = null;
      _finished = false;
      _started = true;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ArenaColors.background,
    appBar: AppBar(
      title: const Text('Truth or Dare'),
      centerTitle: true,
      leading: IconButton(
        onPressed: _exit,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      actions: [
        IconButton(
          tooltip: 'Restart game',
          onPressed: _restart,
          icon: const Icon(Icons.restart_alt_rounded),
        ),
      ],
    ),
    body: Stack(
      children: [
        const Positioned.fill(
          child: Image(
            image: AssetImage('assets/images/truth_dare/bg_truthdare.png'),
            fit: BoxFit.cover,
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xC4071230),
                  Color(0xA6071230),
                  Color(0xE6071230),
                ],
              ),
            ),
          ),
        ),
        const Positioned(
          top: -90,
          right: -120,
          child: _Glow(size: 270, color: ArenaColors.purple),
        ),
        SafeArea(
          child: _finished
              ? _results()
              : _selected == null
              ? _setupOrSpinner()
              : _turn(),
        ),
      ],
    ),
  );

  Widget _setupOrSpinner() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [if (!_started) ..._setup() else ..._spinner()],
        ),
      ),
    ),
  );

  List<Widget> _setup() => [
    const _TitleBlock(
      kicker: 'PASS & PLAY',
      title: 'Make it a good one',
      subtitle: 'Add 2–20 players, choose a spinner, then take turns together.',
    ),
    const SizedBox(height: 18),
    _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('PLAYERS', style: _eyebrow)),
              Text(
                '$_playerCount / 20',
                style: const TextStyle(
                  color: ArenaColors.cyan,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(
            _controllers.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controllers[index],
                      textCapitalization: TextCapitalization.words,
                      maxLength: 24,
                      decoration: InputDecoration(
                        counterText: '',
                        labelText: 'Player ${index + 1}',
                        prefixIcon: Icon(
                          Icons.person_rounded,
                          color: index.isEven
                              ? ArenaColors.cyan
                              : ArenaColors.playerTwo,
                        ),
                      ),
                    ),
                  ),
                  if (_controllers.length > 2)
                    IconButton(
                      tooltip: 'Remove player',
                      onPressed: () => _removePlayer(index),
                      icon: const Icon(
                        Icons.remove_circle_outline_rounded,
                        color: Colors.white54,
                      ),
                    ),
                ],
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: _playerCount < 20 ? _addPlayer : null,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Add player'),
          ),
        ],
      ),
    ),
    const SizedBox(height: 14),
    _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CHOOSE YOUR SPINNER', style: _eyebrow),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _modeButton(
                  _SpinMode.bottle,
                  Icons.local_drink_rounded,
                  'Spin the Bottle',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _modeButton(
                  _SpinMode.arrow,
                  Icons.navigation_rounded,
                  'Random Arrow',
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),
    FilledButton.icon(
      onPressed: _start,
      icon: const Icon(Icons.play_arrow_rounded),
      label: const Text('Start game'),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        backgroundColor: const Color(0xFFFF718C),
      ),
    ),
  ];

  List<Widget> _spinner() => [
    _TitleBlock(
      kicker: 'ROUND $_round  ·  TURN ${_turns + 1}',
      title: 'Who goes next?',
      subtitle: _spinning
          ? 'The ${_mode == _SpinMode.bottle ? 'bottle' : 'arrow'} is spinning…'
          : 'Pass the device around, then spin.',
    ),
    const SizedBox(height: 20),
    _panel(
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ArenaColors.surfaceRaised,
                    border: Border.all(color: ArenaColors.border, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: ArenaColors.purple.withValues(alpha: .15),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                ),
                for (var i = 0; i < _playerCount; i++) _playerDot(i),
                AnimatedRotation(
                  turns: _rotation.toDouble(),
                  duration: const Duration(milliseconds: 1650),
                  curve: Curves.easeOutCubic,
                  child: _mode == _SpinMode.bottle
                      ? Image.asset(
                          'assets/images/truth_dare/bottle_spin.png',
                          width: 74,
                          height: 112,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        )
                      : const Icon(
                          Icons.navigation_rounded,
                          size: 64,
                          color: Color(0xFFFF718C),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          if (_selected != null)
            Text(
              '${_players[_selected!]} is up!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
                color: ArenaColors.gold,
              ),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _spinning || _selected != null ? null : _spin,
            icon: Icon(
              _mode == _SpinMode.bottle
                  ? Icons.local_drink_rounded
                  : Icons.navigation_rounded,
            ),
            label: Text(
              _spinning
                  ? 'Spinning…'
                  : _selected == null
                  ? 'Spin to choose'
                  : 'Player selected',
            ),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
          ),
          if (_selected != null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Choose your challenge below.',
                style: TextStyle(color: ArenaColors.textMuted),
              ),
            ),
        ],
      ),
    ),
    if (_selected != null) ...[
      const SizedBox(height: 14),
      _panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PICK A CHALLENGE', style: _eyebrow),
            const SizedBox(height: 10),
            SegmentedButton<_Difficulty>(
              segments: const [
                ButtonSegment(value: _Difficulty.easy, label: Text('Easy')),
                ButtonSegment(value: _Difficulty.medium, label: Text('Medium')),
                ButtonSegment(value: _Difficulty.spicy, label: Text('Spicy')),
              ],
              selected: {_difficulty},
              onSelectionChanged: (value) =>
                  setState(() => _difficulty = value.first),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _kindButton(_ChallengeKind.truth)),
                const SizedBox(width: 10),
                Expanded(child: _kindButton(_ChallengeKind.dare)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  final options = [_ChallengeKind.truth, _ChallengeKind.dare];
                  _choose(options[_random.nextInt(2)]);
                },
                icon: const Icon(Icons.shuffle_rounded),
                label: const Text('Random'),
              ),
            ),
            if (_challenge != null) ...[
              const SizedBox(height: 14),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Container(
                  key: ValueKey(_challenge!.text),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ArenaColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _kind == _ChallengeKind.truth
                          ? ArenaColors.cyan
                          : const Color(0xFFFF718C),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_kind == _ChallengeKind.truth ? 'TRUTH' : 'DARE'}  ·  ${_difficulty.name.toUpperCase()}',
                        style: _eyebrow,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _challenge!.text,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _another,
                      child: const Text('Get another'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _complete(skipped: true),
                      child: const Text('Skip'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _complete(skipped: false),
                      child: const Text('Complete'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ],
    const SizedBox(height: 16),
    _historyPanel(),
  ];

  Widget _turn() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _spinner(),
        ),
      ),
    ),
  );

  Widget _results() => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          children: [
            const Icon(
              Icons.celebration_rounded,
              size: 72,
              color: ArenaColors.gold,
            ),
            const SizedBox(height: 12),
            const Text(
              'That’s a wrap!',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              '$_turns turns · ${_round - 1} rounds · ${_players.length} players',
              style: const TextStyle(color: ArenaColors.textMuted),
            ),
            const SizedBox(height: 18),
            _historyPanel(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _exit,
                    icon: const Icon(Icons.exit_to_app_rounded),
                    label: const Text('Exit'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _restart,
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Play again'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _historyPanel() => _panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: Text('CHALLENGE HISTORY', style: _eyebrow)),
            Text(
              '$_turns turns',
              style: const TextStyle(
                color: ArenaColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        if (_history.isEmpty)
          const Text(
            'Completed and skipped challenges will show here.',
            style: TextStyle(color: ArenaColors.textMuted, fontSize: 12),
          )
        else
          ..._history
              .take(12)
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 16,
                        color: ArenaColors.success,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.3,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    ),
  );

  Widget _playerDot(int index) {
    final angle = -pi / 2 + 2 * pi * index / _playerCount;
    final active = _selected == index;
    return Transform.translate(
      offset: Offset(cos(angle) * 86, sin(angle) * 86),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: active ? 42 : 34,
        height: active ? 42 : 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? ArenaColors.gold
              : index.isEven
              ? ArenaColors.primary
              : ArenaColors.purple,
          border: Border.all(color: ArenaColors.background, width: 3),
        ),
        child: Text(
          _players[index].characters.first.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: ArenaColors.background,
          ),
        ),
      ),
    );
  }

  Widget _modeButton(_SpinMode mode, IconData icon, String label) {
    final active = _mode == mode;
    return InkWell(
      onTap: () => setState(() => _mode = mode),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        decoration: BoxDecoration(
          color: active
              ? ArenaColors.purple.withValues(alpha: .18)
              : ArenaColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? ArenaColors.purple : ArenaColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: active ? ArenaColors.purple : ArenaColors.textMuted,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: active ? Colors.white : ArenaColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kindButton(_ChallengeKind kind) {
    final truth = kind == _ChallengeKind.truth;
    return FilledButton.icon(
      onPressed: () => _choose(kind),
      icon: Icon(truth ? Icons.chat_bubble_rounded : Icons.bolt_rounded),
      label: Text(truth ? 'Truth' : 'Dare'),
      style: FilledButton.styleFrom(
        backgroundColor: truth
            ? const Color(0xFF16778B)
            : const Color(0xFFB74162),
        minimumSize: const Size(0, 46),
      ),
    );
  }

  Widget _panel({required Widget child}) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: ArenaColors.surface.withValues(alpha: .97),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: ArenaColors.border),
    ),
    child: child,
  );
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({
    required this.kicker,
    required this.title,
    required this.subtitle,
  });
  final String kicker, title, subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        kicker,
        style: const TextStyle(
          color: ArenaColors.cyan,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        title,
        style: const TextStyle(
          fontSize: 27,
          height: 1.1,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        subtitle,
        style: const TextStyle(
          color: ArenaColors.textMuted,
          fontSize: 13,
          height: 1.35,
        ),
      ),
    ],
  );
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});
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
          colors: [color.withValues(alpha: .13), Colors.transparent],
        ),
      ),
    ),
  );
}

const _eyebrow = TextStyle(
  color: ArenaColors.textMuted,
  fontSize: 10,
  fontWeight: FontWeight.w900,
  letterSpacing: 1.1,
);
