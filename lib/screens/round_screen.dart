import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../audio/game_audio_service.dart';
import '../game/bid_challenge_game.dart';
import '../game/game_session.dart';
import '../models/game_models.dart';

class RoundScreen extends StatefulWidget {
  const RoundScreen({super.key, required this.session});
  final GameSession session;

  @override
  State<RoundScreen> createState() => _RoundScreenState();
}

class _RoundScreenState extends State<RoundScreen> {
  static const Map<String, String> _localImageByItemId = <String, String>{
    'marvel_iron_man': 'assets/images/marvel/iron_man.webp',
    'marvel_spider_man': 'assets/images/marvel/spider_man.webp',
    'marvel_captain_america': 'assets/images/marvel/captain_america.webp',
    'marvel_thor': 'assets/images/marvel/thor.jpg',
    'marvel_hulk': 'assets/images/marvel/hulk.webp',
    'marvel_black_widow': 'assets/images/marvel/black_widow.jpg',
    'marvel_doctor_strange': 'assets/images/marvel/doctor_strange.jpeg',
    'marvel_wanda_maximoff': 'assets/images/marvel/wanda_maximoff.webp',
    'marvel_black_panther': 'assets/images/marvel/black_panther.jpg',
    'marvel_x_men': 'assets/images/marvel/xmen.webp',
    'marvel_hawkeye': 'assets/images/marvel/hawkeye.webp',
    'marvel_vision': 'assets/images/marvel/vision.jpg',
    'pokemon_bulbasaur': 'assets/images/pokemon/bulbasaur.png',
    'pokemon_charmander': 'assets/images/pokemon/charmander.png',
    'pokemon_squirtle': 'assets/images/pokemon/squirtle.png',
    'pokemon_pikachu': 'assets/images/pokemon/pikachu.png',
    'pokemon_meowth': 'assets/images/pokemon/meowth.png',
    'pokemon_eevee': 'assets/images/pokemon/eevee.png',
    'pokemon_snorlax': 'assets/images/pokemon/snorlax.png',
    'pokemon_gengar': 'assets/images/pokemon/gengar.png',
    'pokemon_psyduck': 'assets/images/pokemon/psyduck.png',
    'pokemon_lapras': 'assets/images/pokemon/lapras.png',
    'pokemon_mew': 'assets/images/pokemon/mew.png',
  };

  int _selectedIncrement = BidChallengeGame.openingBid;
  BidChallengeGame get game => widget.session.activeGame!;

