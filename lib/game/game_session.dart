import '../data/category_repository.dart';
import '../game/bid_challenge_game.dart';
import '../models/game_models.dart';

class GameSession {
  GameSession() : categories = <GameCategory>[];

  List<GameCategory> categories;
  GameCategory? selectedCategory;
  int teamSize = 3;
  List<String> playerNames = <String>[];
  BidChallengeGame? activeGame;
  RoundResult? lastRound;

  Future<void> loadCategories() async {
    final baseCategories = await CategoryRepository.loadCategories();
    categories = baseCategories;
    selectedCategory = categories.firstWhere(
      (category) => category.id == 'random',
      orElse: () => categories.first,
    );
  }

  void setPlayersFromTeamSize(int size, [List<String>? customNames]) {
    final playerCount = size * 2;
    final values = customNames != null && customNames.isNotEmpty
        ? customNames
        : List<String>.generate(playerCount, (index) {
            final team = index < size ? 'Team A' : 'Team B';
            final teamIndex = index < size ? index : index - size;
            return '$team Player ${teamIndex + 1}';
          });
    playerNames = values
        .take(playerCount)
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
    while (playerNames.length < playerCount) {
      playerNames.add('Player ${playerNames.length + 1}');
    }
    if (playerNames.length > playerCount) {
      playerNames = playerNames.sublist(0, playerCount);
    }
  }

  void updateEditableCategoryItems(String categoryId, List<String> names) {
    const editableIds = <String>{'custom'};
    if (!editableIds.contains(categoryId)) return;
    final index = categories.indexWhere(
      (category) => category.id == categoryId,
    );
    if (index < 0) return;
    final category = categories[index];
    final items = names
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList(growable: false)
        .asMap()
        .entries
        .map(
          (entry) => GameItem(
            id: '${category.id}_user_${entry.key + 1}',
            name: entry.value,
            categoryId: category.id,
          ),
        )
        .toList(growable: false);
    final updated = GameCategory(
      id: category.id,
      name: category.name,
      items: items,
      isRandomMix: category.isRandomMix,
      enabled: category.enabled,
      logoName: category.logoName,
      logoUrl: category.logoUrl,
      logoSourcePage: category.logoSourcePage,
      logoLicense: category.logoLicense,
    );
    categories[index] = updated;
    if (selectedCategory?.id == category.id) selectedCategory = updated;
  }

  void startGame() {
    if (playerNames.isEmpty) setPlayersFromTeamSize(teamSize);
    final names = playerNames;
    lastRound = null;
    activeGame = BidChallengeGame(
      selectedCategory: selectedCategory ?? categories.first,
      playerNames: names,
    );

    if ((selectedCategory ?? categories.first).isRandomMix) {
      activeGame!.prepareRandomMixedPool(
        CategoryRepository.buildMixedItemPool(categories),
      );
    }
  }

  Future<void> restartGame() async {
    lastRound = null;
    activeGame = null;
    startGame();
  }
}
