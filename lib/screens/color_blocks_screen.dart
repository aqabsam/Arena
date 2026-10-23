import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../audio/game_audio_service.dart';
import '../theme/game_arena_theme.dart';

enum ColorBlockMode { match, connect, rows, puzzle }

class ColorBlocksScreen extends StatefulWidget {
  const ColorBlocksScreen({super.key});
  @override
  State<ColorBlocksScreen> createState() => _ColorBlocksScreenState();
}

class _ColorBlocksScreenState extends State<ColorBlocksScreen> {
  static const _rows = 7;
  static const _cols = 7;
  static const _colors = <Color>[
    Color(0xFFFF6885),
    Color(0xFFFFC857),
    Color(0xFF5DD9C1),
    Color(0xFF62A6FF),
    Color(0xFFB38AFF),
    Color(0xFFFF91D2),
  ];
  static const _modeNames = <ColorBlockMode, String>{
    ColorBlockMode.match: 'Color Match',
    ColorBlockMode.connect: 'Connect',
    ColorBlockMode.rows: 'Clear Rows',
    ColorBlockMode.puzzle: 'Color Quest',
  };
  final _random = Random();
  final _scores = [0, 0];
  List<int> _board = [];
  ColorBlockMode _mode = ColorBlockMode.match;
  Set<int> _path = {};
  int? _pathColor;
  int _score = 0;
  int _best = 0;
  int _combo = 0;
  int _level = 1;
  int _targetColor = 0;
  int _targetLeft = 0;
  int _activeColor = 0;
  int _activePlayer = 0;
  bool _twoPlayers = false;
  bool _sound = true;
  bool _gameOver = false;

  int get _paletteSize => min(_colors.length, 4 + (_level - 1) ~/ 2);
  int _at(int row, int col) => row * _cols + col;

  @override
  void initState() {
    super.initState();
    _newGame();
    _loadBest();
  }

  Future<void> _loadBest() async {
    final mode = _mode;
    final prefs = await SharedPreferences.getInstance();
    if (mounted && _mode == mode) {
      setState(
        () => _best = prefs.getInt('color_blocks_best_${mode.name}') ?? 0,
      );
    }
  }

  Future<void> _saveBest() async {
    final mode = _mode;
    final score = _score;
    final prefs = await SharedPreferences.getInstance();
    final key = 'color_blocks_best_${mode.name}';
    final stored = prefs.getInt(key) ?? 0;
    final best = max(_best, stored);
    if (score <= best) {
      if (mounted && _mode == mode && _best != best) {
        setState(() => _best = best);
      }
      return;
    }
    await prefs.setInt(key, score);
    if (mounted && _mode == mode) setState(() => _best = score);
  }

  void _play(GameSound sound) {
    if (_sound) GameAudioService.instance.play(sound);
  }

  void _newGame() {
    _score = 0;
    _combo = 0;
    _level = 1;
    _activePlayer = 0;
    _scores[0] = 0;
    _scores[1] = 0;
    _path.clear();
    _gameOver = false;
    _activeColor = _random.nextInt(_paletteSize);
    _board = _mode == ColorBlockMode.rows
        ? List<int>.filled(_rows * _cols, -1)
        : List<int>.generate(
            _rows * _cols,
            (_) => _random.nextInt(_paletteSize),
          );
    _makePuzzleTarget();
  }

  void _makePuzzleTarget() {
    _targetColor = _random.nextInt(_paletteSize);
    _targetLeft = _board.where((color) => color == _targetColor).length;
  }

  void _setMode(ColorBlockMode mode) {
    setState(() {
      _mode = mode;
      _newGame();
      _loadBest();
    });
  }

  List<int> _group(int start) {
    final color = _board[start];
    if (color < 0) return [];
    final found = <int>{start};
    final queue = <int>[start];
    for (var i = 0; i < queue.length; i++) {
      final cell = queue[i], row = cell ~/ _cols, col = cell % _cols;
      for (final next in <int>[
        if (row > 0) cell - _cols,
        if (row < _rows - 1) cell + _cols,
        if (col > 0) cell - 1,
        if (col < _cols - 1) cell + 1,
      ]) {
        if (_board[next] == color && found.add(next)) queue.add(next);
      }
    }
    return queue;
  }

  void _tapCell(int index) {
    if (_gameOver) return;
    switch (_mode) {
      case ColorBlockMode.match:
      case ColorBlockMode.puzzle:
        _clearGroup(index);
      case ColorBlockMode.connect:
        _selectConnect(index);
      case ColorBlockMode.rows:
        _dropPiece(index % _cols);
    }
  }

