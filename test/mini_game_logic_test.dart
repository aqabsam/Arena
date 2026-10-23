import 'package:flutter_test/flutter_test.dart';
import 'package:game_arena/game/mini_game_logic.dart';

void main() {
  group('Tic-Tac-Toe', () {
    test(
      'detects win, highlights line, rejects moves after finish, restarts',
      () {
        final game = TicTacToeState();
        for (final cell in [0, 3, 1, 4, 2]) {
          expect(game.play(cell), isTrue);
        }
        expect(game.winner, 1);
        expect(game.winningLine, [0, 1, 2]);
        expect(game.play(5), isFalse);
        game.reset();
        expect(game.board, everyElement(0));
        expect(game.currentPlayer, 1);
        expect(game.winner, 0);
      },
    );

    test('detects draw and rejects occupied cells', () {
      final game = TicTacToeState();
      for (final cell in [0, 1, 2, 4, 3, 5, 7, 6, 8]) {
        game.play(cell);
      }
      expect(game.draw, isTrue);
      expect(game.winner, 0);
      expect(game.play(0), isFalse);
    });
  });

  group('Rock Paper Scissors', () {
    test('resolves each winner and a tie', () {
      expect(resolveHands(Hand.rock, Hand.scissors), 1);
      expect(resolveHands(Hand.paper, Hand.rock), 1);
      expect(resolveHands(Hand.scissors, Hand.paper), 1);
      expect(resolveHands(Hand.paper, Hand.paper), 0);
      expect(resolveHands(Hand.scissors, Hand.rock), 2);
    });
  });

  group('Connect Four', () {
    test('detects vertical win, full columns, invalid moves, and restart', () {
      final game = ConnectFourState();
      for (final col in [0, 1, 0, 1, 0, 1, 0]) {
        expect(game.drop(col), isTrue);
      }
      expect(game.winner, 1);
      expect(game.winningCells, containsAll(['5,0', '4,0', '3,0', '2,0']));
      expect(game.drop(0), isFalse);
      game.reset();
      expect(game.board.every((row) => row.every((cell) => cell == 0)), isTrue);
      expect(game.currentPlayer, 1);
      expect(game.drop(7), isFalse);
    });

    test('detects diagonal connect four', () {
      final game = ConnectFourState();
      for (final col in [0, 1, 1, 2, 4, 2, 2, 3, 4, 3, 5, 3, 3]) {
        game.drop(col);
      }
      expect(game.winner, 1);
    });
  });

  group('Dots and Boxes', () {
    test('claims a completed box and grants another turn', () {
      final game = DotsBoxesState();
      game.draw('h', 0, 0);
      game.draw('v', 0, 0);
      game.draw('h', 1, 0);
      expect(game.currentPlayer, 2);
      game.draw('v', 0, 1);
      expect(game.boxes['0,0'], 2);
      expect(game.currentPlayer, 2);
      expect(game.draw('v', 0, 1), isFalse);
      game.reset();
      expect(game.edges, isEmpty);
      expect(game.boxes, isEmpty);
      expect(game.currentPlayer, 1);
    });

    test('ends after all nine boxes are claimed', () {
      final game = DotsBoxesState();
      for (var r = 0; r <= 3; r++) {
        for (var c = 0; c < 3; c++) {
          game.draw('h', r, c);
        }
      }
      for (var r = 0; r < 3; r++) {
        for (var c = 0; c <= 3; c++) {
          game.draw('v', r, c);
        }
      }
      expect(game.finished, isTrue);
      expect(game.boxes, hasLength(9));
      expect(game.draw('h', 0, 0), isFalse);
    });
  });

  group('Stick Takeaway', () {
    test('enforces valid takes, turn changes, winning move, and restart', () {
      final game = NimState(startingPile: 4);
      expect(game.take(0), isFalse);
      expect(game.take(5), isFalse);
      expect(game.take(3), isTrue);
      expect(game.currentPlayer, 2);
      expect(game.take(1), isTrue);
      expect(game.winner, 2);
      expect(game.take(1), isFalse);
      game.reset();
      expect(game.pile, 4);
      expect(game.winner, 0);
      expect(game.currentPlayer, 1);
    });
  });
}
