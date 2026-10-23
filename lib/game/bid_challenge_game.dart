import 'dart:math' as math;

import '../models/game_models.dart';

enum TeamWinner { teamA, teamB, draw }

class BidChallengeGame {
  static const List<int> bidIncrements = <int>[5, 10, 20, 50];
  static const int openingBid = 10;

  BidChallengeGame({
    required this.selectedCategory,
    required List<String> playerNames,
  }) : _allPlayers = List.generate(
         playerNames.length,
         (index) => GamePlayer(
           name: playerNames[index].trim().isEmpty
               ? 'Player ${index + 1}'
               : playerNames[index].trim(),
         ),
       ),
       _availableItems = _buildAvailableItems(selectedCategory),
       _roundNumber = 1 {
    _totalRounds = _availableItems.length;
    _selectOpeningRepresentative();
  }

  final GameCategory selectedCategory;
  final List<GamePlayer> _allPlayers;
  final List<GameItem> _availableItems;
  int _roundNumber;
  int _totalRounds = 0;
  final List<RoundResult> _roundResults = <RoundResult>[];
  final Set<String> _purchasedItemIds = <String>{};
  int _turnIndex = 0;
  int _currentBid = 0;
  String? _highestBidder;
  final Set<String> _passedTeams = <String>{};
  final Map<String, int> _auctionBids = <String, int>{};
  final List<String> _auctionHistory = <String>[];
  String _actionMessage = 'Team A — Player 1 opens the auction.';

  List<GamePlayer> get players => List.unmodifiable(_allPlayers);
  List<GameItem> get availableItems => List.unmodifiable(_availableItems);
  int get roundNumber => _roundNumber;
  int get totalCoinsPerPlayer => 100;
  int get totalRounds => _totalRounds;
  bool get isComplete => _availableItems.isEmpty;
  List<RoundResult> get roundResults =>
      List<RoundResult>.unmodifiable(_roundResults);
  int get currentBid => _currentBid;
  String? get highestBidder => _highestBidder;
  int get currentTurnIndex => _turnIndex;
  String get activeTeam =>
      isComplete ? 'Team A' : teamOfPlayer(_allPlayers[_turnIndex].name);
  GamePlayer? get currentPlayer => isComplete ? null : _allPlayers[_turnIndex];
  String get actionMessage => _actionMessage;
  List<String> get auctionHistory => List<String>.unmodifiable(_auctionHistory);
  Set<String> get passedTeams => Set<String>.unmodifiable(_passedTeams);
  bool get auctionHasBid => _highestBidder != null;

  static int addBidIncrement({
    required int currentBid,
    required int increment,
    required int availableCoins,
  }) {
    if (currentBid < 0 || availableCoins < 0 || currentBid > availableCoins) {
      throw ArgumentError('Bid and balance must be valid nonnegative amounts');
    }
    if (!bidIncrements.contains(increment)) {
      throw ArgumentError.value(
        increment,
        'increment',
        'Unsupported increment',
      );
    }
    final nextBid = currentBid + increment;
    if (nextBid > availableCoins) {
      throw ArgumentError('Bid cannot exceed the player’s available coins');
    }
    return nextBid;
  }

  static int reduceBidByFive(int currentBid) {
    if (currentBid < 0) {
      throw ArgumentError.value(currentBid, 'currentBid');
    }
    return math.max(0, currentBid - 5);
  }

  bool isPurchased(String itemId) => _purchasedItemIds.contains(itemId);

  int get _teamSize => _allPlayers.length ~/ 2;

  int _opposingRepresentativeIndex(int index) =>
      teamOfPlayer(_allPlayers[index].name) == 'Team A' ? _teamSize : 0;

  bool _selectOpeningRepresentative() {
    if (_allPlayers.isEmpty) return false;
    if (_allPlayers.first.coins >= openingBid) {
      _turnIndex = 0;
      return true;
    }
    if (_teamSize < _allPlayers.length &&
        _allPlayers[_teamSize].coins >= openingBid) {
      _turnIndex = _teamSize;
      return true;
    }
    return false;
  }

  String playerSeat(String playerName) {
    final index = _allPlayers.indexWhere((player) => player.name == playerName);
    if (index < 0) return 'Player';
    final firstIndex = teamOfPlayer(playerName) == 'Team A' ? 0 : _teamSize;
    return 'Player ${index - firstIndex + 1}';
  }