  @override
  Widget build(BuildContext context) {
    final item = game.currentItem;
    final player = game.currentPlayer;
    final pendingBid = game.currentBid == 0
        ? _selectedIncrement
        : game.currentBid + _selectedIncrement;
    final lastResult = widget.session.lastRound;
    return Scaffold(
      backgroundColor: const Color(0xFF071B46),
      appBar: AppBar(
        title: Text(
          game.isComplete
              ? 'Bid Challenge  •  Complete'
              : 'Bid Challenge  •  Round ${game.roundNumber}/${game.totalRounds}',
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Restart game',
            onPressed: _restart,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
          IconButton(
            tooltip: 'Exit to menu',
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.exit_to_app_rounded),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: CustomPaint(painter: _ArenaPainter())),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 420),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(.08, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          child: KeyedSubtree(
                            key: ValueKey<String?>(item?.id),
                            child: _actorCard(item),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF263976),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF6489FF)),
                          ),
                          child: Text(
                            item == null
                                ? 'All auctions are complete.'
                                : game.actionMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFFFD75A),
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (lastResult != null) ...<Widget>[
                          const SizedBox(height: 10),
                          _resultBanner(lastResult),
                        ],
                        const SizedBox(height: 14),
                        _balancesCard(),
                        if (item != null && player != null) ...<Widget>[
                          const SizedBox(height: 14),
                          _turnControls(player, pendingBid),
                          const SizedBox(height: 14),
                          _historyCard(),
                        ],
                        if (game.isComplete) ...<Widget>[
                          const SizedBox(height: 16),
                          _historyCard(showAll: true),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: () {
                              GameAudioService.instance.play(GameSound.victory);
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/score');
                            },
                            icon: const Icon(Icons.emoji_events_rounded),
                            label: const Text('View Final Scores'),
                            style: _primaryStyle,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actorCard(GameItem? item) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
    decoration: BoxDecoration(
      color: const Color(0xFF0D2456),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF2C78E8), width: 1.5),
    ),
    child: Column(
      children: <Widget>[
        Text(
          item == null ? 'AUCTION COMPLETE' : 'CURRENTLY UP FOR AUCTION',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 150,
          height: 112,
          decoration: BoxDecoration(
            color: const Color(0xFF071936),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF9DBBFF), width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: _itemImage(item),
        ),
        const SizedBox(height: 8),
        Text(
          item?.name ?? 'All actors have been auctioned',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 21,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Category: ${game.selectedCategory.name}',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 10),
        TweenAnimationBuilder<double>(
          key: ValueKey<int>(game.currentBid),
          tween: Tween<double>(begin: .82, end: 1),
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) => Transform.scale(
            scale: scale,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _SpinningCoin(key: ValueKey<int>(game.currentBid), size: 19),
                const SizedBox(width: 5),
                Text(
                  'Current bid: ₹${game.currentBid}${game.highestBidder == null ? '' : ' · ${game.highestBidder} (${game.teamOfPlayer(game.highestBidder!)}) leading'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFD75A),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (game.currentPlayer case final current?)
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text(
              "${game.activeTeam} — ${game.playerSeat(current.name)} · ${current.name}'s turn",
              style: const TextStyle(
                color: Color(0xFF9DBBFF),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    ),
  );

  Widget _balancesCard() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF142958),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'PLAYER BALANCES',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        for (final team in <String>['Team A', 'Team B'])
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.shield_rounded,
                  size: 16,
                  color: team == 'Team A'
                      ? const Color(0xFF62A9FF)
                      : const Color(0xFFFF789A),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    '$team WALLET',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .7,
                    ),
                  ),
                ),
                const _SpinningCoin(size: 15),
                const SizedBox(width: 5),
                Text(
                  '${game.teamCoins(team)}',
                  style: const TextStyle(
                    color: Color(0xFFFFD75A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        const Divider(color: Color(0x334D6AA4), height: 12),
        for (var i = 0; i < game.players.length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(vertical: 3),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: game.players[i].name == game.currentPlayer?.name
                  ? const Color(0xFF294B86)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: game.players[i].name == game.currentPlayer?.name
                    ? const Color(0xFFFFD75A)
                    : Colors.transparent,
              ),
              boxShadow: game.players[i].name == game.currentPlayer?.name
                  ? <BoxShadow>[
                      BoxShadow(
                        color: const Color(0xFFFFD75A).withValues(alpha: .16),
                        blurRadius: 12,
                      ),
                    ]
                  : const <BoxShadow>[],
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.circle,
                  size: 9,
                  color: i < game.players.length ~/ 2
                      ? const Color(0xFF62A9FF)
                      : const Color(0xFFFF789A),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${game.players[i].name}${game.players[i].name == game.currentPlayer?.name ? ' · TURN' : ''}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          game.players[i].name == game.currentPlayer?.name
                          ? FontWeight.w900
                          : FontWeight.w600,
                    ),
                  ),
                ),
                _SpinningCoin(
                  key: ValueKey<int>(game.players[i].coins),
                  size: 17,
                ),
                const SizedBox(width: 5),
                Text(
                  '${game.players[i].coins}',
                  style: const TextStyle(
                    color: Color(0xFFFFD75A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );

  Widget _turnControls(GamePlayer player, int pendingBid) => AnimatedContainer(
    key: ValueKey<String>(player.name),
    duration: const Duration(milliseconds: 320),
    curve: Curves.easeOut,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1B2D66),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFFFD75A), width: 1.4),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: const Color(0xFF638CFF).withValues(alpha: .22),
          blurRadius: 18,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          '${game.activeTeam} — ${game.playerSeat(player.name)} · ${player.name}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your balance: ${player.coins} coins',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 14),
        const Text(
          'Choose a bid increase, then confirm the exact amount:',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          children: <Widget>[
            for (final amount in <int>[5, 10])
              ChoiceChip(
                label: Text('+$amount Coins'),
                selected: _selectedIncrement == amount,
                onSelected:
                    game.currentBid == 0 && amount < BidChallengeGame.openingBid
                    ? null
                    : (_) => setState(() => _selectedIncrement = amount),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Your bid will be ₹$pendingBid',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFFFD75A),
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          key: const Key('submit-auction-bid'),
          onPressed: pendingBid <= player.coins
              ? () => _act(() => game.placeBid(player.name, _selectedIncrement))
              : null,
          icon: const Icon(Icons.trending_up_rounded),
          label: const Text('Increase Bid'),
          style: _primaryStyle,
        ),
        if (game.currentBid > 0 && game.highestBidder != null) ...<Widget>[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('purchase-current-bid'),
            onPressed: () => _act(() => game.purchaseCurrentBid(player.name)),
            icon: const Icon(Icons.shopping_bag_rounded),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Sell to ${game.teamOfPlayer(game.highestBidder!)} · ₹${game.currentBid} ',
                ),
                _SpinningCoin(key: ValueKey<int>(game.currentBid), size: 16),
                const Text(' coins'),
              ],
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF9CF2B8),
              side: const BorderSide(color: Color(0xFF65CF90)),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ],
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _act(() => game.pass(player.name)),
          icon: const Icon(Icons.skip_next_rounded),
          label: const Text('Pass'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white70,
            side: BorderSide(color: Colors.white.withValues(alpha: .35)),
            padding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      ],
    ),
  );

  Widget _historyCard({bool showAll = false}) {
    final entries = showAll
        ? game.roundResults
              .expand(
                (result) => <String>[
                  'Round ${result.roundNumber} · ${result.itemName}',
                  ...result.history,
                  result.sold
                      ? 'Sold to ${result.winnerName} for ${result.winningBid} coins.'
                      : 'Unsold',
                ],
              )
              .toList()
        : game.auctionHistory;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF142958),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'BIDDING HISTORY',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 7),
          if (entries.isEmpty)
            const Text(
              'No bids yet. The starting bid is 0 coins.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          for (final entry in entries.reversed.take(
            showAll ? entries.length : 8,
          ))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(
                '• $entry',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _resultBanner(RoundResult result) => TweenAnimationBuilder<double>(
    key: ValueKey<int>(result.roundNumber),
    tween: Tween<double>(begin: .65, end: 1),
    duration: const Duration(milliseconds: 520),
    curve: Curves.elasticOut,
    builder: (context, scale, child) =>
        Transform.scale(scale: scale, child: child),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1D2C63),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            result.sold
                ? Icons.emoji_events_rounded
                : Icons.hourglass_empty_rounded,
            color: result.sold ? const Color(0xFFFFD75A) : Colors.white70,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              result.sold
                  ? 'SOLD · ${result.itemName} → ${game.teamOfPlayer(result.winnerName)} · ${result.winnerName} for ${result.winningBid} coins'
                  : 'UNSOLD · ${result.itemName}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF9CF2B8),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  void _act(RoundResult? Function() action) {
    try {
      GameAudioService.instance.play(GameSound.selection);
      final result = action();
      setState(() {
        _selectedIncrement = game.currentBid == 0
            ? BidChallengeGame.openingBid
            : 5;
        if (result != null) widget.session.lastRound = result;
      });
    } on ArgumentError catch (error) {
      _showError(error.toString());
    } on StateError catch (error) {
      _showError(error.message);
    }
  }

  void _showError(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _restart() async {
    await widget.session.restartGame();
    if (mounted) {
      setState(() => _selectedIncrement = BidChallengeGame.openingBid);
    }
  }

  Widget _itemImage(GameItem? item) {
    final localImage = item == null ? null : _localImageByItemId[item.id];
    if (localImage != null) {
      return Image.asset(
        localImage,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _missingImage(item!.name),
      );
    }
    return _missingImage(item?.name ?? 'No item available');
  }

  Widget _missingImage(String name) => Container(
    color: const Color(0xFF0A2048),
    alignment: Alignment.center,
    padding: const EdgeInsets.all(10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(
          Icons.image_not_supported_outlined,
          color: Color(0xFF9DBBFF),
          size: 30,
        ),
        const SizedBox(height: 5),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );

  ButtonStyle get _primaryStyle => ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 14),
    backgroundColor: const Color(0xFF5A43F2),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}