  void _clearGroup(int index) {
    final color = _board[index];
    if (color < 0 ||
        (_mode == ColorBlockMode.puzzle && color != _targetColor)) {
      _play(GameSound.incorrect);
      return;
    }
    final group = _group(index);
    if (group.length < 2 && _mode != ColorBlockMode.puzzle) {
      _combo = 0;
      _play(GameSound.incorrect);
      return;
    }
    setState(() {
      _combo++;
      for (final cell in group) {
        _board[cell] = -1;
      }
      if (_mode == ColorBlockMode.puzzle) _targetLeft -= group.length;
      _addScore(group.length * 10 * _combo);
      _collapse();
      if (_twoPlayers) _activePlayer = 1 - _activePlayer;
      if (_mode == ColorBlockMode.puzzle && _targetLeft <= 0) {
        _addScore(100 * _level);
        _level++;
        _board = List<int>.generate(
          _rows * _cols,
          (_) => _random.nextInt(_paletteSize),
        );
        _makePuzzleTarget();
      } else if (_board.every((color) => color < 0)) {
        _board = List<int>.generate(
          _rows * _cols,
          (_) => _random.nextInt(_paletteSize),
        );
        if (_mode == ColorBlockMode.puzzle) _makePuzzleTarget();
      }
    });
    _play(GameSound.correct);
    _saveBest();
  }

  void _selectConnect(int index) {
    final color = _board[index];
    if (color < 0) return;
    setState(() {
      if (_path.isEmpty ||
          color != _pathColor ||
          !_adjacentToPath(index) ||
          _path.contains(index)) {
        _path = {index};
        _pathColor = color;
      } else {
        _path.add(index);
      }
    });
    _play(GameSound.selection);
  }

  bool _adjacentToPath(int cell) {
    final r = cell ~/ _cols, c = cell % _cols;
    return _path.any((other) {
      final rr = other ~/ _cols, cc = other % _cols;
      return (r - rr).abs() + (c - cc).abs() == 1;
    });
  }

  void _connectPath() {
    if (_path.length < 3) return;
    setState(() {
      final amount = _path.length;
      for (final cell in _path) {
        _board[cell] = -1;
      }
      _combo++;
      _addScore(amount * 15 * _combo);
      _path.clear();
      _pathColor = null;
      _collapse();
      if (_twoPlayers) _activePlayer = 1 - _activePlayer;
    });
    _play(GameSound.correct);
    _saveBest();
  }

  void _dropPiece(int column) {
    final row = List.generate(
      _rows,
      (r) => r,
    ).reversed.firstWhere((r) => _board[_at(r, column)] < 0, orElse: () => -1);
    if (row < 0) {
      _gameOver = true;
      _saveBest();
      setState(() {});
      return;
    }
    setState(() {
      _board[_at(row, column)] = _activeColor;
      _combo = 0;
      var cleared = 0;
      for (var r = 0; r < _rows; r++) {
        final line = List.generate(_cols, (c) => _board[_at(r, c)]);
        if (line.every((c) => c >= 0)) {
          for (var c = 0; c < _cols; c++) {
            _board[_at(r, c)] = -1;
          }
          cleared++;
        }
      }
      if (cleared > 0) {
        _combo = cleared;
        _addScore(100 * cleared * cleared);
        _collapse();
        _play(GameSound.correct);
      } else {
        _play(GameSound.tap);
      }
      _activeColor = _random.nextInt(_paletteSize);
      if (_twoPlayers) _activePlayer = 1 - _activePlayer;
      if (_board.every((cell) => cell >= 0)) _gameOver = true;
    });
    _saveBest();
  }

  void _collapse() {
    for (var col = 0; col < _cols; col++) {
      final remaining = <int>[];
      for (var row = _rows - 1; row >= 0; row--) {
        final color = _board[_at(row, col)];
        if (color >= 0) remaining.add(color);
      }
      for (var row = _rows - 1; row >= 0; row--) {
        final offset = _rows - 1 - row;
        _board[_at(row, col)] = offset < remaining.length
            ? remaining[offset]
            : -1;
      }
    }
    if (_board.every((cell) => cell < 0)) {
      _level++;
      for (var i = 0; i < _board.length; i++) {
        _board[i] = _random.nextInt(_paletteSize);
      }
    }
  }

