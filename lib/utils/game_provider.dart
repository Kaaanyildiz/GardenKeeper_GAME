import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'audio_manager.dart';
import 'package:flutter/rendering.dart';

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
  tough,      // Dayanıklı köstebek (2 vuruş gerektirir)
  healing     // İyileştirici köstebek (Hayatta Kalma modunda can ekler)
}

// Güçlendirme türleri için enum
enum PowerUpType {
  hammer,     // Çekiç güçlendirmesi (sonraki vuruşta ekstra puan)
  timeFreezer, // Zaman dondurucu (süreyi kısa bir süre durdurur)
  moleReveal  // Köstebek gösterici (tüm köstebekleri kısa süre gösterir)
}

// Görev türleri için enum
enum TaskType {
  hitMoles,      // Köstebek vurma görevi
  hitGoldenMoles, // Altın köstebek vurma görevi
  reachScore,    // Belirli bir puana ulaşma görevi
  playTimeInMode // Belirli bir modda belirli süre geçirme görevi
}

// Mesaj türleri için enum
enum MessageType {
  info,
  success,
  warning,
  error,
}

// Oyun içi mesajları temsil eden sınıf
class GameMessage {
  final String text;
  final DateTime timestamp;
  final MessageType type;
  
  GameMessage({
    required this.text, 
    required this.timestamp,
    this.type = MessageType.info,
  });
}

// Köstebek kontrolü için yapılar
class Mole {
  final MoleType type;
  int health;
  
  Mole({required this.type, this.health = 1});
}

// Günlük görevler için yapı
class DailyTask {
  final String id;
  final String title;
  final String description;
  final int requiredCount;
  final int rewardPoints;
  final TaskType type;
  final GameMode? gameMode; // Opsiyonel: Sadece belirli bir mod için geçerli görevler için

  DailyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredCount,
    required this.rewardPoints,
    required this.type,
    this.gameMode,
  });
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
  int get _difficultyLevel => _difficulty == 'easy' ? 1 : (_difficulty == 'normal' ? 2 : 3);
  
  // Ses ayarları
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  
  // Köstebek kontrolü için değişkenler
  final Random _random = Random();
  
  // Maksimum can sayısı
  final int _maxLives = 5;
  
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
  
  // Aktif güçlendirmeler listesi
  final List<PowerUpType> _activeBoosts = [];
  
  // Güçlendirme sistemi değişkenleri
  PowerUpType? _activePowerUp;
  bool _powerUpActive = false;
  int _powerUpDuration = 0;
  
  // Ekranda bekleyen güçlendirme için değişkenler
  int _pendingPowerUpIndex = -1;
  PowerUpType? _pendingPowerUpType;
  
  // Başarılar sistemi
  final Map<String, bool> _achievements = {
    'first_game': false,      // İlk oyun
    'score_100': false,       // 100 puan
    'score_500': false,       // 500 puan
    'golden_mole': false,     // İlk altın köstebek
    'all_modes': false,       // Tüm modları oyna
    'survival_master': false, // Hayatta kalma modunda 2 dakika
  };
  
  // Günlük görevler için değişkenler
  final Map<String, DailyTask> _dailyTasks = {
    'hit_10_moles': DailyTask(
      id: 'hit_10_moles',
      title: '10 Köstebek Vur',
      description: 'Bugün 10 köstebek vur',
      requiredCount: 10,
      rewardPoints: 20,
      type: TaskType.hitMoles,
    ),
    'hit_5_golden': DailyTask(
      id: 'hit_5_golden',
      title: '5 Altın Köstebek Vur',
      description: 'Bugün 5 altın köstebek vur',
      requiredCount: 5,
      rewardPoints: 50,
      type: TaskType.hitGoldenMoles,
    ),
    'score_300': DailyTask(
      id: 'score_300',
      title: '300 Puan Topla',
      description: 'Tek oyunda 300 puan topla',
      requiredCount: 300,
      rewardPoints: 40,
      type: TaskType.reachScore,
    ),
    'play_survival': DailyTask(
      id: 'play_survival',
      title: 'Hayatta Kalma Modu Oyna',
      description: 'Hayatta kalma modunda 1 dakika geçir',
      requiredCount: 60, // 60 saniye
      rewardPoints: 30,
      type: TaskType.playTimeInMode,
      gameMode: GameMode.survival,
    ),
  };
  
  // Günlük görev ilerlemeleri
  final Map<String, int> _taskProgresses = {};
  
  // Kullanıcının günlük puanı
  int _dailyPoints = 0;
  
  // Combo sistemi için yeni değişkenler
  int _currentCombo = 0;
  int _maxCombo = 0;
  Timer? _comboTimer;
  static const int _comboTimeout = 2000; // 2 saniye combo süresi
  
  // Ses efektleri için yeni değişkenler
  final Map<MoleType, String> _moleHitSounds = {
    MoleType.normal: 'audio/hit_normal.mp3',
    MoleType.golden: 'audio/hit_golden.mp3',
    MoleType.speedy: 'audio/hit_speedy.mp3',
    MoleType.tough: 'audio/hit_tough.mp3',
    MoleType.healing: 'audio/hit_healing.mp3',
  };
  
  // Tek bir kaçırma sesi
  final String _missSound = 'audio/miss.mp3';
  
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
  int get currentCombo => _currentCombo;
  
  // Getter'lar - Yeni eklenenler
  GameMode get currentGameMode => _currentGameMode;
  int get lives => _lives;
  Map<String, bool> get achievements => _achievements;
  bool get hasPowerUp => _powerUpActive;
  PowerUpType? get activePowerUp => _activePowerUp;
  List<MoleType> get moleTypes => _moleTypes;
  Map<GameMode, int> get highScores => _highScores;
  int get powerUpDuration => _powerUpDuration;
  int get pendingPowerUpIndex => _pendingPowerUpIndex;
  PowerUpType? get pendingPowerUpType => _pendingPowerUpType;
  
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
  
  // Getter'lar
  Map<String, DailyTask> get dailyTasks => _dailyTasks;
  Map<String, int> get taskProgresses => _taskProgresses;
  int get dailyPoints => _dailyPoints;
  
  // Aktif günlük görevleri getir
  List<DailyTask> get activeDailyTasks => _dailyTasks.values.toList();
  
  // En son güncelleme tarihi
  DateTime? _lastDailyTaskUpdate;
  
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
    
    // Günlük görev ilerlemelerini yükle
    for (var taskId in _dailyTasks.keys) {
      _taskProgresses[taskId] = prefs.getInt('task_$taskId') ?? 0;
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
    
    // Günlük görev ilerlemelerini kaydet
    for (var taskId in _taskProgresses.keys) {
      await prefs.setInt('task_$taskId', _taskProgresses[taskId] ?? 0);
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
        _timeLeft = 0;  // Başlangıçta 0'dan başlat (yukarı doğru sayacak)
        break;
      case GameMode.special:
        _timeLeft = 60;
        break;
    }
    
    // Arkaplan müziğini başlat ve sesi ayarla
    if (_musicEnabled) {
      _audioManager.lowerBackgroundMusicVolume(); // Oyun başladığında sesi kıs
    }
    
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
        } else {
          // Hayatta kalma modunda süreyi ilerlet ve başarım kontrolü yap
          _timeLeft++;
          
          // 2 dakika (120 saniye) hayatta kalma başarımı kontrolü
          if (_timeLeft >= 120 && !_achievements['survival_master']!) {
            _achievements['survival_master'] = true;
            _showMessage("Başarım: Bahçenin Efendisi!");
            _saveData();
          }
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
    
    // İlk köstebekleri göster - oyunun hemen başlaması için
    Future.delayed(Duration(milliseconds: 300), () {
      if (_isGameActive) {
        _showRandomEntities();
      }
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
          _moleTypes[index] = MoleType.tough; // %10 dayanıklı köstebek
          _moleHealth[index] = 2; // Dayanıklı köstebekler 2 vuruş gerektirir
        } else if (_currentGameMode == GameMode.survival && roll < 0.45) {
          _moleTypes[index] = MoleType.healing; // %5 iyileştirici köstebek - sadece Hayatta Kalma modunda
        } else {
          _moleTypes[index] = MoleType.normal;
        }
      } else {
        // Diğer modlar için
        _moleTypes[index] = MoleType.normal;
        
        // Hayatta Kalma modunda iyileştirici köstebek şansı
        if (_currentGameMode == GameMode.survival && random.nextDouble() < 0.15) { // %15 şansa yükseltildi
          _moleTypes[index] = MoleType.healing;
        }
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
              // Yaşam hakkı kalmadıysa oyunu bitir
              if (_lives <= 0) {
                endGame();
              }
              // Yaşam azaldığında mesaj göster ve ses çal
              _showMessage("Bir canını kaybettin!");
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
    
    // Rastgele bir güçlendirme seç
    List<PowerUpType> availablePowerUps = [
      PowerUpType.hammer,
      PowerUpType.timeFreezer,
      PowerUpType.moleReveal,
    ];
    
    // Hayatta kalma modunda timeFreezer çalışmayacağı için listeden çıkar
    if (_currentGameMode == GameMode.survival) {
      availablePowerUps.remove(PowerUpType.timeFreezer);
    }
    
    PowerUpType randomPowerUp = availablePowerUps[random.nextInt(availablePowerUps.length)];
    
    // Güçlendirmeyi aktif et - ekranda gösterirken kullanılacak
    _moleVisible[index] = true;
    _moleTypes[index] = MoleType.normal; // Özel bir görsel eklenebilir
    
    // Güçlendirme UI'da görünür olması için bir bayrak ekle
    _pendingPowerUpIndex = index;
    _pendingPowerUpType = randomPowerUp;
    
    // Güçlendirmeyi belirli bir süre sonra otomatik kaldır
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (_isGameActive && _pendingPowerUpIndex == index) {
        _pendingPowerUpIndex = -1;
        _pendingPowerUpType = null;
        if (_moleVisible[index] && !_moleHit[index]) {
          _moleVisible[index] = false;
        }
        notifyListeners();
      }
    });
    
    notifyListeners();
  }
  
  // Güçlendirme aktifleştir
  void activatePowerUp(PowerUpType type) {
    _activePowerUp = type;
    _powerUpActive = true;
    
    switch (type) {
      case PowerUpType.hammer:
        _powerUpDuration = 3;
        break;
      case PowerUpType.timeFreezer:
        _powerUpDuration = 5;
        break;
      case PowerUpType.moleReveal:
        _powerUpDuration = 3;
        _revealAllMoles();
        break;
    }
    
    _audioManager.playPowerUpSound();
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
    if (!_isGameActive || !_moleVisible[index] || _moleHit[index]) return;
    
    _moleHit[index] = true;
    
    // Combo sistemini güncelle
    _incrementCombo();
    
    // Köstebek tipine göre puan hesaplama ve ses çalma
    int pointsToAdd = 0;
    switch (_moleTypes[index]) {
      case MoleType.normal:
        pointsToAdd = 10;
        _audioManager.playHitSound(MoleType.normal);
        break;
      case MoleType.golden:
        pointsToAdd = 30;
        _audioManager.playHitSound(MoleType.golden);
        break;
      case MoleType.speedy:
        pointsToAdd = 20;
        _audioManager.playHitSound(MoleType.speedy);
        break;
      case MoleType.tough:
        if (_moleHealth[index] > 1) {
          _moleHealth[index]--;
          pointsToAdd = 15;
          _audioManager.playHitSound(MoleType.tough);
        } else {
          pointsToAdd = 25;
          _moleVisible[index] = false;
          _audioManager.playHitSound(MoleType.tough);
        }
        break;
      case MoleType.healing:
        pointsToAdd = 5;
        _audioManager.playHitSound(MoleType.healing);
        if (_currentGameMode == GameMode.survival) {
          _lives = min(_lives + 1, _maxLives);
          _showMessage("Can kazandın!", type: MessageType.success);
        }
        _moleVisible[index] = false;
        break;
    }
    
    // Combo bonusu ekle
    if (_currentCombo > 1) {
      pointsToAdd = (pointsToAdd * (1 + (_currentCombo * 0.1))).round(); // Her combo için %10 bonus
    }
    
    // Çekiç güçlendirmesi aktifse puanı iki katına çıkar
    if (_activePowerUp == PowerUpType.hammer && _powerUpActive) {
      pointsToAdd *= 2;
      _powerUpActive = false;
      _activePowerUp = null;
    }
    
    _score += pointsToAdd;
    
    // Titreşim
    _vibrate();
    
    // Puan animasyonu
    _pointAnimations[index] = pointsToAdd;
    Future.delayed(const Duration(milliseconds: 1000), () {
      _pointAnimations.remove(index);
      notifyListeners();
    });
    
    // Normal köstebekler için vurulma animasyonu
    if (_moleTypes[index] == MoleType.normal) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_isGameActive) {
          _moleVisible[index] = false;
          notifyListeners();
        }
      });
    }
    
    notifyListeners();
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
    
    // Müzik sesini normale döndür
    _audioManager.resetBackgroundMusicVolume();
    
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
    
    // Müzik sesini normale döndür
    _audioManager.resetBackgroundMusicVolume();
    
    notifyListeners();
  }
  
  // Nesne imha edildiğinde zamanlayıcıyı iptal et
  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
  
  // Başarıları güncellemek için yardımcı metod
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
  
  // Rastgele köstebek tipi seçen fonksiyon
  MoleType _getRandomMoleType() {
    // Zorluk seviyesine göre farklı olasılıklar kullan
    double randomValue = _random.nextDouble();
    
    // Hayatta kalma modunda iyileştirici köstebek çıkma olasılığını artır
    double healingChance = _currentGameMode == GameMode.survival ? 0.08 : 0.03;
    
    // Zorluk seviyesi arttıkça, özel köstebeklerin çıkma olasılığı da artar
    double goldenChance = 0.15 + (_difficultyLevel * 0.03);
    double speedyChance = 0.15 + (_difficultyLevel * 0.05);
    double toughChance = 0.10 + (_difficultyLevel * 0.04);
    
    if (randomValue < healingChance) {
      return MoleType.healing;
    } else if (randomValue < healingChance + goldenChance) {
      return MoleType.golden;
    } else if (randomValue < healingChance + goldenChance + speedyChance) {
      return MoleType.speedy;
    } else if (randomValue < healingChance + goldenChance + speedyChance + toughChance) {
      return MoleType.tough;
    } else {
      return MoleType.normal;
    }
  }
  
  // Ses çalma yardımcı metodu
  Future<void> _playSound(String soundPath) async {
    if (!_soundEnabled) return;
    
    try {
      // AudioManager üzerinden ses çal
      await _audioManager.playSound(soundPath);
    } catch (e) {
      print('Ses çalma hatası: $e');
    }
  }
  
  // Titreşim oluşturma metodu
  void _vibrate() {
    try {
      HapticFeedback.mediumImpact();
    } catch (e) {
      print('Titreşim hatası: $e');
    }
  }
  
  // Aktif mesajları ve animasyonları depolamak için değişkenler
  final List<GameMessage> _messages = [];
  final Map<int, int> _pointAnimations = {}; // index, point değerlerini tutar
  // Mesaj eklemek için metot
  void addMessage(String message, {MessageType type = MessageType.info}) {
    _messages.add(GameMessage(
      text: message,
      timestamp: DateTime.now(),
      type: type,
    ));
    
    // 2 saniye sonra mesajı kaldır (daha hızlı mesaj gösterme)
    Future.delayed(const Duration(milliseconds: 2000), () {
      if(_messages.isNotEmpty) {
        _messages.removeAt(0);
        notifyListeners();
      }
    });
    
    notifyListeners();
  }  // Puan animasyonu eklemek için metot
  void addPointAnimation(int index, int points) {
    // Önce var olan animasyonu temizle (üst üste binmeyi önle)
    _pointAnimations.remove(index);
    // Yeni animasyonu ekle
    _pointAnimations[index] = points;
    
    // 400ms (0.4 saniye) sonra animasyonu kaldır (daha hızlı temizleme)
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_pointAnimations.containsKey(index)) {
        _pointAnimations.remove(index);
        notifyListeners();
      }
    });
    
    notifyListeners();
  }

  // Mevcut mesajlara ulaşmak için getter
  List<GameMessage> get messages => _messages;

  // Puan animasyonlarına ulaşmak için getter
  Map<int, int> get pointAnimations => _pointAnimations;
  // Ekranda mesaj gösterme
  void _showMessage(String message, {MessageType type = MessageType.info}) {
    // Yeni mesajı ekledikten sonra, 3 saniyeden daha eski mesajları otomatik temizle
    final now = DateTime.now();
    _messages.removeWhere((msg) => 
      now.difference(msg.timestamp).inMilliseconds > 3000);
      
    // Yeni mesajı ekle
    addMessage(message, type: type);
  }
  // Puan animasyonu gösterme
  void _showPointAnimation(int index, int points) {
    // Hemen göstermeye başla
    // Her bir köstebek için ayrı bir animasyon göster - diğerlerini etkileme
    addPointAnimation(index, points);
  }

  // Günlük görevleri kontrol et ve güncelle
  void checkDailyTasks() {
    // Bugünün tarihi
    final now = DateTime.now();
    
    // En son güncelleme tarihi bugün değilse, görevleri sıfırla
    if (_lastDailyTaskUpdate == null || 
        !isSameDay(_lastDailyTaskUpdate!, now)) {
      _resetDailyTasks();
      _lastDailyTaskUpdate = now;
    }
    
    notifyListeners();
  }
  
  // İki tarihin aynı gün olup olmadığını kontrol et
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  // Günlük görevleri sıfırla
  void _resetDailyTasks() {
    for (var taskId in _dailyTasks.keys) {
      _taskProgresses[taskId] = 0;
    }
    _dailyPoints = 0;
    _saveData();
  }
  
  // Günlük görev ilerlemesini güncelle
  void _updateTaskProgress(String taskId, int progress) {
    // Görev yoksa işlem yapma
    if (!_dailyTasks.containsKey(taskId)) {
      return;
    }
    
    // Görev zaten tamamlanmışsa işlem yapma
    final requiredCount = _dailyTasks[taskId]!.requiredCount;
    final currentProgress = _taskProgresses[taskId] ?? 0;
    if (currentProgress >= requiredCount) {
      return;
    }
    
    // Yeni ilerlemeyi ayarla
    _taskProgresses[taskId] = progress;
    
    // Görev tamamlandıysa ödülü ver
    if (progress >= requiredCount) {
      // Görev puanını ekle
      _dailyPoints += _dailyTasks[taskId]!.rewardPoints;
      
      // Başarı mesajı göster
      _showMessage(
        "Görev Tamamlandı: ${_dailyTasks[taskId]!.title}! +${_dailyTasks[taskId]!.rewardPoints} puan kazandın!", 
        type: MessageType.success
      );
    }
    
    _saveData();
    notifyListeners();
  }
  
  // Günlük görev ilerlemesini güncelle - kolay kullanım için
  void _updateDailyTaskProgress(String taskId, [int? value]) {
    if (!_dailyTasks.containsKey(taskId)) return;
    
    int currentProgress = _taskProgresses[taskId] ?? 0;
    int newProgress;
    
    if (value != null) {
      // Belirli bir değere ayarla (skor gibi)
      newProgress = value;
    } else {
      // Artırarak ilerlet (köstebek vurma gibi)
      newProgress = currentProgress + 1;
    }
    
    _updateTaskProgress(taskId, newProgress);
  }

  // Combo sistemini sıfırla
  void _resetCombo() {
    _currentCombo = 0;
    _comboTimer?.cancel();
    notifyListeners();
  }
  
  // Combo süresini yenile
  void _refreshComboTimer() {
    _comboTimer?.cancel();
    _comboTimer = Timer(const Duration(milliseconds: _comboTimeout), () {
      if (_currentCombo > 0) {
        _showMessage("$_currentCombo Combo!", type: MessageType.success);
      }
      _resetCombo();
    });
  }
  
  // Combo'yu artır
  void _incrementCombo() {
    _currentCombo++;
    if (_currentCombo > _maxCombo) {
      _maxCombo = _currentCombo;
    }
    _refreshComboTimer();
    
    // Combo mesajlarını göster ve ses çal
    if (_currentCombo % 5 == 0) {
      _showMessage("$_currentCombo Combo!", type: MessageType.success);
      _audioManager.playComboSound();
    }
  }
}