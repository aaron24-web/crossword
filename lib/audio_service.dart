import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Servicio centralizado para manejar música y efectos de sonido
class AudioService {
  // Singleton pattern
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // Players separados para música y efectos
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // Estado
  bool _musicEnabled = true;
  bool _soundEnabled = true;
  double _musicVolume = 0.7;
  double _sfxVolume = 0.8;

  // Getters
  bool get musicEnabled => _musicEnabled;
  bool get soundEnabled => _soundEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  /// Inicializar el servicio de audio
  Future<void> initialize() async {
    // Configurar el player de música para loop
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
    _musicPlayer.setVolume(_musicVolume);

    // Configurar el player de efectos
    _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    _sfxPlayer.setVolume(_sfxVolume);

    debugPrint('🎵 AudioService initialized');
  }

  /// Reproducir música de fondo
  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;

    try {
      await _musicPlayer.play(
        AssetSource('audio/music/background_music.mp3'),
      );
      debugPrint('🎵 Background music started');
    } catch (e) {
      debugPrint('❌ Error playing background music: $e');
    }
  }

  /// Pausar música de fondo
  Future<void> pauseBackgroundMusic() async {
    await _musicPlayer.pause();
    debugPrint('⏸️ Background music paused');
  }

  /// Reanudar música de fondo
  Future<void> resumeBackgroundMusic() async {
    if (!_musicEnabled) return;
    await _musicPlayer.resume();
    debugPrint('▶️ Background music resumed');
  }

  /// Detener música de fondo
  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
    debugPrint('⏹️ Background music stopped');
  }

  /// Reproducir efecto de sonido
  Future<void> playSoundEffect(SoundEffect effect) async {
    if (!_soundEnabled) return;

    try {
      await _sfxPlayer.play(
        AssetSource('audio/sfx/${effect.filename}'),
      );
    } catch (e) {
      debugPrint('❌ Error playing sound effect ${effect.filename}: $e');
    }
  }

  /// Activar/desactivar música
  void toggleMusic(bool enabled) {
    _musicEnabled = enabled;
    if (enabled) {
      resumeBackgroundMusic();
    } else {
      pauseBackgroundMusic();
    }
    debugPrint('🎵 Music ${enabled ? "enabled" : "disabled"}');
  }

  /// Activar/desactivar efectos de sonido
  void toggleSound(bool enabled) {
    _soundEnabled = enabled;
    debugPrint('🔊 Sound effects ${enabled ? "enabled" : "disabled"}');
  }

  /// Cambiar volumen de música
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _musicPlayer.setVolume(_musicVolume);
    debugPrint('🎵 Music volume: ${(_musicVolume * 100).toInt()}%');
  }

  /// Cambiar volumen de efectos
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    _sfxPlayer.setVolume(_sfxVolume);
    debugPrint('🔊 SFX volume: ${(_sfxVolume * 100).toInt()}%');
  }

  /// Limpiar recursos
  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _sfxPlayer.dispose();
    debugPrint('🗑️ AudioService disposed');
  }
}

/// Enum para los efectos de sonido disponibles
enum SoundEffect {
  buttonClick('button_click.mp3'),
  wordCorrect('word_correct.mp3'),
  wordWrong('word_wrong.mp3'),
  puzzleComplete('puzzle_complete.mp3'),
  letterType('letter_type.mp3');

  const SoundEffect(this.filename);
  final String filename;
}