class _SpinningCoin extends StatelessWidget {
  const _SpinningCoin({super.key, required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: 1),
    duration: const Duration(milliseconds: 460),
    curve: Curves.easeOutCubic,
    builder: (context, progress, child) => Transform.rotate(
      angle: progress * math.pi * 2,
      child: Transform.scale(scale: .82 + progress * .18, child: child),
    ),
    child: Icon(
      Icons.monetization_on_rounded,
      color: const Color(0xFFFFD75A),
      size: size,
      shadows: const <Shadow>[Shadow(color: Color(0xAAFFB000), blurRadius: 7)],
    ),
  );
}

class _ArenaPainter extends CustomPainter {
  const _ArenaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFF050D24),
          Color(0xFF102B55),
          Color(0xFF070E23),
        ],
      ).createShader(bounds);
    canvas.drawRect(bounds, background);

    final glow = Paint()
      ..color = const Color(0xFF5986FF).withValues(alpha: .08);
    canvas.drawCircle(
      Offset(size.width * .5, size.height * .44),
      size.width * .48,
      glow,
    );

    final lightPaint = Paint()
      ..color = const Color(0xFFFFD75A).withValues(alpha: .075);
    final spotlights = <Path>[
      Path()
        ..moveTo(size.width * .08, 0)
        ..lineTo(size.width * .32, 0)
        ..lineTo(size.width * .52, size.height * .60)
        ..lineTo(size.width * .30, size.height * .60)
        ..close(),
      Path()
        ..moveTo(size.width * .75, 0)
        ..lineTo(size.width * .94, 0)
        ..lineTo(size.width * .69, size.height * .58)
        ..lineTo(size.width * .51, size.height * .58)
        ..close(),
    ];
    for (final path in spotlights) {
      canvas.drawPath(path, lightPaint);
    }

    final stageY = size.height * .87;
    final crowdPaint = Paint()
      ..color = const Color(0xFF030817).withValues(alpha: .82);
    final crowdStep = math.max(14.0, size.width / 55).toDouble();
    for (var x = -crowdStep; x < size.width + crowdStep; x += crowdStep) {
      final stagger = (x / crowdStep).floor().isEven ? 0.0 : 9.0;
      canvas.drawCircle(
        Offset(x, stageY - 10 - stagger),
        crowdStep * .29,
        crowdPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, stageY + 5 - stagger),
          width: crowdStep * .74,
          height: crowdStep * .75,
        ),
        crowdPaint,
      );
    }

    final railPaint = Paint()
      ..color = const Color(0xFFFFD75A).withValues(alpha: .45)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(0, stageY - 23),
      Offset(size.width, stageY - 23),
      railPaint,
    );
    for (var i = 0; i < 16; i++) {
      final x = size.width * (i + .5) / 16;
      final y = size.height * (.16 + ((i * 13) % 27) / 100);
      canvas.drawCircle(Offset(x, y), (i % 3 + 1).toDouble(), railPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArenaPainter oldDelegate) => false;
}
