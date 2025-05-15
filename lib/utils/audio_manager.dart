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
  
  AudioManager._internal() {
    _initMusicPlayer();
  }
  
  late AudioPlayer _musicPlayer;
  final Set<AudioPlayer> _activePlayers = {};
  final int _maxConcurrentSounds = 5; // Maksimum eşzamanlı ses sayısı
  
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _isDisposed = false;
  double _soundVolume = 1.0;
  double _musicVolume = 1.0;
  bool _isMusicInitialized = false;
  
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
  
  void _initMusicPlayer() {
    _musicPlayer = AudioPlayer();
  }

  Future<void> _recreateMusicPlayer() async {
    try {
      await _musicPlayer.dispose();
      _initMusicPlayer();
      _isMusicInitialized = false;
    } catch (e) {
      if (kDebugMode) {
        print('Müzik oynatıcı yeniden oluşturulurken hata: $e');
      }
    }
  }
  
  void initialize() {
    if (_isDisposed) return;
    _initializeBackgroundMusic();
  }
  
  Future<void> _initializeBackgroundMusic() async {
    if (_isDisposed || _isMusicInitialized) return;
    
    try {
      await _musicPlayer.stop(); // Önce durduralım
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setSourceAsset(backgroundMusic);
      await _musicPlayer.setVolume(_musicVolume);
      _isMusicInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Arkaplan müziği başlatılırken hata: $e');
      }
      _isMusicInitialized = false;
      // Hata durumunda müzik oynatıcıyı yeniden oluştur
      await _recreateMusicPlayer();
    }
  }
  
  void setSoundEnabled(bool enabled) {
    if (_isDisposed) return;
    _soundEnabled = enabled;
    if (!enabled) {
      _stopAllSounds();
    }
  }
  
  void setMusicEnabled(bool enabled) async {
    if (_isDisposed) return;
    _musicEnabled = enabled;
    
    try {
      if (enabled) {
        await playBackgroundMusic();
      } else {
        // Müziği tamamen durdur
        await _musicPlayer.stop();
        _isMusicInitialized = false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Müzik durumu değiştirilirken hata: $e');
      }
    }
  }
  
  Future<void> _stopAllSounds() async {
    if (_isDisposed) return;
    
    final playersToCleanup = List<AudioPlayer>.from(_activePlayers);
    for (var player in playersToCleanup) {
      try {
        await player.stop();
        await player.dispose();
      } catch (e) {
        if (kDebugMode) {
          print('Ses durdurulurken hata: $e');
        }
      }
    }
    _activePlayers.clear();
  }
  
  Future<void> _cleanupOldestPlayer() async {
    if (_isDisposed || _activePlayers.isEmpty) return;
    
    final oldestPlayer = _activePlayers.first;
    await _cleanupPlayer(oldestPlayer);
  }
  
  Future<void> _cleanupPlayer(AudioPlayer player) async {
    if (_isDisposed) return;
    
    try {
      if (_activePlayers.contains(player)) {
        await player.stop();
        await player.dispose();
        _activePlayers.remove(player);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ses oynatıcı temizlenirken hata: $e');
      }
      _activePlayers.remove(player);
    }
  }
  
  void setSoundVolume(double volume) {
    if (_isDisposed) return;
    _soundVolume = volume.clamp(0.0, 1.0);
    // Aktif ses efektlerinin seviyesini güncelle
    for (var player in _activePlayers) {
      player.setVolume(_soundVolume);
    }
  }
  
  void setMusicVolume(double volume) {
    if (_isDisposed) return;
    _musicVolume = volume.clamp(0.0, 1.0);
    _musicPlayer.setVolume(_musicVolume);
  }
  
  Future<void> playSound(String soundName) async {
    if (_isDisposed || !_soundEnabled) return;
    
    if (_activePlayers.length >= _maxConcurrentSounds) {
      await _cleanupOldestPlayer();
    }
    
    AudioPlayer? player;
    try {
      player = AudioPlayer();
      
      // Ses seviyesini ayarla
      await player.setVolume(_soundVolume);
      
      // Kaynağı ayarla ve çalmaya başla
      final source = AssetSource(soundName);
      await player.play(source);
      
      _activePlayers.add(player);
      
      // Ses çalma durumunu izle
      player.onPlayerStateChanged.listen((state) async {
        if (state == PlayerState.completed || 
            state == PlayerState.stopped || 
            state == PlayerState.disposed) {
          await _cleanupPlayer(player!);
        }
      });
      
      // 3 saniye sonra otomatik temizleme
      Future.delayed(const Duration(seconds: 3), () async {
        if (_activePlayers.contains(player)) {
          await _cleanupPlayer(player!);
        }
      });
      
    } catch (e) {
      if (kDebugMode) {
        print('Ses çalınırken hata: $e - Ses dosyası: $soundName');
      }
      if (player != null) {
        await _cleanupPlayer(player);
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
      final player = AudioPlayer();
      _activePlayers.add(player);
      
      // Ses seviyesini hemen ayarla
      await player.setVolume(_soundVolume);
      
      // Sesi çal ve temizleme işlemini planla
      await player.play(AssetSource(missSound));
      
      // Ses çalındıktan sonra temizle
      Future.delayed(const Duration(milliseconds: 500), () {
        _cleanupPlayer(player);
      });
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
      final player = AudioPlayer();
      _activePlayers.add(player);
      
      // Ses seviyesini hemen ayarla
      await player.setVolume(_soundVolume);
      
      // Sesi çal ve temizleme işlemini planla
      player.play(AssetSource(buttonSound)).then((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _cleanupPlayer(player);
        });
      });
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
      if (!_isMusicInitialized) {
        await _initializeBackgroundMusic();
      }
      
      if (_musicPlayer.state == PlayerState.playing) {
        return;
      }
      
      await _musicPlayer.setVolume(_musicVolume);
      await _musicPlayer.resume();
    } catch (e) {
      if (kDebugMode) {
        print('Arkaplan müziği çalınırken hata: $e');
      }
      // Hata durumunda yeniden başlatmayı dene
      _isMusicInitialized = false;
      try {
        await _initializeBackgroundMusic();
        await _musicPlayer.resume();
      } catch (retryError) {
        if (kDebugMode) {
          print('Müzik yeniden başlatılırken hata: $retryError');
        }
      }
    }
  }
  
  Future<void> pauseBackgroundMusic() async {
    if (_isDisposed || !_musicEnabled) return;
    
    try {
      if (_musicPlayer.state == PlayerState.playing) {
        await _musicPlayer.pause();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Müzik duraklatılırken hata oluştu: $e');
      }
    }
  }
  
  Future<void> stopBackgroundMusic() async {
    if (_isDisposed) return;
    
    try {
      await _musicPlayer.stop();
      _isMusicInitialized = false;
    } catch (e) {
      if (kDebugMode) {
        print('Müzik durdurulurken hata oluştu: $e');
      }
    }
  }
  
  Future<void> lowerBackgroundMusicVolume() async {
    if (_isDisposed || !_musicEnabled) return;
    
    try {
      // Mevcut ses seviyesinin %20'sine düşür
      await _musicPlayer.setVolume(_musicVolume * 0.2);
    } catch (e) {
      if (kDebugMode) {
        print('Müzik sesi ayarlanırken hata oluştu: $e');
      }
    }
  }
  
  Future<void> resetBackgroundMusicVolume() async {
    if (_isDisposed || !_musicEnabled) return;
    
    try {
      await _musicPlayer.setVolume(_musicVolume);
    } catch (e) {
      if (kDebugMode) {
        print('Müzik sesi ayarlanırken hata oluştu: $e');
      }
    }
  }
  
  void dispose() {
    if (_isDisposed) return;
    
    _isDisposed = true;
    
    try {
      // Önce tüm sesleri durdur
      _stopAllSounds().then((_) {
        // Sonra müziği durdur
        stopBackgroundMusic().then((_) {
          // Tüm aktif ses oynatıcılarını temizle
          for (var player in _activePlayers) {
            try {
              player.stop();
              player.dispose();
            } catch (e) {
              if (kDebugMode) {
                print('Ses oynatıcı temizlenirken hata: $e');
              }
            }
          }
          _activePlayers.clear();
          
          // Son olarak müzik oynatıcısını temizle
          try {
            _musicPlayer.dispose();
          } catch (e) {
            if (kDebugMode) {
              print('Müzik oynatıcı temizlenirken hata: $e');
            }
          }
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print('AudioManager dispose edilirken hata: $e');
      }
    }
  }
}