  void _addScore(int points) {
    _score += points;
    _scores[_activePlayer] += points;
    final nextLevel = 1 + _score ~/ 250;
    if (nextLevel > _level) _level = nextLevel;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ArenaColors.background,
    appBar: AppBar(
      title: const Text(
        'Color Blocks Puzzle',
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
          tooltip: 'New game',
          onPressed: () => setState(_newGame),
          icon: const Icon(Icons.restart_alt_rounded),
        ),
      ],
    ),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'COLOR BLOCKS',
                    style: TextStyle(
                      color: ArenaColors.cyan,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _modeNames[_mode]!,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _description,
                    style: const TextStyle(
                      color: ArenaColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: ColorBlockMode.values
                        .map(
                          (mode) => ChoiceChip(
                            label: Text(_modeNames[mode]!),
                            selected: _mode == mode,
                            onSelected: (_) => _setMode(mode),
                            selectedColor: ArenaColors.purple,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _metric('SCORE', '$_score')),
                      Expanded(child: _metric('BEST', '$_best')),
                      Expanded(child: _metric('LEVEL', '$_level')),
                      Expanded(child: _metric('COMBO', '×$_combo')),
                    ],
                  ),
                  if (_twoPlayers) ...[
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Expanded(child: _playerScore(0)),
                        const SizedBox(width: 8),
                        Expanded(child: _playerScore(1)),
                      ],
                    ),
                  ],
                  if (_mode == ColorBlockMode.puzzle) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: _card(),
                      child: Text(
                        'COLOR QUEST: clear all ${_colorNames[_targetColor]} blocks · $_targetLeft left',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Center(
                    child: SizedBox(
                      width: min(constraints.maxWidth - 28, 520),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(7),
                          decoration: _card(),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _board.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: _cols,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 5,
                                ),
                            itemBuilder: (context, index) => _block(index),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_mode == ColorBlockMode.connect)
                    FilledButton.icon(
                      onPressed: _path.length >= 3 ? _connectPath : null,
                      icon: const Icon(Icons.link_rounded),
                      label: Text('Connect ${_path.length} blocks (need 3+)'),
                    ),
                  if (_mode == ColorBlockMode.rows)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: _card(),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Next block',
                              style: TextStyle(color: ArenaColors.textMuted),
                            ),
                          ),
                          _swatch(_activeColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Tap a column to drop',
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  if (_gameOver) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: _card(),
                      child: Column(
                        children: [
                          const Text(
                            'Board full! Nice run.',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_twoPlayers)
                            Text(
                              _scores[0] == _scores[1]
                                  ? 'It’s a tie!'
                                  : '${_scores[0] > _scores[1] ? 'Player 1' : 'Player 2'} wins this round!',
                              style: const TextStyle(color: ArenaColors.gold),
                            ),
                          FilledButton(
                            onPressed: () => setState(_newGame),
                            child: const Text('Play again'),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Two-player pass & play'),
                    subtitle: const Text(
                      'Share the board and alternate successful moves.',
                    ),
                    value: _twoPlayers,
                    onChanged: (value) => setState(() {
                      _twoPlayers = value;
                      _newGame();
                    }),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Scores and best scores save on this device.',
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
      ),
    ),
  );

  String get _description => switch (_mode) {
    ColorBlockMode.match =>
      'Tap connected matching colors to clear a group. Bigger combos score more.',
    ColorBlockMode.connect =>
      'Tap a path of neighboring blocks with the same color, then connect 3 or more.',
    ColorBlockMode.rows =>
      'Tap a column to drop the next block. Complete a row to clear it.',
    ColorBlockMode.puzzle =>
      'Clear every block of the highlighted color to solve each quest.',
  };

  static const _colorNames = [
    'coral',
    'gold',
    'mint',
    'blue',
    'violet',
    'pink',
  ];

  Widget _block(int index) {
    final value = _board[index];
    final selected = _path.contains(index);
    return Semantics(
      key: ValueKey('color-block-$index'),
      button: true,
      label: value < 0 ? 'Empty block' : '${_colorNames[value]} block',
      child: GestureDetector(
        onTap: () => _tapCell(index),
        child: AnimatedScale(
          scale: selected ? 1.08 : 1,
          duration: const Duration(milliseconds: 140),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: value < 0
                  ? Colors.white.withValues(alpha: .035)
                  : _colors[value],
              borderRadius: BorderRadius.circular(9),
              border: selected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: value < 0
                  ? null
                  : [
                      BoxShadow(
                        color: _colors[value].withValues(alpha: .25),
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: value < 0
                ? null
                : Center(
                    child: selected
                        ? const Icon(Icons.circle, size: 9, color: Colors.white)
                        : null,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _metric(String title, String value) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 3),
    padding: const EdgeInsets.symmetric(vertical: 9),
    decoration: _card(),
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
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: ArenaColors.gold,
          ),
        ),
      ],
    ),
  );
  Widget _playerScore(int player) => Container(
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: ArenaColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: _activePlayer == player ? ArenaColors.cyan : ArenaColors.border,
      ),
    ),
    child: Text(
      'PLAYER ${player + 1}  ${_scores[player]}${_activePlayer == player ? '  • YOUR TURN' : ''}',
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
    ),
  );
  Widget _swatch(int color) => Container(
    width: 25,
    height: 25,
    decoration: BoxDecoration(
      color: _colors[color],
      borderRadius: BorderRadius.circular(7),
    ),
  );
  BoxDecoration _card() => BoxDecoration(
    color: ArenaColors.surface,
    border: Border.all(color: ArenaColors.border),
    borderRadius: BorderRadius.circular(16),
  );
}
