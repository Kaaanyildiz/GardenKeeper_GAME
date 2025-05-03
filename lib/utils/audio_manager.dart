/*
 * Copyright © 2025 Mehmet Kaan YILDIZ
 * Garden Keeper - Köstebek vurma oyunu
 * Tüm hakları saklıdır.
 * 
 * Bu yazılım, MIT Lisansı altında lisanslanmıştır.
 * Lisans bilgisi için LICENSE dosyasını inceleyiniz.
 */

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  
  AudioManager._internal();
  
  final AudioPlayer _effectsPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  
  // Ses efektleri
  static const String hitSound = 'hit.mp3';
  static const String missSound = 'miss.mp3';
  static const String gameOverSound = 'game_over.mp3';
  static const String buttonSound = 'button.mp3';
  
  // Müzik
  static const String backgroundMusic = 'background_music.mp3';
  
  void initialize() {
    // Ses motoru başlatılıyor
    _effectsPlayer.setReleaseMode(ReleaseMode.stop);
    _musicPlayer.setReleaseMode(ReleaseMode.loop); // Müzik tekrar eder
  }
  
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    if (!enabled) {
      _effectsPlayer.stop();
    }
  }
  
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (enabled) {
      playBackgroundMusic();
    } else {
      _musicPlayer.stop();
    }
  }
  
  Future<void> playSound(String soundName) async {
    if (!_soundEnabled) return;
    
    try {
      await _effectsPlayer.play(AssetSource('audio/$soundName'));
    } catch (e) {
      if (kDebugMode) {
        print('Ses çalınırken hata oluştu: $e');
      }
    }
  }
  
  Future<void> playHitSound() async {
    await playSound(hitSound);
  }
  
  Future<void> playMissSound() async {
    await playSound(missSound);
  }
  
  Future<void> playGameOverSound() async {
    await playSound(gameOverSound);
  }
  
  Future<void> playButtonSound() async {
    await playSound(buttonSound);
  }
  
  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;
    
    try {
      await _musicPlayer.play(AssetSource('audio/$backgroundMusic'));
    } catch (e) {
      if (kDebugMode) {
        print('Müzik çalınırken hata oluştu: $e');
      }
    }
  }
  
  void dispose() {
    _effectsPlayer.dispose();
    _musicPlayer.dispose();
  }
}