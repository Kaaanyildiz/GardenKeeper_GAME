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

// Oyun modları için enum
enum GameMode {
  classic,    // Klasik 60 saniyelik mod
  timeAttack, // Zamana karşı mod
  survival,   // Hayatta kalma modu
  special     // Özel köstebekler modu
}

// Köstebek türleri için enum
enum MoleType {
  normal,     // Normal köstebek
  golden,     // Altın köstebek (ekstra puan)
  speedy,     // Hızlı köstebek (daha az görünme süresi)
  tough       // Dayanıklı köstebek (2 vuruş gerektirir)
}

// Güçlendirme türleri için enum
enum PowerUpType {
  hammer,     // Çekiç güçlendirmesi (sonraki vuruşta ekstra puan)
  timeFreezer, // Zaman dondurucu (süreyi kısa bir süre durdurur)
  moleReveal  // Köstebek gösterici (tüm köstebekleri kısa süre gösterir)
}

class GameProvider extends ChangeNotifier {
  // Mevcut değişkenler
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
  
  // Yeni eklenen özellikler
  GameMode _currentGameMode = GameMode.classic;
  final Map<GameMode, int> _highScores = {
    GameMode.classic: 0,
    GameMode.timeAttack: 0,
    GameMode.survival: 0,
    GameMode.special: 0,
  };
  
  // Hayatta kalma modu için yaşam sayısı
  int _lives = 3;
  
  // Özel köstebekler modu değişkenleri
  final List<MoleType> _moleTypes = List.generate(9, (_) => MoleType.normal);
  final List<int> _moleHealth = List.generate(9, (_) => 1); // Dayanıklı köstebekler için sağlık
  
  // Güçlendirme sistemi değişkenleri
  PowerUpType? _activePowerUp;
  bool _powerUpActive = false;
  int _powerUpDuration = 0;
  
  // Başarılar sistemi
  final Map<String, bool> _achievements = {
    'first_game': false,      // İlk oyun
    'score_100': false,       // 100 puan
    'score_500': false,       // 500 puan
    'golden_mole': false,     // İlk altın köstebek
    'all_modes': false,       // Tüm modları oyna
    'survival_master': false, // Hayatta kalma modunda 2 dakika
  };
  
  // Getter'lar - Mevcut olanlar
  int get score => _score;
  int get highScore => _currentGameMode == GameMode.classic ? _highScore : _highScores[_currentGameMode] ?? 0;
  int get timeLeft => _timeLeft;
  bool get isGameActive => _isGameActive;
  int get gridSize => _gridSize;
  List<bool> get moleVisible => _moleVisible;
  List<bool> get moleHit => _moleHit;
  String get difficulty => _difficulty;
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  
  // Getter'lar - Yeni eklenenler
  GameMode get currentGameMode => _currentGameMode;
  int get lives => _lives;
  Map<String, bool> get achievements => _achievements;
  bool get hasPowerUp => _powerUpActive;
  PowerUpType? get activePowerUp => _activePowerUp;
  List<MoleType> get moleTypes => _moleTypes;
  Map<GameMode, int> get highScores => _highScores;
  int get powerUpDuration => _powerUpDuration;
  
  // Achievements screen için eklenen getter'lar
  List<String> get unlockedAchievements => _achievements.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();
      
  List<String> get allAchievements => _achievements.keys.toList();
  
  // İstatistikler için eklenen getter'lar
  final int _totalGamesPlayed = 0;
  final int _totalMolesHit = 0;
  final int _highestScore = 0;
  
  int get totalGamesPlayed => _totalGamesPlayed;
  int get totalMolesHit => _totalMolesHit;
  int get highestScore => _highestScore;
  
  GameProvider() {
    _loadData();
    _audioManager.initialize();
  }
  
  // Tüm verileri yükle
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Mevcut ayarlar
    _highScore = prefs.getInt('highScore') ?? 0;
    _difficulty = prefs.getString('difficulty') ?? 'normal';
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _musicEnabled = prefs.getBool('musicEnabled') ?? true;
    
    // Yeni ayarlar
    _highScores[GameMode.classic] = prefs.getInt('highScore_classic') ?? 0;
    _highScores[GameMode.timeAttack] = prefs.getInt('highScore_timeAttack') ?? 0;
    _highScores[GameMode.survival] = prefs.getInt('highScore_survival') ?? 0;
    _highScores[GameMode.special] = prefs.getInt('highScore_special') ?? 0;
    
