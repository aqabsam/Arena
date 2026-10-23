class GameItem {
  const GameItem({
    required this.id,
    required this.name,
    required this.categoryId,
    this.imageUrl,
    this.description,
    this.aliases = const <String>[],
    this.enabled = true,
  });

  final String id;
  final String name;
  final String categoryId;
  final String? imageUrl;
  final String? description;
  final List<String> aliases;
  final bool enabled;

  factory GameItem.fromJson(Map<String, dynamic> json, String categoryId) {
    return GameItem(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryId: (json['categoryId'] as String?) ?? categoryId,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      aliases: (json['aliases'] as List<dynamic>? ?? const <dynamic>[])
          .map((alias) => alias.toString())
          .toList(growable: false),
      enabled: (json['enabled'] as bool?) ?? true,
    );
  }
}

class GameCategory {
  const GameCategory({
    required this.id,
    required this.name,
    required this.items,
    this.isRandomMix = false,
    this.enabled = true,
    this.logoName,
    this.logoUrl,
    this.logoSourcePage,
    this.logoLicense,
  });

  final String id;
  final String name;
  final List<GameItem> items;
  final bool isRandomMix;
  final bool enabled;
  final String? logoName;
  final String? logoUrl;
  final String? logoSourcePage;
  final String? logoLicense;

  factory GameCategory.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final rawItems = json['items'] as List<dynamic>? ?? const <dynamic>[];
    return GameCategory(
      id: id,
      name: json['name'] as String,
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map((item) => GameItem.fromJson(item, id))
          .toList(growable: false),
      isRandomMix: (json['isRandomMix'] as bool?) ?? false,
      enabled: (json['enabled'] as bool?) ?? true,
      logoName: json['logoName'] as String?,
      logoUrl: json['logoUrl'] as String?,
      logoSourcePage: json['logoSourcePage'] as String?,
      logoLicense: json['logoLicense'] as String?,
    );
  }
}

class GamePlayer {
  GamePlayer({required this.name, this.coins = 100, this.itemsWon = 0});

  final String name;
  int coins;
  int itemsWon;
  final List<GameItem> _purchasedItems = <GameItem>[];

  List<GameItem> get purchasedItems =>
      List<GameItem>.unmodifiable(_purchasedItems);

  void recordPurchase(GameItem item) {
    if (_purchasedItems.any((purchased) => purchased.id == item.id)) {
      throw StateError('${item.name} was already purchased by $name');
    }
    _purchasedItems.add(item);
  }

  int get score => coins + (itemsWon * 10);
}

class RoundResult {
  const RoundResult({
    required this.itemId,
    required this.itemName,
    this.imageUrl,
    required this.categoryName,
    required this.winnerName,
    required this.winningBid,
    required this.bids,
    required this.roundNumber,
    this.sold = true,
    this.history = const <String>[],
  });

  final String itemId;
  final String itemName;
  final String? imageUrl;
  final String categoryName;
  final String winnerName;
  final int winningBid;
  final Map<String, int> bids;
  final int roundNumber;
  final bool sold;
  final List<String> history;
}