  /// Commits the current player's bid and advances the open auction.
  RoundResult? placeBid(String playerName, int increment) {
    _requireCurrentPlayer(playerName);
    if (!bidIncrements.contains(increment)) {
      throw ArgumentError.value(
        increment,
        'increment',
        'Unsupported increment',
      );
    }
    final player = _allPlayers[_turnIndex];
    final nextBid = _currentBid == 0 ? increment : _currentBid + increment;
    if (_currentBid == 0 && nextBid < openingBid) {
      throw ArgumentError('The opening bid is $openingBid coins.');
    }
    if (nextBid > player.coins) {
      throw ArgumentError(
        '${player.name} cannot bid more than their ${player.coins} coins',
      );
    }
    _currentBid = nextBid;
    _highestBidder = playerName;
    _auctionBids[playerName] = nextBid;
    final team = teamOfPlayer(playerName);
    _auctionHistory.add(
      '$team — ${playerSeat(playerName)} bid $nextBid coins.',
    );
    final nextIndex = _opposingRepresentativeIndex(_turnIndex);
    final nextPlayer = _allPlayers[nextIndex];
    final message =
        '$team — ${playerSeat(playerName)} bid $nextBid coins. '
        '${teamOfPlayer(nextPlayer.name)} — ${playerSeat(nextPlayer.name)}, respond!';
    if (_passedTeams.contains(teamOfPlayer(nextPlayer.name))) {
      _actionMessage = '$message The other team has passed.';
      return _finishAuction(playerName);
    }
    _turnIndex = nextIndex;
    _actionMessage = message;
    return null;
  }

  /// The current player accepts the standing price and buys the item.
  RoundResult purchaseCurrentBid(String playerName) {
    _requireCurrentPlayer(playerName);
    if (_currentBid <= 0 || _highestBidder == null) {
      throw StateError('There is no offer to accept.');
    }
    final highTeam = teamOfPlayer(_highestBidder!);
    if (highTeam == teamOfPlayer(playerName)) {
      throw StateError('Only the opposing team can accept this offer.');
    }
    final item = currentItem!;
    _auctionHistory.add(
      '${teamOfPlayer(playerName)} accepted $highTeam’s offer of $_currentBid coins for ${item.name}.',
    );
    _actionMessage =
        '${item.name} sold to $_highestBidder ($highTeam) for $_currentBid coins.';
    return _finishAuction(_highestBidder);
  }

  /// Withdraws this player from this item only.
  RoundResult? pass(String playerName) {
    _requireCurrentPlayer(playerName);
    final team = teamOfPlayer(playerName);
    _passedTeams.add(team);
    _auctionHistory.add('$team — ${playerSeat(playerName)} passed.');
    if (_highestBidder != null && teamOfPlayer(_highestBidder!) != team) {
      _actionMessage =
          '$team passed. ${currentItem!.name} goes to $_highestBidder for $_currentBid coins.';
      return _finishAuction(_highestBidder);
    }
    if (_highestBidder == null && _passedTeams.length == 2) {
      _actionMessage = 'Both teams passed. ${currentItem!.name} is unsold.';
      return _finishAuction(null);
    }
    final nextIndex = _opposingRepresentativeIndex(_turnIndex);
    _turnIndex = nextIndex;
    final next = _allPlayers[nextIndex];
    _actionMessage =
        '$team — ${playerSeat(playerName)} passed. '
        '${teamOfPlayer(next.name)} — ${playerSeat(next.name)}, respond!';
    return null;
  }

  void _requireCurrentPlayer(String playerName) {
    if (isComplete) throw StateError('No items remaining');
    if (_allPlayers[_turnIndex].name != playerName) {
      throw StateError('It is ${_allPlayers[_turnIndex].name}’s turn.');
    }
    if (_passedTeams.contains(teamOfPlayer(playerName))) {
      throw StateError(
        '${teamOfPlayer(playerName)} has already passed this auction.',
      );
    }
  }

