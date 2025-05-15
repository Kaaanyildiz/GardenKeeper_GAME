import '../models/achievement.dart' as models;
import '../enums/achievement_category.dart';
import '../enums/game_mode.dart';
import '../enums/message_type.dart';
import '../../shared_prefs.dart';

mixin GameAchievementMixin {
  // Maps
  final Map<String, models.Achievement> _achievements = {};
  final Map<String, bool> _achievementStates = {};
  Map<String, int> get stats;
  // State variables
  int _achievementPoints = 0;
  bool _isGameActive = false;
  int _currentCombo = 0;

  // Getters
  int get achievementPoints => _achievementPoints;
  int get currentCombo => _currentCombo;
  bool get isGameActive => _isGameActive;
  int get score;
  String get difficulty;
  GameMode get currentGameMode;
  int get missedMoles;

  // Methods
  void addMessage(String message, {MessageType type = MessageType.info, bool isAnimated = true, int? score});
  void notifyListeners();

  // Initialize achievements
  Future<void> loadAchievements() async {
    _achievements.clear();
    _achievementStates.clear();

    // General Achievements
    _achievements['first_game'] = models.Achievement(
      id: 'first_game',
      title: 'İlk Adım',
      description: 'İlk oyununu oyna',
      category: AchievementCategory.general,
      points: 5,
    );

    _achievements['total_score_10k'] = models.Achievement(
      id: 'total_score_10k',
      title: 'Puan Avcısı', 
      description: 'Toplam 10,000 puan kazan',
      category: AchievementCategory.general,
      points: 30,
    );

    _achievements['hit_1000_moles'] = models.Achievement(
      id: 'hit_1000_moles',
      title: 'Köstebek Avcısı',
      description: 'Toplam 1,000 köstebek vur',
      category: AchievementCategory.general,
      points: 40,
    );

    _achievements['daily_tasks_10'] = models.Achievement(
      id: 'daily_tasks_10',
      title: 'Görev Tutkunu',  
      description: '10 günlük görevi tamamla',
      category: AchievementCategory.general,
      points: 25,
    );
    
    // Difficulty Achievements
    _achievements['score_2000_easy'] = models.Achievement(
      id: 'score_2000_easy',
      title: 'Kolay Başlangıç',
      description: 'Kolay modda 2,000 puan kazan',
      category: AchievementCategory.difficulty,
      difficulty: 'easy',
      points: 10,
    );

    _achievements['score_3000_normal'] = models.Achievement(
      id: 'score_3000_normal', 
      title: 'Normal Uzman',
      description: 'Normal modda 3,000 puan kazan',
      category: AchievementCategory.difficulty,
      difficulty: 'normal', 
      points: 20,
    );

    _achievements['score_4000_hard'] = models.Achievement(
      id: 'score_4000_hard',
      title: 'Zor Usta',
      description: 'Zor modda 4,000 puan kazan', 
      category: AchievementCategory.difficulty,
      difficulty: 'hard',
      points: 40,
    );

    // Mode Achievements
    _achievements['classic_master'] = models.Achievement(
      id: 'classic_master',
      title: 'Klasik Usta',
      description: 'Klasik modda 5000 puan yap',
      category: AchievementCategory.mode,
      gameMode: GameMode.classic,
      points: 45,
    );

    _achievements['time_attack_180s'] = models.Achievement(
      id: 'time_attack_180s',
      title: 'Zaman Bükücü',
      description: 'Zaman Yarışı modunda 180 saniyeye ulaş',
      category: AchievementCategory.mode,
      gameMode: GameMode.timeAttack,
      points: 35,
    );

    _achievements['survival_300s'] = models.Achievement(
      id: 'survival_300s',
      title: 'Hayatta Kalma Uzmanı',
      description: 'Hayatta Kalma modunda 300 saniye hayatta kal',
      category: AchievementCategory.mode,
      gameMode: GameMode.survival,
      points: 35,
    );

    // Special/Hidden Achievements
    _achievements['perfect_game'] = models.Achievement(
      id: 'perfect_game',
      title: 'Mükemmel!',
      description: 'Hiç köstebek kaçırmadan oyunu bitir',
      category: AchievementCategory.special,
      points: 50,
      isHidden: true,
    );

    _achievements['speed_demon'] = models.Achievement(
      id: 'speed_demon',
      title: 'Hız İblisi',
      description: '1 saniye içinde 3 köstebek vur',
      category: AchievementCategory.special,
      points: 45,
      isHidden: true,
    );

    _achievements['golden_master'] = models.Achievement(
      id: 'golden_master',
      title: 'Altın Usta',
      description: 'Tek oyunda 10 altın köstebek vur',
      category: AchievementCategory.special,
      points: 40,
      isHidden: true,
    );

    // Load saved achievement states
    final prefs = await SharedPrefs.instance;
    for (var id in _achievements.keys) {
      _achievementStates[id] = prefs.getBool('achievement_$id') ?? false;
    }

    notifyListeners();
  }

  // Achievement helpers
  List<models.Achievement> getAchievementsByCategory(AchievementCategory category) {
    return _achievements.values
        .where((a) => a.category == category)
        .toList();
  }

  bool isAchievementUnlocked(String achievementId) {
    return _achievementStates[achievementId] ?? false;
  }

  double getAchievementProgress(String achievementId) {
    if (isAchievementUnlocked(achievementId)) return 1.0;
    
    final achievement = _achievements[achievementId];
    if (achievement == null) return 0.0;

    switch (achievement.id) {
      case 'total_score_10k':
        return (stats['totalScore'] ?? 0) / 10000;
      case 'hit_1000_moles':
        return (stats['totalMolesHit'] ?? 0) / 1000;  
      case 'play_100_games':
        return (stats['totalGamesPlayed'] ?? 0) / 100;
      default:
        return 0.0;
    }
  }

  // Achievement checks
  void checkAchievements() {
    bool anyUnlocked = false;

    // General achievements
    if (!_achievementStates['first_game']!) {
      unlockAchievement('first_game');
      anyUnlocked = true;
    }

    if (stats['totalScore']! >= 10000 && !_achievementStates['total_score_10k']!) {
      unlockAchievement('total_score_10k');
      anyUnlocked = true;
    }

    if (stats['totalMolesHit']! >= 1000 && !_achievementStates['hit_1000_moles']!) {
      unlockAchievement('hit_1000_moles');
      anyUnlocked = true;
    }

    // Mode achievements
    switch (currentGameMode) {
      case GameMode.classic:
        if (score >= 5000 && !_achievementStates['classic_master']!) {
          unlockAchievement('classic_master');
          anyUnlocked = true;
        }
        break;

      case GameMode.timeAttack:
        if (score >= 180 && !_achievementStates['time_attack_180s']!) {
          unlockAchievement('time_attack_180s'); 
          anyUnlocked = true;
        }
        break;

      case GameMode.survival:
        if (score >= 300 && !_achievementStates['survival_300s']!) {
          unlockAchievement('survival_300s');
          anyUnlocked = true;
        }
        break;

      default:
        break;
    }

    // Difficulty achievements
    if (difficulty == 'easy') {
      if (score >= 2000 && !_achievementStates['score_2000_easy']!) {
        unlockAchievement('score_2000_easy');
        anyUnlocked = true;
      }
    } else if (difficulty == 'normal') {
      if (score >= 3000 && !_achievementStates['score_3000_normal']!) {
        unlockAchievement('score_3000_normal');
        anyUnlocked = true;
      }
    } else if (difficulty == 'hard') {
      if (score >= 4000 && !_achievementStates['score_4000_hard']!) {
        unlockAchievement('score_4000_hard');
        anyUnlocked = true;
      }
    }

    checkSpecialAchievements();

    if (anyUnlocked) {
      saveAchievements();
    }
  }

  void checkSpecialAchievements() {
    // Perfect game
    if (missedMoles == 0 && !_achievementStates['perfect_game']!) {
      unlockAchievement('perfect_game');
    }

    // Golden master
    if (stats['goldenMolesHitInGame']! >= 10 && !_achievementStates['golden_master']!) {
      unlockAchievement('golden_master');
    }
  }
  void unlockAchievement(String id) {
    if (!_achievements.containsKey(id)) return;
    
    _achievementStates[id] = true;
    _achievementPoints += _achievements[id]!.points;
    
    addMessage('Başarım açıldı: ${_achievements[id]!.title}!', type: MessageType.success);
    saveAchievements();
  }

  // Save achievement states
  Future<void> saveAchievements() async {
    final prefs = await SharedPrefs.instance;
    for (var id in _achievementStates.keys) {
      await prefs.setBool('achievement_$id', _achievementStates[id] ?? false);
    }
  }
}