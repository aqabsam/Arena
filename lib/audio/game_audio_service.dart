import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameSound {
  tap,
  navigation,
  selection,
  correct,
  incorrect,
  gameStart,
  victory,
}

class AudioPreferences {
  AudioPreferences(this._preferences);

  static const _musicKey = 'game_arena_background_music_enabled';
  static const _effectsKey = 'game_arena_touch_effects_enabled';
  final SharedPreferences _preferences;

  bool get musicEnabled => _preferences.getBool(_musicKey) ?? true;
  bool get effectsEnabled => _preferences.getBool(_effectsKey) ?? true;

  Future<void> setMusicEnabled(bool enabled) async {
    await _preferences.setBool(_musicKey, enabled);
  }

  Future<void> setEffectsEnabled(bool enabled) async {
    await _preferences.setBool(_effectsKey, enabled);
  }
}

class GameAudioService {
  GameAudioService._();

  static final GameAudioService instance = GameAudioService._();

  static const _musicAsset = 'audio/game_audio.mp3';
  final AudioPlayer _music = AudioPlayer(playerId: 'game-arena-music');
  final AudioPlayer _effects = AudioPlayer(playerId: 'game-arena-effects');
  AudioPreferences? _preferences;
  bool _musicStarted = false;
  DateTime _lastEffectAt = DateTime.fromMillisecondsSinceEpoch(0);
  GameSound? _lastSound;
  bool _initialized = false;

  bool get musicEnabled => _preferences?.musicEnabled ?? true;
  bool get effectsEnabled => _preferences?.effectsEnabled ?? true;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      _preferences = AudioPreferences(await SharedPreferences.getInstance());
      await _music.setPlayerMode(PlayerMode.mediaPlayer);
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(0.38);
      await _effects.setPlayerMode(PlayerMode.lowLatency);
      await _effects.setReleaseMode(ReleaseMode.stop);
      if (musicEnabled) unawaited(_startMusic());
    } on Object {
      // Audio is optional; playback setup failures must never block the game.
    }
  }

  Future<void> setMusicEnabled(bool enabled) async {
    final preferences = _preferences;
    if (preferences == null) return;
    try {
      await preferences.setMusicEnabled(enabled);
      if (enabled) {
        if (_musicStarted) {
          await _music.resume();
        } else {
          await _startMusic();
        }
      } else if (_musicStarted) {
        await _music.pause();
      }
    } on Object {
      // Keep the preference change from affecting gameplay if audio fails.
    }
  }

  Future<void> setEffectsEnabled(bool enabled) async {
    final preferences = _preferences;
    if (preferences == null) return;
    try {
      await preferences.setEffectsEnabled(enabled);
      if (!enabled) await _effects.stop();
    } on Object {
      // Keep the preference change from affecting gameplay if audio fails.
    }
  }

  Future<void> _startMusic() async {
    if (!musicEnabled) return;
    try {
      await _music.play(AssetSource(_musicAsset), volume: 0.38);
      _musicStarted = true;
      if (!musicEnabled) await _music.pause();
    } on Object {
      _musicStarted = false;
    }
  }

  Future<void> play(GameSound sound) async {
    if (!effectsEnabled) return;
    final now = DateTime.now();
    if (sound == _lastSound &&
        now.difference(_lastEffectAt).inMilliseconds < 55) {
      return;
    }
    _lastEffectAt = now;
    _lastSound = sound;
    try {
      await _effects.stop();
      await _effects.play(AssetSource('audio/${_assetName(sound)}.wav'));
    } on Object {
      // Missing/corrupt optional sound effects are safely ignored.
    }
  }

  String _assetName(GameSound sound) => switch (sound) {
    GameSound.tap => 'tap',
    GameSound.navigation => 'select',
    GameSound.selection => 'select',
    GameSound.correct => 'correct',
    GameSound.incorrect => 'incorrect',
    GameSound.gameStart => 'start',
    GameSound.victory => 'victory',
  };
}
