import 'package:flutter_test/flutter_test.dart';
import 'package:game_arena/data/character_ranking_repository.dart';
import 'package:game_arena/data/category_repository.dart';
import 'package:game_arena/game/bid_challenge_game.dart';
import 'package:game_arena/game/game_session.dart';
import 'package:game_arena/models/game_models.dart';

GameCategory _category({bool randomMix = false}) => GameCategory(
  id: randomMix ? 'random' : 'test',
  name: randomMix ? 'Random / Mixed' : 'Test',
  isRandomMix: randomMix,
  items: randomMix
      ? const <GameItem>[]
      : const <GameItem>[
          GameItem(id: 'test_one', name: 'One', categoryId: 'test'),
        ],
);

GameCategory _twoItemCategory() => const GameCategory(
  id: 'test',
  name: 'Test',
  items: <GameItem>[
    GameItem(id: 'test_one', name: 'One', categoryId: 'test'),
    GameItem(id: 'test_two', name: 'Two', categoryId: 'test'),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'category dataset has unique IDs and accurate item categories',
    () async {
      final categories = await CategoryRepository.loadCategories();
      CategoryRepository.validateCategories(categories);
      expect(categories.length, 36);
      expect(categories.first.isRandomMix, isTrue);
      expect(categories.first.items, isEmpty);
      expect(
        categories
            .where(
              (category) => const <String>{
                'classmates',
                'schoolmates',
                'teachers',
                'friends',
              }.contains(category.id),
            )
            .toList(),
        isEmpty,
      );
      await CategoryRepository.validateReferencedAssets(categories);
      final pokemon = categories.singleWhere(
        (category) => category.id == 'pokemon',
      );
      expect(pokemon.items.where((item) => item.imageUrl != null).length, 11);
      for (final category in categories) {
        for (final item in category.items) {
          if (item.imageUrl != null) {
            expect(Uri.parse(item.imageUrl!).scheme, 'https');
          }
        }
      }
    },
  );

  test(
    'category logo metadata is loaded and SVG logos use raster previews',
    () async {
      final categories = await CategoryRepository.loadCategories();
      final withLogos = categories.where(
        (category) => category.logoUrl != null,
      );
      expect(withLogos, hasLength(18));
      expect(
        withLogos.every(
          (category) =>
              category.logoName != null &&
              category.logoSourcePage != null &&
              category.logoLicense != null,
        ),
        isTrue,
      );
      expect(
        CategoryRepository.categoryLogoRasterUrl(
          'https://upload.wikimedia.org/wikipedia/commons/1/1a/Film-strip.svg',
        ),
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Film-strip.svg/160px-Film-strip.svg.png',
      );
      const pngUrl =
          'https://upload.wikimedia.org/wikipedia/commons/3/36/logo.png';
      expect(CategoryRepository.categoryLogoRasterUrl(pngUrl), pngUrl);
    },
  );

  test('team representatives alternate and seller accepts the highest bid', () {
    final game = BidChallengeGame(
      selectedCategory: _category(),
      playerNames: const <String>['A1', 'B1'],
    );
    expect(game.players.map((player) => player.coins), everyElement(100));
    expect(game.currentPlayer!.name, 'A1');
    game.placeBid('A1', 10);
    expect(game.currentPlayer!.name, 'B1');
    game.placeBid('B1', 5);
    expect(game.currentPlayer!.name, 'A1');
    final result = game.purchaseCurrentBid('A1');
    expect(result.winnerName, 'B1');
    expect(result.winningBid, 15);
    expect(game.players[0].coins, 100);
    expect(game.players[1].coins, 85);
  });

  test('auction starts at 10 and offers five and ten coin raises', () {
    final game = BidChallengeGame(
      selectedCategory: _category(),
      playerNames: const <String>['A', 'B'],
    );
    expect(game.currentPlayer!.name, 'A');
    expect(() => game.placeBid('A', 5), throwsArgumentError);
    expect(game.placeBid('A', 10), isNull);
    expect(game.currentBid, 10);
    expect(game.currentPlayer!.name, 'B');
    expect(game.placeBid('B', 10), isNull);
    expect(game.currentBid, 20);
    expect(game.currentPlayer!.name, 'A');
    expect(game.highestBidder, 'B');
    expect(game.actionMessage, contains('Team A — Player 1, respond!'));
  });

  test('purchase charges only the buyer and does not charge bidders', () {
    final game = BidChallengeGame(
      selectedCategory: _category(),
      playerNames: const <String>['A', 'B'],
    );
    game.placeBid('A', 10);
    game.placeBid('B', 5);
    final result = game.purchaseCurrentBid('A');
    expect(result.winnerName, 'B');
    expect(result.winningBid, 15);
    expect(game.players.map((player) => player.coins), <int>[100, 85]);
    expect(game.players.map((player) => player.itemsWon), <int>[0, 1]);
    expect(game.isPurchased(result.itemId), isTrue);
    expect(game.teamCoins('Team A'), 100);
    expect(game.teamCoins('Team B'), 85);
  });

  test(
    'player cannot raise beyond their balance and passing removes their turn',
    () {
      final game = BidChallengeGame(
        selectedCategory: _category(),
        playerNames: const <String>['A', 'B'],
      );
      game.players[1].coins = 14;
      game.placeBid('A', 10);
      expect(() => game.placeBid('B', 5), throwsArgumentError);
      expect(game.players.map((player) => player.coins), <int>[100, 14]);
    },
  );

  test('all players can pass and leave the item unsold', () {
    final game = BidChallengeGame(
      selectedCategory: _twoItemCategory(),
      playerNames: const <String>['A', 'B'],
    );
    final firstItemId = game.currentItem!.id;
    game.pass('A');
    expect(game.currentPlayer!.name, 'B');
    final result = game.pass('B');
    expect(result!.sold, isFalse);
    expect(result.winnerName, isEmpty);
    expect(game.players.map((player) => player.coins), everyElement(100));
    expect(game.currentItem!.id, isNot(firstItemId));
  });

  test('only high bidder left after opponents pass wins at current bid', () {
    final game = BidChallengeGame(
      selectedCategory: _category(),
      playerNames: const <String>['A', 'B'],
    );
    game.placeBid('A', 10);
    final result = game.pass('B');
    expect(result!.winnerName, 'A');
    expect(result.winningBid, 10);
    expect(game.players.first.coins, 90);
  });

  test(
    'next actor is exposed only after auction closes and no double purchase',
    () {
      final game = BidChallengeGame(
        selectedCategory: _twoItemCategory(),
        playerNames: const <String>['A', 'B'],
      );
      final itemId = game.currentItem!.id;
      game.placeBid('A', 10);
      expect(game.currentItem!.id, itemId);
      final result = game.purchaseCurrentBid('B');
      expect(game.currentItem!.id, isNot(itemId));
      expect(game.isPurchased(itemId), isTrue);
      expect(result.history, isNotEmpty);
      expect(game.roundResults, hasLength(1));
    },
  );

  test('a player cannot bid more coins than they own', () {
    final game = BidChallengeGame(
      selectedCategory: _category(),
      playerNames: const <String>['A1', 'A2'],
    );
    game.players[1].coins = 54;
    game.placeBid('A1', 50);
    expect(() => game.placeBid('A2', 5), throwsArgumentError);
    expect(game.players.map((player) => player.coins), <int>[100, 54]);
  });

  test('bid increment controls add exact amounts without spending coins', () {
    expect(
      BidChallengeGame.addBidIncrement(
        currentBid: 50,
        increment: 5,
        availableCoins: 200,
      ),
      55,
    );
    expect(
      BidChallengeGame.addBidIncrement(
        currentBid: 50,
        increment: 10,
        availableCoins: 200,
      ),
      60,
    );
    expect(
      BidChallengeGame.addBidIncrement(
        currentBid: 50,
        increment: 20,
        availableCoins: 200,
      ),
      70,
    );
    expect(
      BidChallengeGame.addBidIncrement(
        currentBid: 50,
        increment: 50,
        availableCoins: 200,
      ),
      100,
    );
    var proposedBid = 50;
    for (final increment in BidChallengeGame.bidIncrements) {
      proposedBid = BidChallengeGame.addBidIncrement(
        currentBid: proposedBid,
        increment: increment,
        availableCoins: 200,
      );
    }
    expect(proposedBid, 135);
    expect(BidChallengeGame.reduceBidByFive(proposedBid), 130);
    expect(BidChallengeGame.reduceBidByFive(0), 0);
    expect(
      () => BidChallengeGame.addBidIncrement(
        currentBid: 0,
        increment: 7,
        availableCoins: 100,
      ),
      throwsArgumentError,
    );
    expect(
      () => BidChallengeGame.addBidIncrement(
        currentBid: 95,
        increment: 10,
        availableCoins: 100,
      ),
      throwsArgumentError,
    );

    final game = BidChallengeGame(
      selectedCategory: _category(),
      playerNames: const <String>['A', 'B'],
    );
    final before = game.players.first.coins;
    BidChallengeGame.addBidIncrement(
      currentBid: 0,
      increment: 50,
      availableCoins: before,
    );
    expect(game.players.first.coins, before);
  });

  test(
    'confirmed purchase charges only the buyer and records ownership once',
    () {
      final game = BidChallengeGame(
        selectedCategory: _category(),
        playerNames: const <String>['A', 'B', 'C'],
      );
      game.placeBid('A', 20);
      game.placeBid('B', 50);
      game.pass('A');
      final result = game.roundResults.single;

      expect(result.winnerName, 'B');
      expect(game.players.map((player) => player.coins), <int>[100, 30, 100]);
      expect(game.players[0].purchasedItems, isEmpty);
      expect(game.players[1].purchasedItems.map((item) => item.id), <String>[
        'test_one',
      ]);
      expect(game.players[2].purchasedItems, isEmpty);
      expect(game.teamOfPlayer('B'), 'Team B');
      expect(game.isPurchased('test_one'), isTrue);
      expect(game.players[1].itemsWon, 1);
      expect(game.players[1].purchasedItems, hasLength(1));
    },
  );

  test('Random / Mixed skips disabled items', () {
    final game = BidChallengeGame(
      selectedCategory: _category(randomMix: true),
      playerNames: const <String>['A1', 'B1'],
    );
    game.prepareRandomMixedPool(const <GameItem>[
      GameItem(id: 'available', name: 'Available', categoryId: 'test'),
      GameItem(
        id: 'disabled',
        name: 'Disabled',
        categoryId: 'test',
        enabled: false,
      ),
    ]);
    expect(game.availableItems.map((item) => item.id), <String>['available']);
  });

  test('team totals include remaining coins and ten points per owned item', () {
    final game = BidChallengeGame(
      selectedCategory: _category(),
      playerNames: const <String>['A1', 'A2', 'B1', 'B2'],
    );
    game.placeBid('A1', 20);
    final result = game.purchaseCurrentBid('B1');
    expect(result.winnerName, 'A1');
    expect(game.teamScore('Team A'), 190);
    expect(game.teamScore('Team B'), 200);
    expect(game.players[0].itemsWon, 1);
  });

  test('a completed item cannot award its points twice', () {
    final game = BidChallengeGame(
      selectedCategory: _category(),
      playerNames: const <String>['A', 'B'],
    );
    game.placeBid('A', 10);
    game.purchaseCurrentBid('B');
    expect(game.players[0].itemsWon, 1);
    expect(game.players[0].score, 100);
    expect(() => game.purchaseCurrentBid('A'), throwsStateError);
    expect(game.players[0].itemsWon, 1);
    expect(game.players[0].score, 100);
    expect(game.players[0].purchasedItems, hasLength(1));
    expect(game.isPurchased('test_one'), isTrue);
  });

  test('automatic team result uses completed score state consistently', () {
    final game = BidChallengeGame(
      selectedCategory: _category(),
      playerNames: const <String>['A1', 'B1'],
    );
    game.players[0].coins = 15;
    game.placeBid('A1', 10);
    game.placeBid('B1', 5);
    game.purchaseCurrentBid('A1');

    expect(game.isComplete, isTrue);
    expect(game.roundResults.single.winnerName, 'B1');
    expect(game.teamScore('Team A'), 15);
    expect(game.teamScore('Team B'), 95);
    expect(game.teamWinner, TeamWinner.teamB);
    expect(game.teamWinner, TeamWinner.teamB);
  });

  test('equal completed team scores are declared a draw', () {
    final game = BidChallengeGame(
      selectedCategory: _category(),
      playerNames: const <String>['A1', 'B1'],
    );
    game.pass('A1');
    game.pass('B1');

    expect(game.isComplete, isTrue);
    expect(game.teamScore('Team A'), game.teamScore('Team B'));
    expect(game.teamWinner, TeamWinner.draw);
  });

  test(
    'ranking asset has 50 unique ranks in each category and safe aliases',
    () async {
      final rankings = await CharacterRankingRepository.loadRankings();
      expect(rankings.length, 21);
      expect(rankings.values, everyElement(hasLength(50)));
      expect(
        CharacterRankingRepository.findByName(
          rankings['Marvel']!,
          'Wanda Maximoff',
        )?.rank,
        13,
      );
      expect(
        CharacterRankingRepository.findByName(rankings['DC']!, 'Flash')?.rank,
        4,
      );
      expect(
        CharacterRankingRepository.findByName(
          rankings['Bollywood']!,
          'Priyanka Chopra Jonas',
        )?.rank,
        4,
      );
      expect(
        CharacterRankingRepository.findByName(
          rankings['Naruto']!,
          'Naruto',
        )?.name,
        'Naruto Uzumaki',
      );
      expect(
        CharacterRankingRepository.findByName(
          rankings['Dragon Ball']!,
          'Goku',
        )?.name,
        'Son Goku',
      );
      expect(
        CharacterRankingRepository.findByName(
          rankings['Dragon Ball']!,
          'Trunks',
        ),
        isNull,
      );
    },
  );

  test('team size creates equal teams and custom items can be edited', () {
    final session = GameSession()..categories = <GameCategory>[_category()];
    session.setPlayersFromTeamSize(4);
    expect(session.playerNames, hasLength(8));
    expect(
      session.playerNames.take(4).every((name) => name.startsWith('Team A')),
      isTrue,
    );
    expect(
      session.playerNames.skip(4).every((name) => name.startsWith('Team B')),
      isTrue,
    );
    session.categories = <GameCategory>[
      GameCategory(
        id: 'custom',
        name: 'Custom Category',
        items: const <GameItem>[],
      ),
    ];
    session.updateEditableCategoryItems('custom', const <String>[
      'My own item',
    ]);
    expect(session.categories.single.items.single.name, 'My own item');
  });

  test('starting again restores coins and item counts', () {
    final session = GameSession()
      ..categories = <GameCategory>[_category()]
      ..selectedCategory = _category()
      ..teamSize = 1
      ..playerNames = <String>['A1', 'B1'];
    session.startGame();
    session.activeGame!.placeBid('A1', 20);
    session.activeGame!.purchaseCurrentBid('B1');
    session.startGame();
    expect(
      session.activeGame!.players.map((player) => player.coins),
      everyElement(100),
    );
    expect(
      session.activeGame!.players.map((player) => player.itemsWon),
      everyElement(0),
    );
    expect(session.activeGame!.currentBid, 0);
    expect(session.activeGame!.currentPlayer!.name, 'A1');
    expect(session.activeGame!.auctionHistory, isEmpty);
  });
}
