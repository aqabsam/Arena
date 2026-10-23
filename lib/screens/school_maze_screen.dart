import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../audio/game_audio_service.dart';
import '../theme/game_arena_theme.dart';

enum MazeLevel { easy, medium, hard, expert }

enum _MazePhase { setup, countdown, playing, legDone, results }

class _MazeMap {
  _MazeMap(this.size, this.cells, this.checkpoints, this.obstacles);
  final int size;
  final List<bool> cells;
  final Set<int> checkpoints;
  final Set<int> obstacles;
  int get start => size + 1;
  int get home => size * size - size - 2;
  bool open(int cell) => cell >= 0 && cell < cells.length && cells[cell];
}

class SchoolMazeScreen extends StatefulWidget {
  const SchoolMazeScreen({super.key});
  @override
  State<SchoolMazeScreen> createState() => _SchoolMazeScreenState();
}

class _SchoolMazeScreenState extends State<SchoolMazeScreen> {
  static const _sizes = [7, 9, 11, 13];
  final _random = Random();
  final _names = [
    TextEditingController(text: 'Player 1'),
    TextEditingController(text: 'Player 2'),
  ];
  MazeLevel _level = MazeLevel.easy;
  _MazePhase _phase = _MazePhase.setup;
  _MazeMap? _maze;
  int _levelIndex = 0;
  int _playerIndex = 0;
  int _position = 0;
  int _moves = 0;
  int _countdown = 3;
  bool _race = false;
  bool _sound = true;
  Timer? _timer;
  Stopwatch _stopwatch = Stopwatch();
  Duration _elapsed = Duration.zero;
  final _times = <String, Duration>{};
  final _visitedCheckpoints = <int>{};
  int _bestSeconds = 0;
  int _penaltySeconds = 0;

  List<String> get _players => _names.map((e) => e.text.trim()).toList();
  int get _playerCount => _race ? _names.length : 1;

  @override
  void initState() {
    super.initState();
    _loadBest();
  }

