/*
 * Copyright © 2025 Mehmet Kaan YILDIZ
 * Garden Keeper - Köstebek vurma oyunu
 * Tüm hakları saklıdır.
 * 
 * Bu yazılım, MIT Lisansı altında lisanslanmıştır.
 * Lisans bilgisi için LICENSE dosyasını inceleyiniz.
 */

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_manager.dart';

class GameProvider extends ChangeNotifier {
  int _score = 0;
  int _highScore = 0;
  int _timeLeft = 60; // 60 saniyelik oyun
  bool _isGameActive = false;
  Timer? _gameTimer;
  final int _gridSize = 3; // 3x3 grid (kolay ayarlanabilir)
  final List<bool> _moleVisible = List.generate(9, (_) => false);
  final List<bool> _moleHit = List.generate(9, (_) => false);
  
  // Ses yöneticisi
  final AudioManager _audioManager = AudioManager();
  
  // Oyun zorluğu
  String _difficulty = 'normal'; // easy, normal, hard
  
  // Ses ayarları
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  
  // Getter'lar
  int get score => _score;
  int get highScore => _highScore;
  int get timeLeft => _timeLeft;
  bool get isGameActive => _isGameActive;
  int get gridSize => _gridSize;
  List<bool> get moleVisible => _moleVisible;
  List<bool> get moleHit => _moleHit;
  String get difficulty => _difficulty;
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  
  GameProvider() {
    _loadHighScore();
    _audioManager.initialize();
  }
  
  // Yüksek skoru yükle
  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt('highScore') ?? 0;
    _difficulty = prefs.getString('difficulty') ?? 'normal';
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _musicEnabled = prefs.getBool('musicEnabled') ?? true;
    
    // Ses ayarlarını güncelle
    _audioManager.setSoundEnabled(_soundEnabled);
    _audioManager.setMusicEnabled(_musicEnabled);
    
    notifyListeners();
  }
  
  // Yüksek skoru kaydet
  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', _highScore);
  }
  
  // Ayarları kaydet
  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('difficulty', _difficulty);
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('musicEnabled', _musicEnabled);
  }
  
  // Zorluk seviyesini değiştir
  void setDifficulty(String difficulty) {
    _difficulty = difficulty;
    saveSettings();
    _audioManager.playButtonSound();
    notifyListeners();
  }
  
  // Ses ayarlarını değiştir
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    _audioManager.setSoundEnabled(enabled);
    saveSettings();
    notifyListeners();
  }
  
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    _audioManager.setMusicEnabled(enabled);
    saveSettings();
    notifyListeners();
  }
  
  // Oyunu başlat
  void startGame() {
    _score = 0;
    _timeLeft = 60;
    _isGameActive = true;
    
    // Arkaplan müziğini başlat
    _audioManager.playBackgroundMusic();
    
    // Tüm köstebekler için false değeri ata
    for (int i = 0; i < _moleVisible.length; i++) {
      _moleVisible[i] = false;
      _moleHit[i] = false;
    }
    
    // Zamanlayıcıyı başlat
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeLeft--;
      
      if (_timeLeft <= 0) {
        endGame();
      } else {
        _showRandomMole();
      }
      
      notifyListeners();
    });
    
    notifyListeners();
  }
  
  // Rastgele köstebek göster
  void _showRandomMole() {
    // Zorluğa göre aynı anda kaç köstebek gösterileceğini belirle
    int molesToShow;
    int moleStayDuration; // milisaniye cinsinden
    
    switch (_difficulty) {
      case 'easy':
        molesToShow = 1;
        moleStayDuration = 1550; // 1.5 saniye
        break;
      case 'normal':
        molesToShow = Random().nextInt(2) + 1; // 1-2 arası
        moleStayDuration = 1350; // 1.2 saniye
        break;
      case 'hard':
        molesToShow = Random().nextInt(3) + 1; // 1-3 arası
        moleStayDuration = 1250; // 0.8 saniye
        break;
      default:
        molesToShow = 1;
        moleStayDuration = 1200;
    }
    
    // Önce tüm köstebekleri gizle
    for (int i = 0; i < _moleVisible.length; i++) {
      _moleVisible[i] = false;
      _moleHit[i] = false;
    }
    
    // Rastgele köstebekleri göster
    final random = Random();
    for (int i = 0; i < molesToShow; i++) {
      int index = random.nextInt(_moleVisible.length);
      
      // Eğer zaten gösteriliyorsa, başka bir indeks bul
      while (_moleVisible[index]) {
        index = random.nextInt(_moleVisible.length);
      }
      
      _moleVisible[index] = true;
    }
    
    notifyListeners();
    
    // Belirli bir süre sonra köstebekleri gizle
    Future.delayed(Duration(milliseconds: moleStayDuration), () {
      if (_isGameActive) {
        for (int i = 0; i < _moleVisible.length; i++) {
          if (_moleVisible[i] && !_moleHit[i]) {
            _moleVisible[i] = false;
            // Iskalandığında ses çal
            _audioManager.playMissSound();
          }
        }
        notifyListeners();
      }
    });
  }
  
  // Köstebeğe vur
  void hitMole(int index) {
    if (_isGameActive && _moleVisible[index] && !_moleHit[index]) {
      _moleHit[index] = true;
      
      // Vurma sesi çal
      _audioManager.playHitSound();
      
      // Zorluğa göre puan ekle
      switch (_difficulty) {
        case 'easy':
          _score += 10;
          break;
        case 'normal':
          _score += 15;
          break;
        case 'hard':
          _score += 25;
          break;
        default:
          _score += 15;
      }
      
      // Yüksek skoru güncelle
      if (_score > _highScore) {
        _highScore = _score;
        _saveHighScore();
      }
      
      notifyListeners();
    }
  }
  
  // Oyunu bitir - güvenli şekilde
  void endGame() {
    if (!_isGameActive) return; // Zaten durmuşsa bir şey yapma
    
    _isGameActive = false;
    _gameTimer?.cancel();
    
    // Oyun sonu sesi çal
    _audioManager.playGameOverSound();
    
    // Tüm köstebekleri gizle
    for (int i = 0; i < _moleVisible.length; i++) {
      _moleVisible[i] = false;
      _moleHit[i] = false;
    }
    
    // Asenkron olarak bildir - widget ağacının kilidini bekleyerek
    Future.microtask(() {
      notifyListeners();
    });
  }
  
  // Ana menüye dönmek için oyun durumunu sıfırla
  void resetGameForHomeScreen() {
    // timeLeft'i pozitif bir değere ayarla (oyun sonu kontrolünü geçmesi için)
    _timeLeft = 1;
    _isGameActive = false;
    
    // Tüm köstebekleri gizle
    for (int i = 0; i < _moleVisible.length; i++) {
      _moleVisible[i] = false;
      _moleHit[i] = false;
    }
    
    notifyListeners();
  }
  
  // Nesne imha edildiğinde zamanlayıcıyı iptal et
  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}