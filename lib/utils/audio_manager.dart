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
import 'game_provider.dart';  // MoleType enum'ı için import ekliyoruz

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  
  AudioManager._internal();
  
  final AudioPlayer _musicPlayer = AudioPlayer();
  final Set<AudioPlayer> _activePlayers = {};
  final int _maxConcurrentSounds = 5; // Maksimum eşzamanlı ses sayısı
  
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _isDisposed = false;
  
  // Ses efektleri - tam dosya yolları
  static const String hitSound = 'audio/hit_normal.wav';
  static const String hitGoldenSound = 'audio/hit_golden.mp3';
  static const String hitSpeedySound = 'audio/hit speedy.wav';
  static const String hitToughSound = 'audio/hit_tough.mp3';
  static const String hitHealingSound = 'audio/hit_healing.mp3';
  static const String missSound = 'audio/miss.wav';
  static const String gameOverSound = 'audio/game_over.mp3';
  static const String buttonSound = 'audio/button_click.wav';
  static const String comboSound = 'audio/combo.mp3';
  static const String powerUpSound = 'audio/power_up.wav';
  
  // Müzik
  static const String backgroundMusic = 'audio/background_music.mp3';
  
  void initialize() {
    if (_isDisposed) return;
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }
  
  void setSoundEnabled(bool enabled) {
    if (_isDisposed) return;
    _soundEnabled = enabled;
    if (!enabled) {
      _stopAllSounds();
    }
  }
  
  void setMusicEnabled(bool enabled) {
    if (_isDisposed) return;
    _musicEnabled = enabled;
    if (enabled) {
      playBackgroundMusic();
    } else {
      _musicPlayer.stop();
      _musicPlayer.setVolume(1.0);
    }
  }
  
  void _stopAllSounds() {
    if (_isDisposed) return;
    
    final playersToCleanup = List<AudioPlayer>.from(_activePlayers);
    for (var player in playersToCleanup) {
      _cleanupPlayer(player);
    }
    _activePlayers.clear();
  }
  
  void _cleanupOldestPlayer() {
    if (_isDisposed || _activePlayers.isEmpty) return;
    
    final oldestPlayer = _activePlayers.first;
    _cleanupPlayer(oldestPlayer);
  }
  
  Future<void> playSound(String soundName) async {
    if (_isDisposed || !_soundEnabled) return;
    
    if (_activePlayers.length >= _maxConcurrentSounds) {
      _cleanupOldestPlayer();
    }
    
    AudioPlayer? player;
    try {
      player = AudioPlayer();
      _activePlayers.add(player);
      
      final source = AssetSource(soundName);
      
      // Ses çalma işlemini başlat
      await player.play(source);
      
      // Ses çalma durumunu izle
      player.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed || 
            state == PlayerState.stopped || 
            state == PlayerState.disposed) {
          if (!_isDisposed && _activePlayers.contains(player)) {
            _cleanupPlayer(player!);
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Ses çalınırken hata oluştu: $e - Ses dosyası: $soundName');
      }
      if (player != null) {
        _cleanupPlayer(player);
      }
    }
  }
  
  void _cleanupPlayer(AudioPlayer player) {
    if (_isDisposed) return;
    
    try {
      if (_activePlayers.contains(player)) {
        player.stop();
        player.dispose();
        _activePlayers.remove(player);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ses temizlenirken hata oluştu: $e');
      }
    }
  }
  
  Future<void> playHitSound(MoleType moleType) async {
    if (_isDisposed || !_soundEnabled) return;
    try {
      switch (moleType) {
        case MoleType.normal:
          await playSound(hitSound);
          break;
        case MoleType.golden:
          await playSound(hitGoldenSound);
          break;
        case MoleType.speedy:
          await playSound(hitSpeedySound);
          break;
        case MoleType.tough:
          await playSound(hitToughSound);
          break;
        case MoleType.healing:
          await playSound(hitHealingSound);
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Vuruş sesi çalınırken hata oluştu: $e - Köstebek türü: $moleType');
      }
    }
  }
  
  Future<void> playMissSound() async {
    if (_isDisposed || !_soundEnabled) return;
    try {
      await playSound(missSound);
    } catch (e) {
      if (kDebugMode) {
        print('Kaçırma sesi çalınırken hata oluştu: $e');
      }
    }
  }
  
  Future<void> playGameOverSound() async {
    if (_isDisposed || !_soundEnabled) return;
    try {
      await playSound(gameOverSound);
    } catch (e) {
      if (kDebugMode) {
        print('Oyun sonu sesi çalınırken hata oluştu: $e');
      }
    }
  }
  
  Future<void> playButtonSound() async {
    if (_isDisposed || !_soundEnabled) return;
    try {
      await playSound(buttonSound);
    } catch (e) {
      if (kDebugMode) {
        print('Buton sesi çalınırken hata oluştu: $e');
      }
    }
  }

  Future<void> playComboSound() async {
    if (_isDisposed || !_soundEnabled) return;
    try {
      await playSound(comboSound);
    } catch (e) {
      if (kDebugMode) {
        print('Combo sesi çalınırken hata oluştu: $e');
      }
    }
  }

  Future<void> playPowerUpSound() async {
    if (_isDisposed || !_soundEnabled) return;
    try {
      await playSound(powerUpSound);
    } catch (e) {
      if (kDebugMode) {
        print('Güçlendirme sesi çalınırken hata oluştu: $e');
      }
    }
  }
  
  Future<void> playBackgroundMusic() async {
    if (_isDisposed || !_musicEnabled) return;
    
    try {
      if (_musicPlayer.state == PlayerState.playing) {
        await _musicPlayer.setVolume(1.0);
        return;
      }
      
      await _musicPlayer.play(AssetSource(backgroundMusic));
      await _musicPlayer.setVolume(1.0);
    } catch (e) {
      if (kDebugMode) {
        print('Müzik çalınırken hata oluştu: $e');
      }
    }
  }
  
  Future<void> lowerBackgroundMusicVolume() async {
    if (_isDisposed || !_musicEnabled) return;
    
    try {
      await _musicPlayer.setVolume(0.2);
    } catch (e) {
      if (kDebugMode) {
        print('Müzik sesi ayarlanırken hata oluştu: $e');
      }
    }
  }
  
  Future<void> resetBackgroundMusicVolume() async {
    if (_isDisposed || !_musicEnabled) return;
    
    try {
      await _musicPlayer.setVolume(1.0);
    } catch (e) {
      if (kDebugMode) {
        print('Müzik sesi ayarlanırken hata oluştu: $e');
      }
    }
  }
  
  void dispose() {
    if (_isDisposed) return;
    
    _isDisposed = true;
    _stopAllSounds();
    
    try {
      _musicPlayer.stop();
      _musicPlayer.dispose();
    } catch (e) {
      if (kDebugMode) {
        print('Müzik oynatıcı dispose edilirken hata oluştu: $e');
      }
    }
  }
}