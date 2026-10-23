import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game_arena/audio/game_audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'audio preferences default on, persist independently, and reload',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      var preferences = AudioPreferences(await SharedPreferences.getInstance());

      expect(preferences.musicEnabled, isTrue);
      expect(preferences.effectsEnabled, isTrue);

      await preferences.setMusicEnabled(false);
      preferences = AudioPreferences(await SharedPreferences.getInstance());
      expect(preferences.musicEnabled, isFalse);
      expect(preferences.effectsEnabled, isTrue);

      await preferences.setEffectsEnabled(false);
      await preferences.setMusicEnabled(true);
      preferences = AudioPreferences(await SharedPreferences.getInstance());
      expect(preferences.musicEnabled, isTrue);
      expect(preferences.effectsEnabled, isFalse);
    },
  );
}
