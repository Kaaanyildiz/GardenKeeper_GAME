import 'mixins/interfaces/mixin_interface.dart';
import 'state/game_state.dart';
import 'mixins/game_audio_mixin.dart';
import 'mixins/game_message_mixin.dart';
import 'mixins/game_task_mixin.dart';
import 'mixins/game_level_mixin.dart';
import 'mixins/game_power_up_mixin.dart';
import 'mixins/game_achievement_mixin.dart';
import 'enums/game_mode.dart';
import 'enums/message_type.dart';
import 'enums/mole_type.dart';
import '../../utils/level_system.dart';

class GameProvider extends MixinInterface with 
  GameState, 
  GameAudioMixin,
  GameMessageMixin,
  GameTaskMixin,
  GameLevelMixin,
  GamePowerUpMixin,
  GameAchievementMixin {

  // Game state variables 
  int _score = 0;
  int get score => _score;

  void addScore(int points) {
    _score += points;
    notifyListeners();
  }

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
  }

  // Game state methods
  void startGame() {
    _score = 0;
    _isGameActive = true;
    
    // Check first game achievement
    if (!isAchievementUnlocked('first_game')) {
      unlockAchievement('first_game');
      addMessage('Başarım açıldı: İlk Adım!', type: MessageType.success);
    }
    
    notifyListeners();
  }

  void endGame() {
    _isGameActive = false;
    addXp((_score / 2).round(), onLevelUp: () {
      final reward = LevelSystem.getLevelRewards(currentLevel);
      _pendingLevelUp = true;
      _pendingLevel = currentLevel;
      _pendingCoins = reward?.coins ?? 0;
      _pendingUnlockedItems = reward?.items ?? [];
      notifyListeners();
      addMessage('Seviye atladın!');
    });
    // Update stats
    _stats['totalGamesPlayed'] = (_stats['totalGamesPlayed'] ?? 0) + 1;
    _stats['totalScore'] = (_stats['totalScore'] ?? 0) + _score;
    // Check achievements
    checkAchievements();
    notifyListeners();
  }

  void setDifficulty(String difficulty) {
    _difficulty = difficulty;
    notifyListeners();
  }

  void setGameMode(GameMode mode) {
    _gameMode = mode;
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
    _score = 0;
    _missedMoles = 0;
    _isGameActive = false;
    notifyListeners();
  }

  void resetGame() {
    _score = 0;
    _missedMoles = 0;
    _isGameActive = false;
    notifyListeners();
  }

  // Köstebek vurma fonksiyonu (temel)
  void hitMole(int index) {
    addXp(10, onLevelUp: () {
      final reward = LevelSystem.getLevelRewards(currentLevel);
      _pendingLevelUp = true;
      _pendingLevel = currentLevel;
      _pendingCoins = reward?.coins ?? 0;
      _pendingUnlockedItems = reward?.items ?? [];
      notifyListeners();
      addMessage('Seviye atladın!');
    });
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

  // PowerUpMixin için gerekli override'lar (tipler ve isimler birebir aynı)
  @override
  List<bool> get moleVisible => super.moleVisible;
  @override
  List<bool> get moleHit => super.moleHit;
  @override
  List<dynamic> get moleTypes => super.moleTypes;
  @override
  void setMoleVisible(int index, bool value) {
    super.moleVisible[index] = value;
    notifyListeners();
  }
  @override
  void setMoleType(int index, dynamic type) {
    super.moleTypes[index] = type is MoleType ? type : MoleType.normal;
    notifyListeners();
  }
}