  RoundResult _finishAuction(String? winnerName) {
    final item = currentItem!;
    final price = winnerName == null ? 0 : _currentBid;
    if (_purchasedItemIds.contains(item.id)) {
      throw StateError('${item.name} has already been purchased');
    }
    if (winnerName != null) {
      final winner = _allPlayers.firstWhere(
        (player) => player.name == winnerName,
      );
      if (price > winner.coins) {
        throw StateError('${winner.name} cannot afford this purchase.');
      }
      winner.recordPurchase(item);
      winner.coins -= price;
      winner.itemsWon += 1;
      _purchasedItemIds.add(item.id);
    }
    final result = RoundResult(
      itemId: item.id,
      itemName: item.name,
      imageUrl: item.imageUrl,
      categoryName: selectedCategory.name,
      winnerName: winnerName ?? '',
      winningBid: price,
      bids: Map<String, int>.unmodifiable(_auctionBids),
      roundNumber: _roundNumber,
      sold: winnerName != null,
      history: List<String>.unmodifiable(_auctionHistory),
    );
    _roundResults.add(result);
    _availableItems.removeAt(0);
    _roundNumber += 1;
    _turnIndex = 0;
    _currentBid = 0;
    _highestBidder = null;
    _passedTeams.clear();
    _auctionBids.clear();
    _auctionHistory.clear();
    if (_availableItems.isNotEmpty) {
      if (!_selectOpeningRepresentative()) {
        _auctionHistory.add(
          'Neither opening representative can afford the opening bid. ${currentItem!.name} is unsold.',
        );
        _actionMessage = 'No player can afford the opening bid.';
        return _finishAuction(null);
      }
      final opening = _allPlayers[_turnIndex];
      _actionMessage =
          '${teamOfPlayer(opening.name)} — ${playerSeat(opening.name)} opens the next auction.';
    }
    return result;
  }

  static List<GameItem> _buildAvailableItems(GameCategory category) {
    if (category.isRandomMix) {
      return <GameItem>[];
    }
    final items = category.items.where((item) => item.enabled).toList()
      ..shuffle();
    return items.take(math.min(5, items.length)).toList();
  }

  String get currentItemName {
    return currentItem?.name ?? 'Game Complete';
  }

  GameItem? get currentItem =>
      _availableItems.isEmpty ? null : _availableItems.first;

  List<String> getPlayerNames() =>
      _allPlayers.map((player) => player.name).toList();

  void prepareRandomMixedPool(List<GameItem> allItems) {
    if (selectedCategory.isRandomMix) {
      _availableItems.clear();
      final shuffled = allItems.where((item) => item.enabled).toList()
        ..shuffle();
      _availableItems.addAll(shuffled.take(math.min(5, shuffled.length)));
      _totalRounds = _availableItems.length;
      _roundNumber = 1;
      _selectOpeningRepresentative();
    }
  }

  List<GamePlayer> leaderboard() {
    final sorted = List<GamePlayer>.from(_allPlayers)
      ..sort((a, b) {
        return b.score.compareTo(a.score);
      });
    return sorted;
  }

  GamePlayer get winner {
    final sorted = leaderboard();
    return sorted.first;
  }

  String teamOfPlayer(String playerName) {
    final index = _allPlayers.indexWhere((player) => player.name == playerName);
    return index >= 0 && index >= _allPlayers.length ~/ 2 ? 'Team B' : 'Team A';
  }

  int teamScore(String teamName) {
    final midpoint = _allPlayers.length ~/ 2;
    final teamPlayers = teamName == 'Team A'
        ? _allPlayers.take(midpoint)
        : _allPlayers.skip(midpoint);
    return teamPlayers.fold<int>(0, (total, player) => total + player.score);
  }

  TeamWinner get teamWinner {
    final teamAScore = teamScore('Team A');
    final teamBScore = teamScore('Team B');
    if (teamAScore > teamBScore) return TeamWinner.teamA;
    if (teamBScore > teamAScore) return TeamWinner.teamB;
    return TeamWinner.draw;
  }

  int teamCoins(String teamName) {
    final midpoint = _allPlayers.length ~/ 2;
    final teamPlayers = teamName == 'Team A'
        ? _allPlayers.take(midpoint)
        : _allPlayers.skip(midpoint);
    return teamPlayers.fold<int>(0, (total, player) => total + player.coins);
  }

  int getNextRoundBidLimit(String playerName) {
    final player = _allPlayers.firstWhere(
      (member) => member.name == playerName,
    );
    return player.coins;
  }

  int getRandomBidForPlayer(String playerName) {
    final maxBid = getNextRoundBidLimit(playerName);
    final random = math.Random();
    return maxBid == 0 ? 0 : random.nextInt(maxBid + 1);
  }
}
