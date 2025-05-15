import '../../../utils/audio_manager.dart';
import '../enums/mole_type.dart';
import 'interfaces/mixin_interface.dart';

mixin GameAudioMixin on MixinInterface {
  final AudioManager audioManager = AudioManager();
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _soundVolume = 1.0;
  double _musicVolume = 1.0;

  // Getters
  bool get isSoundEnabled => _soundEnabled;
  bool get isMusicEnabled => _musicEnabled;
  double get soundVolume => _soundVolume;
  double get musicVolume => _musicVolume;

  // Sound methods
  void playHitSound(MoleType moleType) {
    if (!_soundEnabled) return;
    audioManager.playHitSound(moleType);
  }

  void playMissSound() {
    if (!_soundEnabled) return;
    audioManager.playMissSound();
  }

  void playGameOverSound() {
    if (!_soundEnabled) return;
    audioManager.playGameOverSound();
  }

  void playPowerUpSound() {
    if (!_soundEnabled) return;
    audioManager.playPowerUpSound();
  }

  void playBackgroundMusic() {
    if (!_musicEnabled) return;
    audioManager.playBackgroundMusic();
  }

  void stopBackgroundMusic() {
    audioManager.stopBackgroundMusic();
  }

  void pauseBackgroundMusic() {
    audioManager.pauseBackgroundMusic();
  }

  void resumeBackgroundMusic() {
    if (!_musicEnabled) return;
    audioManager.resumeBackgroundMusic();
  }

  // Settings
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    notifyListenersInternal();
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (enabled) {
      resumeBackgroundMusic();
    } else {
      stopBackgroundMusic();
    }
    notifyListenersInternal();
  }

  void setSoundVolume(double volume) {
    _soundVolume = volume;
    audioManager.setSoundVolume(volume);
    notifyListenersInternal();
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume;
    audioManager.setMusicVolume(volume);
    notifyListenersInternal();
  }
}