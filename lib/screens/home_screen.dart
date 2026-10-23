import 'package:flutter/material.dart';

import '../audio/game_audio_service.dart';
import '../game/game_session.dart';
import 'mini_games_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071B46),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2947A1), Color(0xFF102667)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF132765),
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: const Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'OFFLINE PARTY GAMES',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.6,
                          ),
                        ),
                        _CoinPill(),
                      ],
                    ),
                    Icon(
                      Icons.workspace_premium_rounded,
                      color: Color(0xFFFFD75A),
                      size: 44,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'GAME',
                      style: TextStyle(
                        color: Color(0xFFFFD75A),
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'ARENA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        shadows: <Shadow>[
                          Shadow(color: Color(0xFF5E82FF), blurRadius: 12),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Play • Bid • Win',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'CHOOSE YOUR GAME',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _GameTile(
                title: 'Bid Challenge',
                subtitle: 'Guess, bid, and win items',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC928), Color(0xFFFF8C16)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Icons.gavel_rounded,
                onTap: () => Navigator.of(context).pushNamed('/category'),
              ),
              const SizedBox(height: 14),
              _GameTile(
                title: 'Mini Games',
                subtitle: '11 quick games for two players',
                gradient: const LinearGradient(
                  colors: [Color(0xFF7047FF), Color(0xFF2375F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Icons.sports_esports_rounded,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MiniGamesScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () {
                  GameAudioService.instance.play(GameSound.tap);
                  showDialog<void>(
                    context: context,
                    builder: (context) => _SettingsDialog(),
                  );
                },
                icon: const Icon(Icons.settings_rounded),
                label: const Text('Settings'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: Color(0xFF5277D9)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.sports_esports_rounded,
                    color: Color(0xFF9DBBFF),
                    size: 22,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'Offline  •  Single Device  •  Just Fun!',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Pick a game and let the bidding begin',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsDialog extends StatefulWidget {
  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  final _audio = GameAudioService.instance;
  late bool _musicEnabled = _audio.musicEnabled;
  late bool _effectsEnabled = _audio.effectsEnabled;

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            colors: [Color(0xFF172D66), Color(0xFF0B1A3B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFF4D75D5), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99030C24),
              blurRadius: 30,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF42A5FF), Color(0xFF714BFF)],
                      ),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 13),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Make the arena yours',
                          style: TextStyle(
                            color: Color(0xFFB7C8EF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close settings',
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: .08),
                      foregroundColor: Colors.white70,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'AUDIO',
                style: TextStyle(
                  color: Color(0xFF8FADEB),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 10),
              _AudioSettingTile(
                icon: Icons.music_note_rounded,
                title: 'Background Music',
                subtitle: 'Loop the Game Arena theme',
                value: _musicEnabled,
                color: const Color(0xFF67C8FF),
                onChanged: (enabled) async {
                  GameAudioService.instance.play(GameSound.tap);
                  setState(() => _musicEnabled = enabled);
                  await _audio.setMusicEnabled(enabled);
                },
              ),
              const SizedBox(height: 10),
              _AudioSettingTile(
                icon: Icons.touch_app_rounded,
                title: 'Touch Sound Effects',
                subtitle: 'Taps, game actions, and wins',
                value: _effectsEnabled,
                color: const Color(0xFFC49BFF),
                onChanged: (enabled) async {
                  GameAudioService.instance.play(GameSound.tap);
                  setState(() => _effectsEnabled = enabled);
                  await _audio.setEffectsEnabled(enabled);
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF071630).withValues(alpha: .72),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .08),
                  ),
                ),
                child: const Row(
                  children: <Widget>[
                    Icon(
                      Icons.wifi_off_rounded,
                      color: Color(0xFF79E5B0),
                      size: 18,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Offline play  •  Virtual coins only',
                        style: TextStyle(
                          color: Color(0xFFD5E0FA),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _AudioSettingTile extends StatelessWidget {
  const _AudioSettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      color: value ? color.withValues(alpha: .10) : const Color(0xFF10234B),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(
        color: value ? color.withValues(alpha: .48) : Colors.white12,
      ),
    ),
    child: Row(
      children: <Widget>[
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .15),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFFA9B9D9), fontSize: 10),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch.adaptive(
          value: value,
          activeTrackColor: color,
          onChanged: onChanged,
        ),
      ],
    ),
  );
}

class _CoinPill extends StatelessWidget {
  const _CoinPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD75A).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD75A).withValues(alpha: 0.4),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.monetization_on_rounded,
            color: Color(0xFFFFD75A),
            size: 16,
          ),
          SizedBox(width: 5),
          Text(
            '100 COINS / PLAYER',
            style: TextStyle(
              color: Color(0xFFFFD75A),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  const _GameTile({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPrimary = title == 'Bid Challenge';
    final foreground = isPrimary ? const Color(0xFF19244A) : Colors.white;
    return GestureDetector(
      onTap: () {
        GameAudioService.instance.play(GameSound.navigation);
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: gradient,
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF122B68),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: foreground.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: foreground, size: 28),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: foreground.withValues(alpha: 0.75),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: foreground, size: 28),
          ],
        ),
      ),
    );
  }
}
