/*
 * Copyright © 2025 Mehmet Kaan YILDIZ
 * Garden Keeper - Köstebek vurma oyunu
 * Tüm hakları saklıdır.
 * 
 * Bu yazılım, MIT Lisansı altında lisanslanmıştır.
 * Lisans bilgisi için LICENSE dosyasını inceleyiniz.
 */

import 'package:audioplayers/audioplayers.dart';
import '../providers/game/enums/mole_type.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  
  late AudioPlayer _musicPlayer;
  late AudioPlayer _soundPlayer;
  late AudioCache _audioCache;
  bool _isMusicEnabled = true;
  bool _isSoundEnabled = true;
  double _musicVolume = 1.0;
  double _soundVolume = 1.0;
  bool _isInitialized = false;

  AudioManager._internal() {
    initialize();
  }
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _musicPlayer = AudioPlayer();
    _soundPlayer = AudioPlayer();
    _audioCache = AudioCache();
    
    // Başlangıç ayarlarını yap
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _soundPlayer.setVolume(_soundVolume);
    await _musicPlayer.setVolume(_musicVolume);
    
    // Ses dosyalarını yükle
    await _loadSounds();
    
    // Müziği başlat (eğer aktifse)
    if (_isMusicEnabled) {
      await playBackgroundMusic();
    }
    
    _isInitialized = true;
  }
  Future<void> _loadSounds() async {
    try {
      final files = [
        'audio/hit_normal.wav',
        'audio/hit_golden.mp3',
        'audio/hit_healing.mp3',
        'audio/hit_tough.mp3',
        'audio/button.wav',
        'audio/miss.wav',
        'audio/power_up.wav',
        'audio/combo.mp3',
        'audio/game_over.mp3',
        'audio/background_music.mp3'
      ];
      
      // Her dosyayı tek tek dene
      for (var file in files) {
        try {
          await _audioCache.load(file);
          print('$file başarıyla yüklendi'); // Debug için log
        } catch (e) {
          print('$file yüklenirken hata: $e');
        }
      }
    } catch (e) {
      print('Ses dosyaları yüklenirken hata oluştu: $e');
    }
  }

  Future<void> playHitSound(MoleType type) async {
    if (!_isSoundEnabled) return;
    try {
      var fileName = type.toString().split('.').last.toLowerCase();
      var extension = fileName == 'normal' ? 'wav' : 'mp3';
      await _soundPlayer.play(AssetSource('assets/audio/hit_$fileName.$extension'));
      await _soundPlayer.setVolume(_soundVolume);
    } catch (e) {
      print('Hit sesi çalınırken hata oluştu: $e');
    }
  }
  Future<void> playMissSound() async {
    if (!_isSoundEnabled) return;
    try {
      await _soundPlayer.play(AssetSource('assets/audio/miss.wav'));
      await _soundPlayer.setVolume(_soundVolume);
    } catch (e) {
      print('Miss sesi çalınırken hata oluştu: $e');
    }
  }

  Future<void> playGameOverSound() async {
    if (!_isSoundEnabled) return;
    try {
      await _soundPlayer.play(AssetSource('assets/audio/game_over.mp3'));
      await _soundPlayer.setVolume(_soundVolume);
    } catch (e) {
      print('Game over sesi çalınırken hata oluştu: $e');
    }
  }

  Future<void> playButtonSound() async {
    if (!_isSoundEnabled) return;
    try {
      await _soundPlayer.play(AssetSource('assets/audio/button.wav'));
      await _soundPlayer.setVolume(_soundVolume);
    } catch (e) {
      print('Button sesi çalınırken hata oluştu: $e');
    }
  }

  Future<void> playPowerUpSound() async {
    if (!_isSoundEnabled) return;
    try {
      await _soundPlayer.play(AssetSource('assets/audio/power_up.wav'));
      await _soundPlayer.setVolume(_soundVolume);
    } catch (e) {
      print('Power up sesi çalınırken hata oluştu: $e');
    }
  }

  Future<void> playComboSound() async {
    if (!_isSoundEnabled) return;
    try {
      await _soundPlayer.play(AssetSource('assets/audio/combo.mp3'));
      await _soundPlayer.setVolume(_soundVolume);
    } catch (e) {
      print('Combo sesi çalınırken hata oluştu: $e');
    }
  }
  Future<void> playBackgroundMusic() async {
    if (!_isMusicEnabled) return;
    try {
      await _musicPlayer.stop(); // Önceki müziği durdur
      await _musicPlayer.setReleaseMode(ReleaseMode.loop); // Tekrar ayarla
      await _musicPlayer.setSource(AssetSource('audio/background_music.mp3')); // Önce source'u ayarla
      await _musicPlayer.setVolume(_musicVolume);
      await _musicPlayer.resume(); // Müziği başlat
      print('Arkaplan müziği başlatıldı'); // Debug için log
    } catch (e) {
      print('Arkaplan müziği çalınırken hata oluştu: $e');
      print('Hata detayı: ${e.toString()}'); // Daha detaylı hata mesajı
    }
  }

  Future<void> pauseBackgroundMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (e) {
      print('Müzik duraklatılırken hata oluştu: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (e) {
      print('Müzik durdurulurken hata oluştu: $e');
    }
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_isMusicEnabled) return;
    try {
      await _musicPlayer.resume();
      await _musicPlayer.setVolume(_musicVolume);
    } catch (e) {
      print('Müzik devam ettirilirken hata oluştu: $e');
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _isSoundEnabled = enabled;
    if (!enabled) {
      await _soundPlayer.stop();
    }
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _isMusicEnabled = enabled;
    if (enabled) {
      await playBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }
  }

  Future<void> setSoundVolume(double volume) async {
    _soundVolume = volume;
    await _soundPlayer.setVolume(volume);
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume;
    await _musicPlayer.setVolume(volume);
  }

  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _soundPlayer.dispose();
  }
}