    // Başarıları yükle
    for (var key in _achievements.keys) {
      _achievements[key] = prefs.getBool('achievement_$key') ?? false;
    }
    
    // Ses ayarlarını güncelle
    _audioManager.setSoundEnabled(_soundEnabled);
    _audioManager.setMusicEnabled(_musicEnabled);
    
    notifyListeners();
  }
  
  // Verileri kaydet
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Mevcut ayarlar
    await prefs.setInt('highScore', _highScore);
    await prefs.setString('difficulty', _difficulty);
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('musicEnabled', _musicEnabled);
    
    // Yeni ayarlar
    await prefs.setInt('highScore_classic', _highScores[GameMode.classic] ?? 0);
    await prefs.setInt('highScore_timeAttack', _highScores[GameMode.timeAttack] ?? 0);
    await prefs.setInt('highScore_survival', _highScores[GameMode.survival] ?? 0);
    await prefs.setInt('highScore_special', _highScores[GameMode.special] ?? 0);
    
    // Başarıları kaydet
    for (var key in _achievements.keys) {
      await prefs.setBool('achievement_$key', _achievements[key] ?? false);
    }
  }
  
  // Oyun modunu ayarla
  void setGameMode(GameMode mode) {
    _currentGameMode = mode;
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
  
  // Oyunu başlat - farklı modlar için güncellenmiş
  void startGame() {
    _score = 0;
    _isGameActive = true;
    
    // Mod özelinde ayarlamalar
    switch (_currentGameMode) {
      case GameMode.classic:
        _timeLeft = 60;
        break;
      case GameMode.timeAttack:
        _timeLeft = 30; // Zamana karşı modda daha az süre
        break;
      case GameMode.survival:
        _lives = 3;     // Hayatta kalma modunda yaşam sistemi
        _timeLeft = 999; // Süresiz
        break;
      case GameMode.special:
        _timeLeft = 60;
        break;
    }
    
    // Arkaplan müziğini başlat
    _audioManager.playBackgroundMusic();
    
    // Tüm köstebekler için false değeri ata
    for (int i = 0; i < _moleVisible.length; i++) {
      _moleVisible[i] = false;
      _moleHit[i] = false;
      _moleTypes[i] = MoleType.normal;
      _moleHealth[i] = 1;
    }
    
    // İlk oyun başarımı
    if (!_achievements['first_game']!) {
      _achievements['first_game'] = true;
      _saveData();
    }
    
    // Zamanlayıcıyı başlat
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Zaman dondurma güçlendirmesi aktifse zamanı azaltma
      if (_powerUpActive && _activePowerUp == PowerUpType.timeFreezer) {
        _powerUpDuration--;
        if (_powerUpDuration <= 0) {
          _powerUpActive = false;
          _activePowerUp = null;
        }
      } else {
        // Zamana karşı modunda, vuruşlar zamanı artırır
        if (_currentGameMode != GameMode.survival) {
          _timeLeft--;
        }
      }
      
      // Güçlendirme durumu güncellemesi
      if (_powerUpActive && _activePowerUp != PowerUpType.timeFreezer) {
        _powerUpDuration--;
        if (_powerUpDuration <= 0) {
          _powerUpActive = false;
          _activePowerUp = null;
        }
      }
      
      // Mod bazlı oyun sonu kontrolü
      if (_currentGameMode != GameMode.survival && _timeLeft <= 0) {
        endGame();
      } else if (_currentGameMode == GameMode.survival && _lives <= 0) {
        endGame();
      } else {
        _showRandomEntities(); // Köstebek ve güçlendirmeleri göster
      }
      
      notifyListeners();
    });
    
    notifyListeners();
  }
  
  // Köstebek ve güçlendirmeleri göster
  void _showRandomEntities() {
    // Önce tüm köstebekleri gizle
    for (int i = 0; i < _moleVisible.length; i++) {
      _moleVisible[i] = false;
      _moleHit[i] = false;
    }
    
    // Zorluğa ve moda göre ayarlamalar
    int molesToShow;
    int moleStayDuration; // milisaniye cinsinden
    bool canShowSpecialMoles = _currentGameMode == GameMode.special;
    bool canShowPowerUps = _score > 50 && !_powerUpActive; // Belirli bir skordan sonra güçlendirmeler görünebilir
    
    switch (_difficulty) {
      case 'easy':
        molesToShow = 1;
        moleStayDuration = 1550;
        break;
      case 'normal':
        molesToShow = Random().nextInt(2) + 1; // 1-2 arası
        moleStayDuration = 1350;
        break;
      case 'hard':
        molesToShow = Random().nextInt(3) + 1; // 1-3 arası
        moleStayDuration = 1250;
        break;
      default:
        molesToShow = 1;
        moleStayDuration = 1200;
    }
    
    // Modlara göre ek ayarlamalar
    if (_currentGameMode == GameMode.timeAttack) {
      molesToShow = max(1, molesToShow);
      moleStayDuration = (moleStayDuration * 0.8).round(); // Daha hızlı
    } else if (_currentGameMode == GameMode.survival) {
      moleStayDuration = (moleStayDuration * 1.1).round(); // Biraz daha yavaş
    }
    
    // Güçlendirme gösterme şansı
    if (canShowPowerUps && Random().nextDouble() < 0.05) { // %5 şans
      _showRandomPowerUp();
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
      
      // Özel köstebekler modunda farklı köstebek türleri
      if (canShowSpecialMoles) {
        double roll = random.nextDouble();
        if (roll < 0.15) {
          _moleTypes[index] = MoleType.golden; // %15 altın köstebek
        } else if (roll < 0.30) {
          _moleTypes[index] = MoleType.speedy; // %15 hızlı köstebek
        } else if (roll < 0.40) {
          _moleTypes[index] = MoleType.tough;  // %10 dayanıklı köstebek
          _moleHealth[index] = 2;
        } else {
          _moleTypes[index] = MoleType.normal; // %60 normal köstebek
        }
      } else {
        _moleTypes[index] = MoleType.normal;
      }
    }
    
    notifyListeners();
    
    // Köstebek türüne göre görünme süresi ayarlaması
    for (int i = 0; i < _moleVisible.length; i++) {
      if (_moleVisible[i]) {
        int adjustedDuration = moleStayDuration;
        
        // Köstebek türüne göre süre ayarla
        if (_moleTypes[i] == MoleType.speedy) {
          adjustedDuration = (moleStayDuration * 0.6).round(); // Hızlı köstebek daha az kalır
        } else if (_moleTypes[i] == MoleType.golden) {
          adjustedDuration = (moleStayDuration * 0.7).round(); // Altın köstebek az kalır
        }
        
        // Belirli bir süre sonra köstebeği gizle
        Future.delayed(Duration(milliseconds: adjustedDuration), () {
          if (_isGameActive && _moleVisible[i] && !_moleHit[i]) {
            _moleVisible[i] = false;
            
            // Hayatta kalma modunda kaçırılan köstebek yaşam azaltır
            if (_currentGameMode == GameMode.survival) {
              _lives--;
              if (_lives <= 0) {
                endGame();
              }
            }
            
            // Iskalandığında ses çal
            _audioManager.playMissSound();
            notifyListeners();
          }
        });
      }
    }
  }
  
  // Rastgele güçlendirme göster
  void _showRandomPowerUp() {
    final random = Random();
    int index = random.nextInt(_moleVisible.length);
    
    // Boş bir yer bul
    while (_moleVisible[index]) {
      index = random.nextInt(_moleVisible.length);
    }
    
    // Güçlendirmeyi belirli bir süre sonra otomatik kaldır
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (_isGameActive) {
        notifyListeners();
      }
    });
  }
  
  // Güçlendirme aktifleştir
  void activatePowerUp(PowerUpType type) {
    _activePowerUp = type;
    _powerUpActive = true;
    
    switch (type) {
      case PowerUpType.hammer:
        _powerUpDuration = 3; // 3 saniyelik çekiç güçlendirmesi
        break;
      case PowerUpType.timeFreezer:
        _powerUpDuration = 5; // 5 saniyelik zaman dondurma
        break;
      case PowerUpType.moleReveal:
        _powerUpDuration = 3; // 3 saniyelik köstebek gösterme
        _revealAllMoles();
        break;
    }
    
    _audioManager.playButtonSound(); // Güçlendirme sesi eklenebilir
    notifyListeners();
  }
  
  // Tüm köstebekleri göster (moleReveal güçlendirmesi için)
  void _revealAllMoles() {
    for (int i = 0; i < _moleVisible.length; i++) {
      if (!_moleVisible[i]) {
        _moleVisible[i] = true;
        _moleTypes[i] = MoleType.normal;
        
        // 3 saniye sonra gizle
        Future.delayed(const Duration(seconds: 3), () {
          if (_isGameActive && _moleVisible[i] && !_moleHit[i]) {
            _moleVisible[i] = false;
            notifyListeners();
          }
        });
      }
    }
    notifyListeners();
  }
  
  // Köstebeğe vur - farklı köstebek türleri için güncellendi
  void hitMole(int index) {
    if (_isGameActive && _moleVisible[index] && !_moleHit[index]) {
      // Dayanıklı köstebek kontrolü
      if (_moleTypes[index] == MoleType.tough && _moleHealth[index] > 1) {
        _moleHealth[index]--;
        _audioManager.playHitSound();
        notifyListeners();
        return;
      }
      
      _moleHit[index] = true;
      
      // Vurma sesi çal
      _audioManager.playHitSound();
      
      // Köstebek türü ve moda göre puan hesapla
      int basePoints;
      switch (_difficulty) {
        case 'easy':
          basePoints = 10;
          break;
        case 'normal':
          basePoints = 15;
          break;
        case 'hard':
          basePoints = 25;
          break;
        default:
          basePoints = 15;
      }
      
      // Köstebek türüne göre çarpan
      double multiplier = 1.0;
      if (_moleTypes[index] == MoleType.golden) {
        multiplier = 3.0;  // Altın köstebek 3x puan
        
        // Altın köstebek başarımı
        if (!_achievements['golden_mole']!) {
          _achievements['golden_mole'] = true;
          _saveData();
        }
      } else if (_moleTypes[index] == MoleType.speedy) {
        multiplier = 2.0;  // Hızlı köstebek 2x puan
      } else if (_moleTypes[index] == MoleType.tough) {
        multiplier = 1.5;  // Dayanıklı köstebek 1.5x puan
      }
      
      // Çekiç güçlendirmesi varsa ek puan
      if (_powerUpActive && _activePowerUp == PowerUpType.hammer) {
        multiplier += 1.0;  // Çekiç güçlendirmesi +1x puan
        _powerUpActive = false;
        _activePowerUp = null;
      }
      
      // Zamana karşı modda her vuruş süreyi uzatır
      if (_currentGameMode == GameMode.timeAttack) {
        _timeLeft += 2;  // Her vuruş +2 saniye
      }
      
      // Toplam puanı hesapla ve ekle
      int points = (basePoints * multiplier).round();
      _score += points;
      
      // Puan başarımlarını kontrol et
      if (_score >= 100 && !_achievements['score_100']!) {
        _achievements['score_100'] = true;
        _saveData();
      }
      if (_score >= 500 && !_achievements['score_500']!) {
        _achievements['score_500'] = true;
        _saveData();
      }
      
      // Yüksek skoru güncelle
      if (_score > (_highScores[_currentGameMode] ?? 0)) {
        _highScores[_currentGameMode] = _score;
        
        // Klasik mod için eski yüksek skor değişkenini de güncelle
        if (_currentGameMode == GameMode.classic && _score > _highScore) {
          _highScore = _score;
        }
        
        _saveData();
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
  
  // Başarımları güncellemek için yardımcı metod
  void checkAchievements() {
    // Tüm modları oyna başarımı
    bool allModesPlayed = true;
    for (var mode in GameMode.values) {
      if ((_highScores[mode] ?? 0) <= 0) {
        allModesPlayed = false;
        break;
      }
    }
    
    if (allModesPlayed && !_achievements['all_modes']!) {
      _achievements['all_modes'] = true;
      _saveData();
    }
  }
  
  // Günlük görev sistemi için
  bool isDailyTaskCompleted(String taskId) {
    // Burada gerçek bir uygulama, tarihlere göre görevleri kontrol eder
    return false; // Şimdilik false dönelim
  }
  
  // Kullanıcı bir günlük görevi tamamladığında
  void completeDailyTask(String taskId) {
    // Günlük görev tamamlama işlemleri
    _saveData();
  }
}