import 'mixins/interfaces/mixin_interface.dart';
import 'state/game_state.dart';
import 'mixins/game_audio_mixin.dart';
import 'mixins/game_message_mixin.dart';
import 'mixins/game_task_mixin.dart';
import 'mixins/game_level_mixin.dart';
import 'mixins/game_power_up_mixin.dart';
import 'mixins/game_achievement_mixin.dart';
import 'mixins/game_score_mixin.dart'; // GameScoreMixin import edildi
import 'enums/game_mode.dart';
import 'enums/mole_type.dart';

class GameProvider extends MixinInterface with 
  GameState, 
  GameAudioMixin,
  GameMessageMixin,
  GameTaskMixin,
  GameLevelMixin,
  GamePowerUpMixin,
  GameAchievementMixin,
  GameScoreMixin {  // GameScoreMixin eklendi
  // Stats
  Map<String, int> _stats = {
    'totalMolesHit': 0, 
    'totalScore': 0,
    'totalGamesPlayed': 0,
    'goldenMolesHitInGame': 0
  };
  Map<String, int> get stats => _stats;

  // Game state
  bool _isGameActive = false;
  bool get isGameActive => _isGameActive;

  String _difficulty = 'normal';
  String get difficulty => _difficulty;

  GameMode _gameMode = GameMode.classic;
  GameMode get currentGameMode => _gameMode;

  // Ses ayarları
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  // Ses ve müzik seviyesi
  double _soundVolume = 1.0;
  double _musicVolume = 1.0;
  double get soundVolume => _soundVolume;
  double get musicVolume => _musicVolume;

  // Initialize
  GameProvider() {
    loadAchievements();
    loadTasks();
    checkDailyTasks();
  }

  // Game state methods
  void startGame() {
    // Oyun başlatılırken modun kesinlikle senkronize olduğundan emin ol
    super.setGameMode(_gameMode);
    super.startGame();
    // Diğer işlemler (skor, achievement vs.) burada kalabilir
    // Köstebek çıkışı ve timer GameState'de yönetiliyor
    notifyListeners();
  }

  void endGame() {
    super.endGame();
    // --- GÜNLÜK GÖREV EVENTLERİ ---
    // 1. Skor görevi (örn. reachScore)
    if (dailyTasks.containsKey('reach_2000_score')) {
      final score = this.score;
      if (score >= 2000) {
        updateTaskProgress('reach_2000_score', score);
      }
    }
    // 2. Hayatta kalma süresi (örn. surviveTime)
    if (dailyTasks.containsKey('survive_120')) {
      final playedSeconds = (this as dynamic).playedSeconds ?? 0;
      if (playedSeconds >= 120) {
        updateTaskProgress('survive_120', playedSeconds);
      }
    }
    // 3. Mükemmel oyun (perfectGame) - hiç köstebek kaçmazsa
    if (dailyTasks.containsKey('perfect_game')) {
      if (missedMoles == 0) {
        updateTaskProgress('perfect_game', 1);
      }
    }
    // 4. Oyun kazanma/görevleri (winGames)
    if (dailyTasks.containsKey('play_3_classic') && currentGameMode == GameMode.classic) {
      updateTaskProgress('play_3_classic', (taskProgresses['play_3_classic'] ?? 0) + 1);
    }
    if (dailyTasks.containsKey('play_2_timeattack') && currentGameMode == GameMode.timeAttack) {
      updateTaskProgress('play_2_timeattack', (taskProgresses['play_2_timeattack'] ?? 0) + 1);
    }
    if (dailyTasks.containsKey('play_5_any')) {
      updateTaskProgress('play_5_any', (taskProgresses['play_5_any'] ?? 0) + 1);
    }
    // XP kazanma görevi (örn. earn_500_xp)
    if (dailyTasks.containsKey('earn_500_xp')) {
      final xp = this.xp;
      if (xp >= 500) {
        updateTaskProgress('earn_500_xp', xp);
      }
    }
    // --- GÜNLÜK GÖREV EVENTLERİ SONU ---
    notifyListeners();
  }

  void setDifficulty(String difficulty) {
    _difficulty = difficulty;
    notifyListeners();
  }
  void setGameMode(GameMode mode) {
    _gameMode = mode;
    super.setGameMode(mode); // GameState mixin'inin _gameMode'unu da güncelle
    notifyListeners();
  }

  // Missed moles
  int _missedMoles = 0;
  int get missedMoles => _missedMoles;

  // Seviye atlama için flag ve bilgiler
  bool _pendingLevelUp = false;
  int _pendingLevel = 0;
  int _pendingCoins = 0;
  List<String> _pendingUnlockedItems = [];

  bool get pendingLevelUp => _pendingLevelUp;
  int get pendingLevel => _pendingLevel;
  int get pendingCoins => _pendingCoins;
  List<String> get pendingUnlockedItems => _pendingUnlockedItems;

  void clearPendingLevelUp() {
    _pendingLevelUp = false;
    _pendingLevel = 0;
    _pendingCoins = 0;
    _pendingUnlockedItems = [];
    notifyListeners();
  }

  // Sesli buton fonksiyonu
  Future<void> playButtonSound() async {
    // AudioManager veya ilgili mixin ile entegre edilebilir
    // Şimdilik sadece notifyListeners çağırıyoruz
    notifyListeners();
  }
  // Oyun sıfırlama fonksiyonları
  void resetGameForHomeScreen() {
    resetScore(); // GameScoreMixin'den gelen metod
    _missedMoles = 0;
    _isGameActive = false;
    notifyListeners();
  }

  void resetGame() {
    resetScore(); // GameScoreMixin'den gelen metod
    _missedMoles = 0;
    _isGameActive = false;
    notifyListeners();
  }

  // Ses ve müzik ayarları
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    audioManager.setSoundEnabled(enabled);
    notifyListeners();
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    audioManager.setMusicEnabled(enabled);
    notifyListeners();
  }

  void setSoundVolume(double volume) {
    _soundVolume = volume;
    audioManager.setSoundVolume(volume);
    notifyListeners();
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume;
    audioManager.setMusicVolume(volume);
    notifyListeners();
  }

  // PowerUpMixin için gerekli override'lar (GameState'teki değişkenlere doğrudan erişim)
  @override
  List<bool> get moleVisible => super.moleVisible;
  @override
  List<bool> get moleHit => super.moleHit;
  @override
  List<MoleType> get moleTypes => super.moleTypes;
  @override
  void setMoleVisible(int index, bool value) {
    super.setMoleVisible(index, value);
    notifyListeners();
  }
  @override
  void setMoleType(int index, dynamic type) {
    super.setMoleType(index, type);
    notifyListeners();
  }
  @override
  void hitMole(int index) {
    super.hitMole(index);
    // Günlük görev ilerlemesi
    final moleType = moleTypes[index];
    // 1. Genel köstebek vurma
    if (dailyTasks.containsKey('hit_50')) {
      updateTaskProgress('hit_50', (taskProgresses['hit_50'] ?? 0) + 1);
    }
    // 2. Altın köstebek vurma
    if (moleType.toString().contains('golden') && dailyTasks.containsKey('hit_5_golden')) {
      updateTaskProgress('hit_5_golden', (taskProgresses['hit_5_golden'] ?? 0) + 1);
    }
    // 3. Kombo görevi
    if (dailyTasks.containsKey('combo_10')) {
      updateTaskProgress('combo_10', (taskProgresses['combo_10'] ?? 0) + 1);
    }
    // 4. Güçlendirme toplama (power-up)
    // (Eğer power-up toplama event'i başka yerdeyse oraya da eklenmeli)
    // 5. Hayatta kalma süresi, skor, oyun kazanma gibi görevler oyun sonunda güncellenmeli
    notifyListeners();
  }

  // Güçlendirme toplama event'i (günlük görev ilerlemesi için)
  void onPowerUpCollected() {
    // collectPowerUps görevi
    if (dailyTasks.containsKey('collect_10_powerups')) {
      updateTaskProgress('collect_10_powerups', (taskProgresses['collect_10_powerups'] ?? 0) + 1);
    }
    // useBoosts görevi (varsa)
    if (dailyTasks.containsKey('use_boosts')) {
      updateTaskProgress('use_boosts', (taskProgresses['use_boosts'] ?? 0) + 1);
    }
    notifyListeners();
  }

  // --- Oyun Sonu Dialog State ---
  bool _gameOverDialogShown = false;
  bool get gameOverDialogShown => _gameOverDialogShown;
  void setGameOverDialogShown(bool value) {
    _gameOverDialogShown = value;
    // notifyListeners(); // UI'da kullanılmadığı için kaldırıldı, context hatası engellenir
  }

  // Zorluk seviyesine göre köstebek çıkış aralığı (ms)
  int get moleSpawnInterval {
    switch (_difficulty) {
      case 'easy':
        return 1500;
      case 'hard':
        return 800;
      case 'normal':
      default:
        return 1200;
    }
  }

  // Zorluk seviyesine göre köstebek görünürlük süresi (ms)
  int get moleVisibleDuration {
    switch (_difficulty) {
      case 'easy':
        return 1800;
      case 'hard':
        return 700;
      case 'normal':
      default:
        return 1200;
    }
  }

  // Tüm oyun state'ini kesin olarak sıfırlar
  void fullResetGameState() {
    // GameState mixin'inden
    setGameActive(false);
    setTimeLeft(60);
    setLives(3);
    // Mole state
    for (int i = 0; i < moleVisible.length; i++) {
      setMoleVisible(i, false);
      // setMoleHit fonksiyonu yok, doğrudan erişim yerine aşağıdaki gibi güncelle:
      try {
        (this as dynamic).moleHit[i] = false;
      } catch (_) {}
      setMoleType(i, MoleType.normal);
    }
    // Timer'lar (GameState mixin'inde varsa)
    try {
      (this as dynamic)._gameTimer?.cancel();
    } catch (_) {}
    try {
      (this as dynamic)._moleSpawnTimer?.cancel();
    } catch (_) {}

    // GameScoreMixin'den
    resetScore();

    // PowerUpMixin'den (varsa)
    try {
      (this as dynamic).resetPowerUps?.call();
    } catch (_) {}

    // Diğer flag ve timer'lar
    _missedMoles = 0;
    // ... gerekirse başka sıfırlamalar
  }
}