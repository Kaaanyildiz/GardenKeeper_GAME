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
  final Map<String, List<AudioPlayer>> _soundPools = {};
  final Map<String, int> _poolIndex = {};
  bool _isMusicEnabled = true;
  bool _isSoundEnabled = true;
  double _musicVolume = 1.0;
  double _soundVolume = 1.0;
  bool _isInitialized = false;
  
  static const int _poolSize = 3; // Her ses için havuzda bulunacak player sayısı

  AudioManager._internal() {
    initialize();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _musicPlayer = AudioPlayer();
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(_musicVolume);
    
    // Tüm ses tipleri için player havuzlarını oluştur
    await _setupSoundPool('hit_normal', 'audio/hit_normal.wav');
    await _setupSoundPool('hit_golden', 'audio/hit_golden.mp3');
    await _setupSoundPool('hit_healing', 'audio/hit_healing.mp3');
    await _setupSoundPool('hit_tough', 'audio/hit_tough.mp3');
    await _setupSoundPool('hit_speedy', 'audio/hit_speedy.wav');
    await _setupSoundPool('button', 'audio/button.wav');
    await _setupSoundPool('miss', 'audio/miss.wav');
    await _setupSoundPool('power_up', 'audio/power_up.wav');
    await _setupSoundPool('combo', 'audio/combo.mp3');
    await _setupSoundPool('game_over', 'audio/game_over.mp3');
    
    if (_isMusicEnabled) {
      await playBackgroundMusic();
    }
    
    _isInitialized = true;
  }

  Future<void> _setupSoundPool(String soundId, String assetPath) async {
    _soundPools[soundId] = [];
    _poolIndex[soundId] = 0;
    print('[DEBUG][AudioManager] Sound pool setup: id=$soundId, asset=$assetPath');
    for (int i = 0; i < _poolSize; i++) {
      final player = AudioPlayer();
      await player.setVolume(_soundVolume);
      _soundPools[soundId]!.add(player);
    }
  }

  AudioPlayer _getNextPlayer(String soundId) {
    if (!_soundPools.containsKey(soundId)) {
      throw Exception('Sound pool not found: $soundId');
    }
    final pool = _soundPools[soundId]!;
    final index = _poolIndex[soundId]!;
    // Sıradaki indekse geç
    _poolIndex[soundId] = (index + 1) % _poolSize;
    print('[DEBUG][AudioManager] getNextPlayer: soundId=$soundId, index=$index');
    return pool[index];
  }

  Future<void> _playSound(String soundId, String assetPath) async {
    if (!_isSoundEnabled) return;
    try {
      final player = _getNextPlayer(soundId);
      // await player.stop(); // GECİKMEYİ AZALTMAK İÇİN KALDIRILDI
      print('[DEBUG][AudioManager] Playing sound: id=$soundId, asset=$assetPath');
      await player.play(AssetSource(assetPath));
    } catch (e) {
      print('$soundId sesi çalınırken hata oluştu: $e');
    }
  }

  Future<void> playHitSound(MoleType type) async {
    if (!_isSoundEnabled) return;
    final fileName = type.toString().split('.').last.toLowerCase();
    final extension = fileName == 'normal' || fileName == 'speedy' ? 'wav' : 'mp3';
    await _playSound('hit_$fileName', 'audio/hit_$fileName.$extension');
  }

  Future<void> playMissSound() async {
    await _playSound('miss', 'audio/miss.wav');
  }

  Future<void> playGameOverSound() async {
    await _playSound('game_over', 'audio/game_over.mp3');
  }

  Future<void> playButtonSound() async {
    await _playSound('button', 'audio/button.wav');
  }

  Future<void> playPowerUpSound() async {
    await _playSound('power_up', 'audio/power_up.wav');
  }

  Future<void> playComboSound() async {
    await _playSound('combo', 'audio/combo.mp3');
  }

  Future<void> playBackgroundMusic() async {
    if (!_isMusicEnabled) return;
    try {
      await _musicPlayer.stop();
      await _musicPlayer.setSource(AssetSource('audio/background_music.mp3'));
      await _musicPlayer.resume();
      await _musicPlayer.setVolume(_musicVolume);
    } catch (e) {
      print('Müzik başlatılırken hata oluştu: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (e) {
      print('Müzik durdurulurken hata oluştu: $e');
    }
  }

  Future<void> pauseBackgroundMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (e) {
      print('Müzik duraklatılırken hata oluştu: $e');
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
      // Tüm aktif sesleri durdur
      for (var pool in _soundPools.values) {
        for (var player in pool) {
          await player.stop();
        }
      }
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
    // Tüm ses çalıcıların sesini güncelle
    for (var pool in _soundPools.values) {
      for (var player in pool) {
        await player.setVolume(volume);
      }
    }
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume;
    await _musicPlayer.setVolume(volume);
  }

  Future<void> dispose() async {
    await _musicPlayer.dispose();
    // Tüm ses çalıcıları temizle
    for (var pool in _soundPools.values) {
      for (var player in pool) {
        await player.dispose();
      }
    }
    _soundPools.clear();
    _poolIndex.clear();
  }
}