  Future<void> _loadBest() async {
    final level = _level;
    final prefs = await SharedPreferences.getInstance();
    if (mounted && _level == level) {
      setState(
        () => _bestSeconds = prefs.getInt('maze_best_${level.name}') ?? 0,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final name in _names) {
      name.dispose();
    }
    super.dispose();
  }

  void _playSound(GameSound sound) {
    if (_sound) GameAudioService.instance.play(sound);
  }

  _MazeMap _generate(int size) {
    final cells = List<bool>.filled(size * size, false);
    int idx(int row, int col) => row * size + col;
    final stack = <(int, int)>[(1, 1)];
    cells[idx(1, 1)] = true;
    while (stack.isNotEmpty) {
      final (r, c) = stack.last;
      final options = <(int, int)>[];
      for (final (dr, dc) in const <(int, int)>[
        (0, 2),
        (0, -2),
        (2, 0),
        (-2, 0),
      ]) {
        final nr = r + dr, nc = c + dc;
        if (nr > 0 &&
            nc > 0 &&
            nr < size - 1 &&
            nc < size - 1 &&
            !cells[idx(nr, nc)]) {
          options.add((nr, nc));
        }
      }
      if (options.isEmpty) {
        stack.removeLast();
      } else {
        final next = options[_random.nextInt(options.length)];
        cells[idx((r + next.$1) ~/ 2, (c + next.$2) ~/ 2)] = true;
        cells[idx(next.$1, next.$2)] = true;
        stack.add(next);
      }
    }
    final start = idx(1, 1), home = idx(size - 2, size - 2);
    cells[start] = true;
    cells[home] = true;
    final openCells = <int>[];
    for (var i = 0; i < cells.length; i++) {
      if (cells[i] && i != start && i != home) openCells.add(i);
    }
    openCells.shuffle(_random);
    final checkpoints = openCells.take(2).toSet();
    final obstacles = openCells.skip(2).take(max(1, size ~/ 4)).toSet();
    return _MazeMap(size, cells, checkpoints, obstacles);
  }

  bool _validNames() {
    final names = _players.take(_playerCount).toList();
    if (names.any((name) => name.isEmpty)) {
      _toast('Enter a name for each racer.');
      return false;
    }
    if (names.map((e) => e.toLowerCase()).toSet().length != names.length) {
      _toast('Racer names must be unique.');
      return false;
    }
    return true;
  }

  void _beginGame() {
    if (!_validNames()) return;
    setState(() {
      _levelIndex = _level.index;
      _playerIndex = 0;
      _times.clear();
      _startLeg(newMaze: true);
    });
  }

  void _startLeg({required bool newMaze}) {
    _timer?.cancel();
    if (newMaze || _maze == null) _maze = _generate(_sizes[_levelIndex]);
    _position = _maze!.start;
    _moves = 0;
    _elapsed = Duration.zero;
    _penaltySeconds = 0;
    _visitedCheckpoints.clear();
    _stopwatch = Stopwatch();
    _countdown = 3;
    _phase = _MazePhase.countdown;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          timer.cancel();
          _phase = _MazePhase.playing;
          _stopwatch.start();
          _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
            if (mounted && _phase == _MazePhase.playing) {
              setState(
                () => _elapsed =
                    _stopwatch.elapsed + Duration(seconds: _penaltySeconds),
              );
            }
          });
        }
      });
    });
  }

  void _move(int dr, int dc) {
    if (_phase != _MazePhase.playing || _maze == null) return;
    final size = _maze!.size;
    final row = _position ~/ size + dr, col = _position % size + dc;
    if (row < 0 || col < 0 || row >= size || col >= size) return;
    final target = row * size + col;
    if (!_maze!.open(target)) {
      _playSound(GameSound.incorrect);
      return;
    }
    setState(() {
      _position = target;
      _moves++;
      if (_maze!.checkpoints.contains(target)) _visitedCheckpoints.add(target);
      if (_maze!.obstacles.contains(target)) _penaltySeconds += 2;
    });
    _playSound(GameSound.tap);
    if (target == _maze!.home) _finishLeg();
  }

  void _finishLeg() {
    _timer?.cancel();
    _stopwatch.stop();
    _elapsed = _stopwatch.elapsed + Duration(seconds: _penaltySeconds);
    final name = _players[_playerIndex];
    _times[name] = _elapsed;
    _playSound(GameSound.correct);
    if (!_race) {
      final isLast = _levelIndex == MazeLevel.values.length - 1;
      setState(() => _phase = isLast ? _MazePhase.results : _MazePhase.legDone);
      _saveBest();
    } else if (_playerIndex + 1 < _playerCount) {
      setState(() => _phase = _MazePhase.legDone);
    } else {
      setState(() => _phase = _MazePhase.results);
    }
  }

  Future<void> _saveBest() async {
    final level = MazeLevel.values[_levelIndex];
    final seconds = _elapsed.inSeconds;
    final prefs = await SharedPreferences.getInstance();
    final key = 'maze_best_${level.name}';
    final previous = prefs.getInt(key) ?? 0;
    if (previous != 0 && seconds >= previous) return;
    await prefs.setInt(key, seconds);
    if (mounted && MazeLevel.values[_levelIndex] == level) {
      setState(() => _bestSeconds = seconds);
    }
  }

  void _next() {
    if (_race) {
      setState(() {
        _playerIndex++;
        _startLeg(newMaze: false);
      });
      return;
    }
    setState(() {
      _levelIndex++;
      _level = MazeLevel.values[_levelIndex];
      _loadBest();
      _startLeg(newMaze: true);
    });
  }

  void _restart() {
    if (_phase == _MazePhase.setup) {
      _beginGame();
    } else {
      setState(() {
        if (_race) {
          _playerIndex = 0;
          _times.clear();
        }
        _startLeg(newMaze: true);
      });
    }
  }

  void _toast(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW) {
      _move(-1, 0);
    } else if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.keyS) {
      _move(1, 0);
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.keyA) {
      _move(0, -1);
    } else if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.keyD) {
      _move(0, 1);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ArenaColors.background,
    appBar: AppBar(
      title: const Text(
        'School-to-Home Maze Race',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      actions: [
        IconButton(
          tooltip: _sound ? 'Mute game sounds' : 'Enable game sounds',
          onPressed: () => setState(() => _sound = !_sound),
          icon: Icon(
            _sound ? Icons.volume_up_rounded : Icons.volume_off_rounded,
          ),
        ),
        IconButton(
          tooltip: 'Restart',
          onPressed: _restart,
          icon: const Icon(Icons.restart_alt_rounded),
        ),
      ],
    ),
    body: SafeArea(
      child: _phase == _MazePhase.setup
          ? _setup()
          : _phase == _MazePhase.results
          ? _results()
          : _game(),
    ),
  );

  Widget _setup() => SingleChildScrollView(
    padding: const EdgeInsets.all(18),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Heading(
              'SCHOOL → HOME',
              'Find your way home!',
              'Navigate checkpoints, avoid detours, and race the clock.',
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _box(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SELECT LEVEL', style: _label),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: MazeLevel.values
                        .map(
                          (level) => ChoiceChip(
                            label: Text(level.name.toUpperCase()),
                            selected: _level == level,
                            onSelected: (_) => setState(() {
                              _level = level;
                              _loadBest();
                            }),
                            selectedColor: ArenaColors.success,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${_sizes[_level.index]} × ${_sizes[_level.index]} maze · Best: ${_bestSeconds == 0 ? '—' : '${_bestSeconds}s'}',
                    style: const TextStyle(
                      color: ArenaColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _box(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Local multiplayer race'),
                      subtitle: const Text(
                        'Take turns on the same maze; fastest time wins.',
                      ),
                      value: _race,
                      onChanged: (value) => setState(() => _race = value),
                    ),
                  ),
                  if (_race)
                    ..._names.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TextField(
                          controller: entry.value,
                          maxLength: 20,
                          decoration: InputDecoration(
                            counterText: '',
                            labelText: 'Racer ${entry.key + 1}',
                            prefixIcon: const Icon(Icons.person_rounded),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const _Legend(),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _beginGame,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(_race ? 'Start race' : 'Start adventure'),
              style: FilledButton.styleFrom(
                backgroundColor: ArenaColors.success,
                foregroundColor: ArenaColors.background,
                minimumSize: const Size(0, 52),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _game() => LayoutBuilder(
    builder: (context, constraints) {
      final maze = _maze!;
      final width = min(constraints.maxWidth - 24, 500.0);
      return Focus(
        autofocus: true,
        onKeyEvent: _onKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _race
                              ? '${_players[_playerIndex]}’s race'
                              : 'LEVEL ${_levelIndex + 1} · ${MazeLevel.values[_levelIndex].name.toUpperCase()}',
                          style: const TextStyle(
                            color: ArenaColors.cyan,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Text(
                        _format(_elapsed),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: ArenaColors.gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _stat('MOVES', '$_moves')),
                      Expanded(
                        child: _stat(
                          'CHECKPOINTS',
                          '${_visitedCheckpoints.length}/${maze.checkpoints.length}',
                        ),
                      ),
                      Expanded(child: _stat('LEVEL', '${_levelIndex + 1}/4')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_phase == _MazePhase.countdown)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: _box(),
                      child: Text(
                        'Get ready… $_countdown',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          color: ArenaColors.gold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Center(
                    child: GestureDetector(
                      onPanEnd: (details) {
                        final velocity = details.velocity.pixelsPerSecond;
                        if (velocity.distance < 120) return;
                        if (velocity.dx.abs() > velocity.dy.abs()) {
                          _move(0, velocity.dx > 0 ? 1 : -1);
                        } else {
                          _move(velocity.dy > 0 ? 1 : -1, 0);
                        }
                      },
                      child: SizedBox(
                        width: width,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: maze.cells.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: maze.size,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 2,
                                ),
                            itemBuilder: (context, index) => _cell(index, maze),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_phase == _MazePhase.playing)
                    _controls()
                  else if (_phase == _MazePhase.legDone)
                    _legComplete(),
                  const SizedBox(height: 10),
                  const Text(
                    'Keyboard: arrows or WASD · Mobile: swipe or use the arrows',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ArenaColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  Widget _cell(int index, _MazeMap maze) {
    final isPlayer = index == _position;
    final isStart = index == maze.start;
    final isHome = index == maze.home;
    final checkpoint = maze.checkpoints.contains(index);
    final obstacle = maze.obstacles.contains(index);
    final visited = _visitedCheckpoints.contains(index);
    final wall = !maze.open(index);
    final child = isPlayer
        ? const Icon(
            Icons.directions_walk_rounded,
            color: Colors.white,
            size: 22,
          )
        : isStart
        ? const Icon(Icons.school_rounded, color: Colors.white, size: 20)
        : isHome
        ? const Icon(Icons.home_rounded, color: Colors.white, size: 20)
        : checkpoint
        ? Icon(
            visited ? Icons.check_circle_rounded : Icons.flag_rounded,
            color: Colors.white,
            size: 17,
          )
        : obstacle
        ? const Icon(
            Icons.construction_rounded,
            color: Color(0xFF5C4224),
            size: 15,
          )
        : null;
    final label = isStart
        ? 'school'
        : isHome
        ? 'home'
        : wall
        ? 'wall'
        : checkpoint
        ? 'checkpoint'
        : obstacle
        ? 'obstacle'
        : 'path';
    return Semantics(
      key: ValueKey('maze-cell-$index'),
      label: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: wall
              ? const Color(0xFF263653)
              : isPlayer
              ? ArenaColors.primary
              : isStart
              ? const Color(0xFF307F63)
              : isHome
              ? const Color(0xFFB44E6B)
              : checkpoint
              ? visited
                    ? const Color(0xFF38765E)
                    : ArenaColors.gold
              : obstacle
              ? const Color(0xFFFFD98E)
              : const Color(0xFF172541),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _controls() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton.filledTonal(
        onPressed: () => _move(0, -1),
        icon: const Icon(Icons.chevron_left_rounded),
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.filledTonal(
            onPressed: () => _move(-1, 0),
            icon: const Icon(Icons.keyboard_arrow_up_rounded),
          ),
          IconButton.filledTonal(
            onPressed: () => _move(1, 0),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ],
      ),
      IconButton.filledTonal(
        onPressed: () => _move(0, 1),
        icon: const Icon(Icons.chevron_right_rounded),
      ),
    ],
  );

  Widget _legComplete() => Container(
    padding: const EdgeInsets.all(15),
    decoration: _box(),
    child: Column(
      children: [
        Text(
          '${_players[_playerIndex]} finished in ${_format(_elapsed)}!',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 9),
        if (_race)
          Text(
            _playerIndex + 1 < _playerCount
                ? 'Pass the device to ${_players[_playerIndex + 1]} for their race.'
                : 'Race complete!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: ArenaColors.textMuted),
          ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: _next,
          child: Text(
            _race
                ? _playerIndex + 1 < _playerCount
                      ? 'Next racer'
                      : 'See results'
                : 'Next level',
          ),
        ),
      ],
    ),
  );

  Widget _results() {
    final sorted = _times.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final winner = _race && sorted.isNotEmpty ? sorted.first.key : null;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                size: 64,
                color: ArenaColors.gold,
              ),
              const SizedBox(height: 8),
              Text(
                _race ? '$winner wins the race!' : 'Maze complete!',
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ...sorted.map(
                (entry) => Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: _box(),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        _format(entry.value),
                        style: const TextStyle(
                          color: ArenaColors.gold,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          setState(() => _phase = _MazePhase.setup),
                      child: const Text('Choose level'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: _restart,
                      child: const Text('Play again'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String title, String value) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 3),
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
    decoration: _box(),
    child: Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: ArenaColors.textMuted,
            fontSize: 8,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
        ),
      ],
    ),
  );
  String _format(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}.${(d.inMilliseconds % 1000 ~/ 100)}';
  BoxDecoration _box() => BoxDecoration(
    color: ArenaColors.surface,
    border: Border.all(color: ArenaColors.border),
    borderRadius: BorderRadius.circular(17),
  );
}

class _Heading extends StatelessWidget {
  const _Heading(this.kicker, this.title, this.subtitle);
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
          letterSpacing: 1.4,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        title,
        style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 4),
      Text(subtitle, style: const TextStyle(color: ArenaColors.textMuted)),
    ],
  );
}

class _Legend extends StatelessWidget {
  const _Legend();
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 8,
    children: const [
      _LegendItem(Icons.school_rounded, 'School', Color(0xFF63DDA8)),
      _LegendItem(Icons.flag_rounded, 'Checkpoint', ArenaColors.gold),
      _LegendItem(Icons.construction_rounded, 'Detour +2s', Color(0xFFFFD98E)),
      _LegendItem(Icons.home_rounded, 'Home', Color(0xFFB44E6B)),
    ],
  );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem(this.icon, this.text, this.color);
  final IconData icon;
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 4),
      Text(
        text,
        style: const TextStyle(color: ArenaColors.textMuted, fontSize: 11),
      ),
    ],
  );
}

const _label = TextStyle(
  color: ArenaColors.textMuted,
  fontSize: 10,
  fontWeight: FontWeight.w900,
  letterSpacing: 1.2,
);
