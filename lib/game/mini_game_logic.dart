/// Rules for the board games in Mini Games. Kept free of Flutter UI state.
class TicTacToeState {
  List<int> board = List<int>.filled(9, 0);
  int currentPlayer = 1;
  int winner = 0;
  bool draw = false;
  List<int> winningLine = <int>[];

  bool play(int cell) {
    if (cell < 0 || cell >= 9 || board[cell] != 0 || winner != 0 || draw) {
      return false;
    }
    board[cell] = currentPlayer;
    for (final line in _wins) {
      if (line.every((index) => board[index] == currentPlayer)) {
        winner = currentPlayer;
        winningLine = line;
        return true;
      }
    }
    if (board.every((value) => value != 0)) {
      draw = true;
      return true;
    }
    currentPlayer = 3 - currentPlayer;
    return true;
  }

  void reset() {
    board = List<int>.filled(9, 0);
    currentPlayer = 1;
    winner = 0;
    draw = false;
    winningLine = <int>[];
  }

  static const _wins = <List<int>>[
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];
}

class ConnectFourState {
  static const rows = 6;
  static const columns = 7;
  List<List<int>> board = List<List<int>>.generate(
    rows,
    (_) => List<int>.filled(columns, 0),
  );
  int currentPlayer = 1;
  int winner = 0;
  bool draw = false;
  Set<String> winningCells = <String>{};

  bool drop(int column) {
    if (column < 0 || column >= columns || winner != 0 || draw) return false;
    final row = board.lastIndexWhere((line) => line[column] == 0);
    if (row < 0) return false;
    board[row][column] = currentPlayer;
    final line = _winningLine(row, column);
    if (line.isNotEmpty) {
      winner = currentPlayer;
      winningCells = line.map((cell) => '${cell.$1},${cell.$2}').toSet();
    } else if (board.every((line) => line.every((cell) => cell != 0))) {
      draw = true;
    } else {
      currentPlayer = 3 - currentPlayer;
    }
    return true;
  }

  List<(int, int)> _winningLine(int row, int column) {
    for (final direction in const <(int, int)>[
      (0, 1),
      (1, 0),
      (1, 1),
      (1, -1),
    ]) {
      final cells = <(int, int)>[(row, column)];
      for (final sign in <int>[-1, 1]) {
        var r = row + direction.$1 * sign;
        var c = column + direction.$2 * sign;
        while (r >= 0 &&
            r < rows &&
            c >= 0 &&
            c < columns &&
            board[r][c] == currentPlayer) {
          cells.add((r, c));
          r += direction.$1 * sign;
          c += direction.$2 * sign;
        }
      }
      if (cells.length >= 4) return cells;
    }
    return <(int, int)>[];
  }

  void reset() {
    board = List<List<int>>.generate(rows, (_) => List<int>.filled(columns, 0));
    currentPlayer = 1;
    winner = 0;
    draw = false;
    winningCells = <String>{};
  }
}

class DotsBoxesState {
  static const size = 3;
  Set<String> edges = <String>{};
  Map<String, int> boxes = <String, int>{};
  int currentPlayer = 1;

  String h(int row, int column) => 'h$row,$column';
  String v(int row, int column) => 'v$row,$column';
  String box(int row, int column) => '$row,$column';
  bool get finished => boxes.length == size * size;

  /// Draw a horizontal (h) or vertical (v) edge; returns false for invalid/repeated moves.
  bool draw(String orientation, int row, int column) {
    final valid = orientation == 'h'
        ? row >= 0 && row <= size && column >= 0 && column < size
        : orientation == 'v' &&
              row >= 0 &&
              row < size &&
              column >= 0 &&
              column <= size;
    if (!valid || finished) return false;
    final edge = orientation == 'h' ? h(row, column) : v(row, column);
    if (!edges.add(edge)) return false;
    var claimed = 0;
    final possible = orientation == 'h'
        ? <(int, int)>[(row - 1, column), (row, column)]
        : <(int, int)>[(row, column - 1), (row, column)];
    for (final (r, c) in possible) {
      if (r < 0 ||
          c < 0 ||
          r >= size ||
          c >= size ||
          boxes.containsKey(box(r, c))) {
        continue;
      }
      if (edges.contains(h(r, c)) &&
          edges.contains(h(r + 1, c)) &&
          edges.contains(v(r, c)) &&
          edges.contains(v(r, c + 1))) {
        boxes[box(r, c)] = currentPlayer;
        claimed++;
      }
    }
    if (claimed == 0) currentPlayer = 3 - currentPlayer;
    return true;
  }

  void reset() {
    edges = <String>{};
    boxes = <String, int>{};
    currentPlayer = 1;
  }
}

class NimState {
  NimState({this.startingPile = 21}) : pile = startingPile;
  final int startingPile;
  int pile;
  int currentPlayer = 1;
  int winner = 0;

  bool take(int amount) {
    if (winner != 0 || amount < 1 || amount > 3 || amount > pile) return false;
    pile -= amount;
    if (pile == 0) {
      winner = currentPlayer;
    } else {
      currentPlayer = 3 - currentPlayer;
    }
    return true;
  }

  void reset() {
    pile = startingPile;
    currentPlayer = 1;
    winner = 0;
  }
}

enum Hand { rock, paper, scissors }

/// Returns 0 for a draw, 1 if player one wins, and 2 if player two wins.
int resolveHands(Hand first, Hand second) {
  if (first == second) return 0;
  if ((first == Hand.rock && second == Hand.scissors) ||
      (first == Hand.paper && second == Hand.rock) ||
      (first == Hand.scissors && second == Hand.paper)) {
    return 1;
  }
  return 2;
}
