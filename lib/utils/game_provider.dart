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

// Başarım kategorileri
enum AchievementCategory {
  general,     // Genel başarımlar
  difficulty,  // Zorluk seviyesine özel başarımlar
  mode,        // Mod özel başarımları
  special      // Özel/gizli başarımlar
}

// Başarım sınıfı
class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final String? difficulty;  // Zorluk seviyesi başarımları için
  final GameMode? gameMode;  // Mod başarımları için
  final int points;         // Başarım puanı
  final bool isHidden;      // Gizli başarım mı?
  
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.points,
    this.difficulty,
    this.gameMode,
    this.isHidden = false,
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
  double _soundVolume = 1.0; // Ses efektleri seviyesi (0.0 - 1.0)
  double _musicVolume = 1.0; // Müzik seviyesi (0.0 - 1.0)
  
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
  
  // Başarımlar listesi
  final Map<String, Achievement> _achievements = {
    // Genel Başarımlar
    'first_game': Achievement(
      id: 'first_game',
      title: 'İlk Adım',
      description: 'İlk oyununu oyna',
      category: AchievementCategory.general,
      points: 5,
    ),
    'play_all_modes': Achievement(
      id: 'play_all_modes',
      title: 'Çok Yönlü',
      description: 'Tüm oyun modlarını dene',
      category: AchievementCategory.general,
      points: 20,
    ),
    'total_score_10k': Achievement(
      id: 'total_score_10k',
      title: 'Puan Avcısı',
      description: 'Toplam 10.000 puan kazan',
      category: AchievementCategory.general,
      points: 30,
    ),
    'hit_1000_moles': Achievement(
      id: 'hit_1000_moles',
      title: 'Köstebek Avcısı',
      description: 'Toplam 1.000 köstebek vur',
      category: AchievementCategory.general,
      points: 40,
    ),
    'daily_tasks_10': Achievement(
      id: 'daily_tasks_10',
      title: 'Görev Tutkunu',
      description: '10 günlük görevi tamamla',
      category: AchievementCategory.general,
      points: 25,
    ),
    'play_100_games': Achievement(
      id: 'play_100_games',
      title: 'Bahçıvan',
      description: '100 oyun oyna',
      category: AchievementCategory.general,
      points: 35,
    ),
    
    // Zorluk Seviyesi Başarımları
    'score_2000_easy': Achievement(
      id: 'score_2000_easy',
      title: 'Kolay Başlangıç',
      description: 'Kolay modda 2.000 puan kazan',
      category: AchievementCategory.difficulty,
      difficulty: 'easy',
      points: 10,
    ),
    'score_3000_normal': Achievement(
      id: 'score_3000_normal',
      title: 'Orta Seviye Uzman',
      description: 'Normal modda 3.000 puan kazan',
      category: AchievementCategory.difficulty,
      difficulty: 'normal',
      points: 20,
    ),
    'score_4000_hard': Achievement(
      id: 'score_4000_hard',
      title: 'Zor Mod Ustası',
      description: 'Zor modda 4.000 puan kazan',
      category: AchievementCategory.difficulty,
      difficulty: 'hard',
      points: 40,
    ),
    'no_miss_easy': Achievement(
      id: 'no_miss_easy',
      title: 'Kolay Mükemmellik',
      description: 'Kolay modda hiç köstebek kaçırmadan oyunu bitir',
      category: AchievementCategory.difficulty,
      difficulty: 'easy',
      points: 15,
    ),
    'no_miss_normal': Achievement(
      id: 'no_miss_normal',
      title: 'Normal Mükemmellik',
      description: 'Normal modda hiç köstebek kaçırmadan oyunu bitir',
      category: AchievementCategory.difficulty,
      difficulty: 'normal',
      points: 30,
    ),
    'no_miss_hard': Achievement(
      id: 'no_miss_hard',
      title: 'Zor Mükemmellik',
      description: 'Zor modda hiç köstebek kaçırmadan oyunu bitir',
      category: AchievementCategory.difficulty,
      difficulty: 'hard',
      points: 50,
    ),
    
    // Mod Özel Başarımları
    'classic_combo_20': Achievement(
      id: 'classic_combo_20',
      title: 'Klasik Kombo Ustası',
      description: 'Klasik modda 20x combo yap',
      category: AchievementCategory.mode,
      gameMode: GameMode.classic,
      points: 25,
    ),
    'time_attack_180s': Achievement(
      id: 'time_attack_180s',
      title: 'Zaman Bükücü',
      description: 'Zaman Yarışı modunda 180 saniyeye ulaş',
      category: AchievementCategory.mode,
      gameMode: GameMode.timeAttack,
      points: 30,
    ),
    'survival_300s': Achievement(
      id: 'survival_300s',
      title: 'Hayatta Kalma Uzmanı',
      description: 'Hayatta Kalma modunda 300 saniye hayatta kal',
      category: AchievementCategory.mode,
      gameMode: GameMode.survival,
      points: 35,
    ),
    'special_golden_streak': Achievement(
      id: 'special_golden_streak',
      title: 'Altın Avcısı',
      description: 'Özel modda üst üste 3 altın köstebek vur',
      category: AchievementCategory.mode,
      gameMode: GameMode.special,
      points: 40,
    ),
    'classic_master': Achievement(
      id: 'classic_master',
      title: 'Klasik Usta',
      description: 'Klasik modda 5000 puan yap',
      category: AchievementCategory.mode,
      gameMode: GameMode.classic,
      points: 45,
    ),
    'time_master': Achievement(
      id: 'time_master',
      title: 'Zaman Ustası',
      description: 'Zaman Yarışı modunda 240 saniyeye ulaş',
      category: AchievementCategory.mode,
      gameMode: GameMode.timeAttack,
      points: 50,
    ),
    'survival_master': Achievement(
      id: 'survival_master',
      title: 'Hayatta Kalma Efsanesi',
      description: 'Hayatta Kalma modunda 600 saniye hayatta kal',
      category: AchievementCategory.mode,
      gameMode: GameMode.survival,
      points: 55,
    ),
    'special_master': Achievement(
      id: 'special_master',
      title: 'Özel Mod Efsanesi',
      description: 'Özel modda 20 altın köstebek vur',
      category: AchievementCategory.mode,
      gameMode: GameMode.special,
      points: 60,
    ),
    
    // Özel/Gizli Başarımlar
    'perfect_game': Achievement(
      id: 'perfect_game',
      title: 'Mükemmel Oyun',
      description: 'Hiç köstebek kaçırmadan oyunu bitir',
      category: AchievementCategory.special,
      points: 50,
      isHidden: true,
    ),
    'speed_demon': Achievement(
      id: 'speed_demon',
      title: 'Hız İblisi',
      description: '1 saniye içinde 3 köstebek vur',
      category: AchievementCategory.special,
      points: 45,
      isHidden: true,
    ),
    'golden_master': Achievement(
      id: 'golden_master',
      title: 'Altın Usta',
      description: 'Tek oyunda 10 altın köstebek vur',
      category: AchievementCategory.special,
      points: 40,
      isHidden: true,
    ),
    'combo_king': Achievement(
      id: 'combo_king',
      title: 'Kombo Kralı',
      description: '30x komboya ulaş',
      category: AchievementCategory.special,
      points: 55,
      isHidden: true,
    ),
    'marathon_runner': Achievement(
      id: 'marathon_runner',
      title: 'Maraton Koşucusu',
      description: 'Tek oturumda 10 oyun oyna',
      category: AchievementCategory.special,
      points: 35,
      isHidden: true,
    ),
    'night_owl': Achievement(
      id: 'night_owl',
      title: 'Gece Kuşu',
      description: 'Gece yarısı (00:00-04:00) oyun oyna',
      category: AchievementCategory.special,
      points: 30,
      isHidden: true,
    ),
  };

  // Başarım durumları
  final Map<String, bool> _achievementStates = {};
  
  // Toplam başarım puanı
  int _achievementPoints = 0;
  
  // Başarım istatistikleri
  final Map<String, int> _stats = {
    'totalGamesPlayed': 0,
    'totalMolesHit': 0,
    'totalScore': 0,
    'maxCombo': 0,
    'goldenMolesHit': 0,
    'perfectGames': 0,
    'timesSurvived300s': 0,
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
  
  // Köstebek yönetimi için yeni değişkenler
  int? _activeMoleIndex;
  Timer? _moleTimer;
  bool _isSpawningMole = false;
  
  // Zorluk seviyelerine göre köstebek süreleri (milisaniye)
  final Map<String, int> _moleDurations = {
    'easy': 2000,    // Kolay: 2 saniye
    'normal': 1500,  // Normal: 1.5 saniye
    'hard': 1200,    // Zor: 1.2 saniye
  };
  
  // Zorluk seviyelerine göre minimum ve maksimum bekleme süreleri (milisaniye)
  final Map<String, Map<String, int>> _spawnDelays = {
    'easy': {
      'min': 600,  // En az 0.6 saniye
      'max': 1500  // En fazla 1.5 saniye
    },
    'normal': {
      'min': 400,  // En az 0.4 saniye
      'max': 1200  // En fazla 1.2 saniye
    },
    'hard': {
      'min': 200,  // En az 0.2 saniye
      'max': 800   // En fazla 0.8 saniye
    }
  };
  
  // Son vuruşların zamanını takip etmek için liste
  final List<DateTime> _recentHits = [];
  
  // Hız İblisi başarımı kontrolü
  void _checkSpeedDemonAchievement() {
    if (_achievementStates['speed_demon'] ?? false) return;
    
    final now = DateTime.now();
    _recentHits.add(now);
    
    // Son 1 saniye içindeki vuruşları kontrol et
    _recentHits.removeWhere(
      (hit) => now.difference(hit).inMilliseconds > 1000
    );
    
    if (_recentHits.length >= 3) {
      _unlockAchievement('speed_demon');
    }
  }
  
  // Altın seri başarımı için değişken
  int _goldenStreak = 0;
  
  // Altın seri başarımı kontrolü
  void _checkGoldenStreak() {
    if (_currentGameMode != GameMode.special) return;
    if (_achievementStates['special_golden_streak'] ?? false) return;
    
    _goldenStreak++;
    if (_goldenStreak >= 3) {
      _unlockAchievement('special_golden_streak');
    }
  }
  
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
  Map<String, bool> get achievementStates => _achievementStates;
  bool get hasPowerUp => _powerUpActive;
  PowerUpType? get activePowerUp => _activePowerUp;
  List<MoleType> get moleTypes => _moleTypes;
  Map<GameMode, int> get highScores => _highScores;
  int get powerUpDuration => _powerUpDuration;
  int get pendingPowerUpIndex => _pendingPowerUpIndex;
  PowerUpType? get pendingPowerUpType => _pendingPowerUpType;
  
  // Achievements screen için eklenen getter'lar
  List<String> get unlockedAchievements => _achievementStates.entries
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
      _achievementStates[key] = prefs.getBool('achievement_$key') ?? false;
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
    for (var key in _achievementStates.keys) {
      await prefs.setBool('achievement_$key', _achievementStates[key] ?? false);
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
  
  // Buton sesi çal - public metod
  Future<void> playButtonSound() async {
    if (_soundEnabled) {
      await _audioManager.playButtonSound();
    }
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
  
  // Ses seviyesi getter ve setter'ları
  double get soundVolume => _soundVolume;
  double get musicVolume => _musicVolume;
  
  void setSoundVolume(double volume) {
    _soundVolume = volume.clamp(0.0, 1.0);
    _audioManager.setSoundVolume(_soundVolume);
    saveSettings();
    notifyListeners();
  }
  
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _audioManager.setMusicVolume(_musicVolume);
    saveSettings();
    notifyListeners();
  }
  
  // Ayarları kaydet
  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('musicEnabled', _musicEnabled);
    await prefs.setDouble('soundVolume', _soundVolume);
    await prefs.setDouble('musicVolume', _musicVolume);
    await prefs.setString('difficulty', _difficulty);
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
    
    // Mevcut mod için oynanma sayısını artır
    final modeKey = 'played_${_currentGameMode.toString()}';
    _stats[modeKey] = (_stats[modeKey] as int? ?? 0) + 1;
    
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
    if (!_achievementStates['first_game']!) {
      _unlockAchievement('first_game');
    }
    
    // Oyun başlangıç değerlerini sıfırla
    _missedMoles = 0;
    _goldenStreak = 0;
    _recentHits.clear();
    
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
          if (_timeLeft >= 120 && !_achievementStates['survival_300s']!) {
            _unlockAchievement('survival_300s');
            _showMessage("Başarım: Bahçenin Efendisi!");
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
  
  // Köstebek durumu için yardımcı fonksiyon
  void _cleanupMole(int index) {
    _moleVisible[index] = false;
    _moleHit[index] = false;
    _moleTypes[index] = MoleType.normal;
    _moleHealth[index] = 1;
    if (_activeMoleIndex == index) {
      _activeMoleIndex = null;
    }
  }

  // Köstebek ve güçlendirmeleri göster
  void _showRandomEntities() {
    if (!_isGameActive || _isSpawningMole) return;
    
    _isSpawningMole = true;
    
    // Tüm aktif köstebekleri temizle
    for (int i = 0; i < _moleVisible.length; i++) {
      if (_moleVisible[i] && !_moleHit[i]) {
        _hideMole(i);
      }
    }
    
    // Yeni köstebek için rastgele konum seç
    int newIndex;
    do {
      newIndex = _random.nextInt(_moleVisible.length);
    } while (_moleVisible[newIndex]); // Görünür olan konumları atla
    
    _activeMoleIndex = newIndex;
    
    // Güçlendirme gösterme şansı
    bool canShowPowerUps = _score > 50 && !_powerUpActive;
    if (canShowPowerUps && _random.nextDouble() < 0.05) {
      _showRandomPowerUp();
      _isSpawningMole = false;
      return;
    }
    
    // Köstebek türünü belirle
    if (_currentGameMode == GameMode.special) {
      double roll = _random.nextDouble();
      if (roll < 0.15) {
        _moleTypes[newIndex] = MoleType.golden;
      } else if (roll < 0.30) {
        _moleTypes[newIndex] = MoleType.speedy;
      } else if (roll < 0.40) {
        _moleTypes[newIndex] = MoleType.tough;
        _moleHealth[newIndex] = 2;
      } else if (_currentGameMode == GameMode.survival && roll < 0.45) {
        _moleTypes[newIndex] = MoleType.healing;
      } else {
        _moleTypes[newIndex] = MoleType.normal;
      }
    } else {
      _moleTypes[newIndex] = MoleType.normal;
      if (_currentGameMode == GameMode.survival && _random.nextDouble() < 0.15) {
        _moleTypes[newIndex] = MoleType.healing;
      }
    }
    
    // Köstebeği göster
    _moleVisible[newIndex] = true;
    _moleHit[newIndex] = false;
    notifyListeners();
    
    // Köstebek süresini ayarla
    int duration = _moleDurations[_difficulty] ?? 1500;
    if (_moleTypes[newIndex] == MoleType.speedy) {
      duration = (duration * 0.6).round();
    } else if (_moleTypes[newIndex] == MoleType.golden) {
      duration = (duration * 0.7).round();
    }
    
    // Köstebeği gizleme zamanlayıcısı
    _moleTimer?.cancel();
    _moleTimer = Timer(Duration(milliseconds: duration), () {
      if (_isGameActive && _moleVisible[newIndex] && !_moleHit[newIndex]) {
        _hideMole(newIndex);
      }
    });
    
    // Sonraki köstebek için rastgele bir süre belirle
    final delays = _spawnDelays[_difficulty] ?? _spawnDelays['normal']!;
    final randomDelay = _random.nextInt(delays['max']! - delays['min']!) + delays['min']!;
    
    Future.delayed(Duration(milliseconds: randomDelay), () {
      _isSpawningMole = false;
      if (_isGameActive) {
        _showRandomEntities();
      }
    });
  }
  
  // Köstebeği gizle
  void _hideMole(int index) {
    if (!_moleVisible[index]) return;
    
    // Mükemmel oyun takibi için kaçırılan köstebekleri say
    if (!_moleHit[index]) {
      _missedMoles++;
    }
    
    _cleanupMole(index);
    
    // Altın seriyi sıfırla
    _goldenStreak = 0;
    
    // Hayatta kalma modunda can azalt
    if (_currentGameMode == GameMode.survival && !_moleHit[index]) {
      _lives--;
      if (_lives <= 0) {
        endGame();
      } else {
        _showMessage("Bir canını kaybettin!");
      }
    }
    
    // Kaçırma sesi çal
    _audioManager.playMissSound();
    notifyListeners();
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
  
  // Oyunu bitir - güvenli şekilde
  void endGame() {
    if (!_isGameActive) return; // Zaten durmuşsa bir şey yapma
    
    _isGameActive = false;
    _gameTimer?.cancel();
    
    // Mükemmel oyun kontrolü
    if (_missedMoles == 0) {
      _stats['perfectGames'] = (_stats['perfectGames'] ?? 0) + 1;
    }
    
    // İstatistikleri güncelle
    _updateStats();
    
    // Başarımları kontrol et
    _checkAchievements();
    
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
    _moleTimer?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }
  
  // Başarımları güncellemek için yardımcı metod
  void _checkAchievements() {
    bool anyUnlocked = false;

    // Genel başarımlar kontrolü
    if (!_achievementStates['first_game']!) {
      _unlockAchievement('first_game');
      anyUnlocked = true;
    }

    if (_stats['totalScore']! >= 10000 && !_achievementStates['total_score_10k']!) {
      _unlockAchievement('total_score_10k');
      anyUnlocked = true;
    }

    if (_stats['totalMolesHit']! >= 1000 && !_achievementStates['hit_1000_moles']!) {
      _unlockAchievement('hit_1000_moles');
      anyUnlocked = true;
    }

    // Yeni genel başarımlar kontrolü
    if (_stats['totalGamesPlayed']! >= 100 && !_achievementStates['play_100_games']!) {
      _unlockAchievement('play_100_games');
      anyUnlocked = true;
    }

    if (_stats['completedDailyTasks']! >= 10 && !_achievementStates['daily_tasks_10']!) {
      _unlockAchievement('daily_tasks_10');
      anyUnlocked = true;
    }

    // Zorluk seviyesi başarımları kontrolü
    if (_difficulty == 'easy') {
      if (_score >= 2000 && !_achievementStates['score_2000_easy']!) {
        _unlockAchievement('score_2000_easy');
        anyUnlocked = true;
      }
      if (_missedMoles == 0 && !_achievementStates['no_miss_easy']!) {
        _unlockAchievement('no_miss_easy');
        anyUnlocked = true;
      }
    }
    
    if (_difficulty == 'normal') {
      if (_score >= 3000 && !_achievementStates['score_3000_normal']!) {
        _unlockAchievement('score_3000_normal');
        anyUnlocked = true;
      }
      if (_missedMoles == 0 && !_achievementStates['no_miss_normal']!) {
        _unlockAchievement('no_miss_normal');
        anyUnlocked = true;
      }
    }
    
    if (_difficulty == 'hard') {
      if (_score >= 4000 && !_achievementStates['score_4000_hard']!) {
        _unlockAchievement('score_4000_hard');
        anyUnlocked = true;
      }
      if (_missedMoles == 0 && !_achievementStates['no_miss_hard']!) {
        _unlockAchievement('no_miss_hard');
        anyUnlocked = true;
      }
    }

    // Mod başarımları kontrolü
    switch (_currentGameMode) {
      case GameMode.classic:
        if (_currentCombo >= 20 && !_achievementStates['classic_combo_20']!) {
          _unlockAchievement('classic_combo_20');
          anyUnlocked = true;
        }
        if (_score >= 5000 && !_achievementStates['classic_master']!) {
          _unlockAchievement('classic_master');
          anyUnlocked = true;
        }
        break;

      case GameMode.timeAttack:
        if (_timeLeft >= 180 && !_achievementStates['time_attack_180s']!) {
          _unlockAchievement('time_attack_180s');
          anyUnlocked = true;
        }
        if (_timeLeft >= 240 && !_achievementStates['time_master']!) {
          _unlockAchievement('time_master');
          anyUnlocked = true;
        }
        break;

      case GameMode.survival:
        if (_timeLeft >= 300 && !_achievementStates['survival_300s']!) {
          _unlockAchievement('survival_300s');
          anyUnlocked = true;
        }
        if (_timeLeft >= 600 && !_achievementStates['survival_master']!) {
          _unlockAchievement('survival_master');
          anyUnlocked = true;
        }
        break;

      case GameMode.special:
        if (_goldenStreak >= 3 && !_achievementStates['special_golden_streak']!) {
          _unlockAchievement('special_golden_streak');
          anyUnlocked = true;
        }
        if (_stats['goldenMolesHitInGame']! >= 20 && !_achievementStates['special_master']!) {
          _unlockAchievement('special_master');
          anyUnlocked = true;
        }
        break;
    }

    // Özel/Gizli başarımlar kontrolü
    _checkSpecialAchievements();

    if (anyUnlocked) {
      _saveData();
    }
  }

  // Özel başarımları kontrol et
  void _checkSpecialAchievements() {
    // Mükemmel oyun kontrolü
    if (_missedMoles == 0 && !_achievementStates['perfect_game']!) {
      _unlockAchievement('perfect_game');
    }

    // Altın usta kontrolü
    if (_stats['goldenMolesHitInGame']! >= 10 && !_achievementStates['golden_master']!) {
      _unlockAchievement('golden_master');
    }

    // Kombo kralı kontrolü
    if (_currentCombo >= 30 && !_achievementStates['combo_king']!) {
      _unlockAchievement('combo_king');
    }

    // Maraton koşucusu kontrolü
    if (_stats['gamesInSession']! >= 10 && !_achievementStates['marathon_runner']!) {
      _unlockAchievement('marathon_runner');
    }

    // Gece kuşu kontrolü
    final now = DateTime.now();
    if (now.hour >= 0 && now.hour < 4 && !_achievementStates['night_owl']!) {
      _unlockAchievement('night_owl');
    }
  }

  // Stats için yeni alanlar ekleyelim
  void _initializeStats() {
    if (!_stats.containsKey('completedDailyTasks')) _stats['completedDailyTasks'] = 0;
    if (!_stats.containsKey('gamesInSession')) _stats['gamesInSession'] = 0;
    if (!_stats.containsKey('goldenMolesHitInGame')) _stats['goldenMolesHitInGame'] = 0;
  }

  // Oyun başlangıcında stats'i güncelle
  void _updateGameStartStats() {
    _stats['gamesInSession'] = (_stats['gamesInSession'] ?? 0) + 1;
    _stats['goldenMolesHitInGame'] = 0; // Her oyun başında sıfırla
  }

  // Altın köstebek vuruşlarını takip et
  void _updateGoldenMoleStats() {
    _stats['goldenMolesHitInGame'] = (_stats['goldenMolesHitInGame'] ?? 0) + 1;
  }

  // Başarım bildirimini göster
  void _showAchievementNotification(Achievement achievement) {
    _showMessage(
      "Yeni Başarım: ${achievement.title}!",
      type: MessageType.success,
    );
  }

  // Başarım aç
  void _unlockAchievement(String id, [BuildContext? context]) {
    if (!_achievements.containsKey(id)) return;
    
    _achievementStates[id] = true;
    _achievementPoints += _achievements[id]!.points;
    
    final achievement = _achievements[id]!;
    
    // Başarım bildirimini göster
    _showAchievementNotification(achievement);
    
    _saveData(); // Başarımı kaydet
  }

  // İstatistikleri güncelle
  void _updateStats() {
    _stats['totalGamesPlayed'] = (_stats['totalGamesPlayed'] ?? 0) + 1;
    _stats['totalScore'] = (_stats['totalScore'] ?? 0) + _score;
    
    if (_currentCombo > (_stats['maxCombo'] ?? 0)) {
      _stats['maxCombo'] = _currentCombo;
    }
    
    _saveData();
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
    _pointAnimations[index] = points;
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_isGameActive) {
        _pointAnimations.remove(index);
        notifyListeners();
      }
    });
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

  // Oyunu tamamen sıfırla
  void resetGame() {
    // Oyun durumunu sıfırla
    _score = 0;
    _timeLeft = 60;
    _isGameActive = false;
    _currentCombo = 0;
    _maxCombo = 0;
    _lives = 3;
    
    // Köstebek durumlarını sıfırla
    for (int i = 0; i < _moleVisible.length; i++) {
      _moleVisible[i] = false;
      _moleHit[i] = false;
      _moleTypes[i] = MoleType.normal;
      _moleHealth[i] = 1;
    }
    
    // Güçlendirme durumlarını sıfırla
    _activePowerUp = null;
    _powerUpActive = false;
    _powerUpDuration = 0;
    _pendingPowerUpIndex = -1;
    _pendingPowerUpType = null;
    
    // Zamanlayıcıyı iptal et
    _gameTimer?.cancel();
    
    // Müzik sesini normale döndür
    _audioManager.resetBackgroundMusicVolume();
    
    notifyListeners();
  }

  // Köstebeğe vur
  void hitMole(int index) {
    if (!_isGameActive || !_moleVisible[index] || _moleHit[index]) return;
    
    // İstatistikleri güncelle
    _stats['totalMolesHit'] = (_stats['totalMolesHit'] ?? 0) + 1;
    if (_moleTypes[index] == MoleType.golden) {
      _stats['goldenMolesHit'] = (_stats['goldenMolesHit'] ?? 0) + 1;
    }
    
    // Hız İblisi başarımı için son vuruş zamanlarını kontrol et
    _checkSpeedDemonAchievement();
    
    // Altın seri başarımı için kontrol
    if (_moleTypes[index] == MoleType.golden) {
      _checkGoldenStreak();
    }
    
    // Combo sistemini güncelle
    _incrementCombo();
    
    // Köstebek tipine göre puan hesaplama ve ses çalma
    int pointsToAdd = 0;
    switch (_moleTypes[index]) {
      case MoleType.normal:
        pointsToAdd = 10;
        _audioManager.playHitSound(MoleType.normal);
        _moleHit[index] = true;
        break;
      case MoleType.golden:
        pointsToAdd = 30;
        _audioManager.playHitSound(MoleType.golden);
        _moleHit[index] = true;
        break;
      case MoleType.speedy:
        pointsToAdd = 20;
        _audioManager.playHitSound(MoleType.speedy);
        _moleHit[index] = true;
        break;
      case MoleType.tough:
        if (_moleHealth[index] > 1) {
          // İlk vuruş
          _moleHealth[index]--;
          pointsToAdd = 15;
          _audioManager.playHitSound(MoleType.tough);
          
          // Mevcut zamanlayıcıyı iptal et ve yeni bir tane başlat
          _moleTimer?.cancel();
          _moleTimer = Timer(Duration(milliseconds: _moleDurations[_difficulty] ?? 1500), () {
            if (_isGameActive && _moleVisible[index] && !_moleHit[index]) {
              _hideMole(index);
            }
          });
          
          // Puanı ekle ve bildir
          _score += pointsToAdd;
          _showPointAnimation(index, pointsToAdd);
          notifyListeners();
          return;
        } else {
          // Son vuruş
          pointsToAdd = 25;
          _audioManager.playHitSound(MoleType.tough);
          _moleHit[index] = true;
        }
        break;
      case MoleType.healing:
        pointsToAdd = 5;
        _audioManager.playHitSound(MoleType.healing);
        _moleHit[index] = true;
        if (_currentGameMode == GameMode.survival) {
          _lives = min(_lives + 1, _maxLives);
          _showMessage("Can kazandın!", type: MessageType.success);
        }
        break;
    }
    
    // Combo bonusu ekle
    if (_currentCombo > 1) {
      pointsToAdd = (pointsToAdd * (1 + (_currentCombo * 0.1))).round();
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
    
    // Puan animasyonu göster
    _showPointAnimation(index, pointsToAdd);
    
    // Vurulma animasyonu ve köstebeği gizleme
    Future.delayed(Duration(milliseconds: _moleTypes[index] == MoleType.healing ? 300 : 200), () {
      if (_isGameActive) {
        _cleanupMole(index);
        notifyListeners();
        
        // Zaman Yarışı modunda süre ekle
        if (_currentGameMode == GameMode.timeAttack) {
          _timeLeft += 2;
          _showMessage("+2 saniye!", type: MessageType.success);
        }
      }
    });
    
    notifyListeners();
  }

  // Mükemmel oyun takibi için değişken
  int _missedMoles = 0;

  // Başarım puanı için getter
  int get achievementPoints => _achievementPoints;

  // Başarım kategorisine göre başarımları getir
  List<Achievement> getAchievementsByCategory(AchievementCategory category) {
    return _achievements.values
        .where((achievement) => achievement.category == category)
        .toList();
  }

  // Başarımın kilidinin açık olup olmadığını kontrol et
  bool isAchievementUnlocked(String id) {
    return _achievementStates[id] ?? false;
  }

  // Başarım ilerleme durumunu hesapla
  double getAchievementProgress(String id) {
    if (!_achievements.containsKey(id)) return 0.0;
    if (_achievementStates[id] ?? false) return 1.0;

    final achievement = _achievements[id]!;
    switch (id) {
      case 'first_game':
        return _stats['totalGamesPlayed']! > 0 ? 1.0 : 0.0;
      
      case 'play_all_modes':
        int modesPlayed = 0;
        for (var mode in GameMode.values) {
          // Her mod için oynanan oyun sayısını kontrol et
          final playCount = _stats['played_${mode.toString()}'] as int? ?? 0;
          if (playCount > 0) modesPlayed++;
        }
        return modesPlayed / GameMode.values.length;
      
      case 'total_score_10k':
        return (_stats['totalScore'] ?? 0) / 10000.0;
      
      case 'hit_1000_moles':
        return (_stats['totalMolesHit'] ?? 0) / 1000.0;
      
      case 'score_2000_easy':
        return (_stats['highScore_easy'] ?? 0) / 2000.0;
      
      case 'score_3000_normal':
        return (_stats['highScore_normal'] ?? 0) / 3000.0;
      
      case 'score_4000_hard':
        return (_stats['highScore_hard'] ?? 0) / 4000.0;
      
      case 'classic_combo_20':
        return (_stats['maxCombo'] ?? 0) / 20.0;
      
      case 'time_attack_180s':
        return (_stats['maxTimeAttackTime'] ?? 0) / 180.0;
      
      case 'survival_300s':
        return (_stats['maxSurvivalTime'] ?? 0) / 300.0;
      
      case 'special_golden_streak':
        return (_stats['maxGoldenStreak'] ?? 0) / 3.0;
      
      case 'perfect_game':
        return _stats['perfectGames']! > 0 ? 1.0 : 0.0;
      
      case 'speed_demon':
        return (_stats['maxHitsInSecond'] ?? 0) / 3.0;
      
      case 'golden_master':
        return (_stats['goldenMolesHit'] ?? 0) / 10.0;
      
      default:
        return 0.0;
    }
  }
}