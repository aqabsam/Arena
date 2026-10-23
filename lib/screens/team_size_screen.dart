import 'package:flutter/material.dart';

import '../audio/game_audio_service.dart';
import '../game/game_session.dart';

class TeamSizeScreen extends StatefulWidget {
  const TeamSizeScreen({super.key, required this.session});

  final GameSession session;

  @override
  State<TeamSizeScreen> createState() => _TeamSizeScreenState();
}

class _TeamSizeScreenState extends State<TeamSizeScreen> {
  late int selectedSize;
  bool customSelected = false;
  final TextEditingController customSizeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedSize = widget.session.teamSize;
  }

  @override
  void dispose() {
    customSizeController.dispose();
    super.dispose();
  }

  void _continue() {
    GameAudioService.instance.play(GameSound.navigation);
    final size = customSelected
        ? int.tryParse(customSizeController.text)
        : selectedSize;
    if (size == null || size < 2 || size > 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Choose 3–7 players or enter a custom size from 2 to 12.',
          ),
        ),
      );
      return;
    }
    widget.session.teamSize = size;
    widget.session.setPlayersFromTeamSize(size);
    Navigator.of(context).pushNamed('/players');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bid Challenge')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            children: <Widget>[
              const Icon(
                Icons.groups_rounded,
                color: Color(0xFF9DBBFF),
                size: 62,
              ),
              const SizedBox(height: 14),
              const Text(
                'Select Team Size',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose the number of players on each team.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 26),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  for (final size in <int>[3, 4, 5, 6, 7])
                    _SizeTile(
                      label: '$size',
                      selected: !customSelected && selectedSize == size,
                      onTap: () => setState(() {
                        selectedSize = size;
                        customSelected = false;
                      }),
                    ),
                  _SizeTile(
                    label: 'Custom',
                    selected: customSelected,
                    onTap: () => setState(() => customSelected = true),
                  ),
                ],
              ),
              if (customSelected) ...<Widget>[
                const SizedBox(height: 18),
                TextField(
                  controller: customSizeController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Players per team (2–12)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF0D2456),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A43F2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Both teams start with 100 coins per player.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SizeTile extends StatelessWidget {
  const _SizeTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label == 'Custom' ? 'Custom team size' : '$label players per team',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: label == 'Custom' ? 104 : 68,
          height: 68,
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF3D8BFF), Color(0xFF4C35FF)],
                  )
                : const LinearGradient(
                    colors: [Color(0xFF1D2C63), Color(0xFF14275A)],
                  ),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected
                  ? const Color(0xFF4A8CFF)
                  : const Color(0xFF2877E8),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
