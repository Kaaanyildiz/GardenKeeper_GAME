import '../state/game_state.dart';
import '../enums/game_mode.dart';
import '../enums/mole_type.dart';
import '../enums/power_up_type.dart';

mixin GameStatisticsMixin on GameState {
  // Mod bazlı istatistikler
  final Map<GameMode, Map<String, dynamic>> _modeStats = {
    GameMode.classic: {
      'totalPlayTime': 0,
      'gamesPlayed': 0,
      'highScore': 0,
      'totalScore': 0,
      'averageScore': 0.0,
    },
    GameMode.timeAttack: {
      'totalPlayTime': 0,
      'gamesPlayed': 0,
      'highScore': 0,
      'maxTimeReached': 0,
      'averageTime': 0.0,
    },
    GameMode.survival: {
      'totalPlayTime': 0,
      'gamesPlayed': 0,
      'highScore': 0,
      'longestSurvival': 0,
      'averageSurvivalTime': 0.0,
    },
    GameMode.special: {
      'totalPlayTime': 0,
      'gamesPlayed': 0,
      'highScore': 0,
      'goldenMolesHit': 0,
      'powerUpsCollected': 0,
    },
  };

  // Köstebek türü istatistikleri
  final Map<MoleType, Map<String, int>> _moleStats = {
    MoleType.normal: {'appeared': 0, 'hit': 0, 'missed': 0},
    MoleType.golden: {'appeared': 0, 'hit': 0, 'missed': 0},
    MoleType.speedy: {'appeared': 0, 'hit': 0, 'missed': 0},
    MoleType.tough: {'appeared': 0, 'hit': 0, 'missed': 0},
    MoleType.healing: {'appeared': 0, 'hit': 0, 'missed': 0},
  };

  // Güçlendirme istatistikleri
  final Map<PowerUpType, Map<String, dynamic>> _powerUpStats = {
    PowerUpType.hammer: {'collected': 0, 'timeActive': 0, 'scoreGained': 0},
    PowerUpType.timeFreezer: {'collected': 0, 'timeActive': 0, 'timeGained': 0},
    PowerUpType.moleReveal: {'collected': 0, 'timeActive': 0, 'molesRevealed': 0},
    PowerUpType.shield: {'collected': 0, 'timeActive': 0, 'damageBlocked': 0},
    PowerUpType.magnet: {'collected': 0, 'timeActive': 0, 'coinsCollected': 0},
  };

  // Genel istatistikler
  final Map<String, dynamic> _generalStats = {
    'totalPlayTime': 0,
    'totalGamesPlayed': 0,
    'totalScore': 0,
    'maxCombo': 0,
    'totalCoinsEarned': 0,
    'achievementsUnlocked': 0,
  };

  // Getters
  Map<GameMode, Map<String, dynamic>> get modeStats => Map.unmodifiable(_modeStats);
  Map<MoleType, Map<String, int>> get moleStats => Map.unmodifiable(_moleStats);
  Map<PowerUpType, Map<String, dynamic>> get powerUpStats => Map.unmodifiable(_powerUpStats);
  Map<String, dynamic> get generalStats => Map.unmodifiable(_generalStats);

  // İstatistik güncelleme metodları
  void updateModeStats(GameMode mode, int score, int playTime) {
    final stats = _modeStats[mode]!;
    stats['totalPlayTime'] += playTime;
    stats['gamesPlayed']++;
    stats['totalScore'] += score;
    
    if (score > (stats['highScore'] ?? 0)) {
      stats['highScore'] = score;
    }

    // Mod özel istatistikler
    switch (mode) {
      case GameMode.timeAttack:
        if (timeLeft > (stats['maxTimeReached'] ?? 0)) {
          stats['maxTimeReached'] = timeLeft;
        }
        stats['averageTime'] = stats['totalPlayTime'] / stats['gamesPlayed'];
        break;
      case GameMode.survival:
        if (playTime > (stats['longestSurvival'] ?? 0)) {
          stats['longestSurvival'] = playTime;
        }
        stats['averageSurvivalTime'] = stats['totalPlayTime'] / stats['gamesPlayed'];
        break;
      default:
        stats['averageScore'] = stats['totalScore'] / stats['gamesPlayed'];
    }
  }

  void updateMoleStats(MoleType type, bool appeared, bool hit) {
    final stats = _moleStats[type]!;
    if (appeared) stats['appeared'] = (stats['appeared'] ?? 0) + 1;
    if (hit) {
      stats['hit'] = (stats['hit'] ?? 0) + 1;
    } else {
      stats['missed'] = (stats['missed'] ?? 0) + 1;
    }
  }

  void updatePowerUpStats(PowerUpType type, {
    bool collected = false,
    int timeActive = 0,
    int effectValue = 0,
  }) {
    final stats = _powerUpStats[type]!;
    if (collected) stats['collected'] = (stats['collected'] ?? 0) + 1;
    stats['timeActive'] = (stats['timeActive'] ?? 0) + timeActive;

    switch (type) {
      case PowerUpType.hammer:
        stats['scoreGained'] = (stats['scoreGained'] ?? 0) + effectValue;
        break;
      case PowerUpType.timeFreezer:
        stats['timeGained'] = (stats['timeGained'] ?? 0) + effectValue;
        break;
      case PowerUpType.moleReveal:
        stats['molesRevealed'] = (stats['molesRevealed'] ?? 0) + effectValue;
        break;
      case PowerUpType.shield:
        stats['damageBlocked'] = (stats['damageBlocked'] ?? 0) + effectValue;
        break;
      case PowerUpType.magnet:
        stats['coinsCollected'] = (stats['coinsCollected'] ?? 0) + effectValue;
        break;
    }
  }

  void updateGeneralStats({
    int playTime = 0,
    int score = 0,
    int combo = 0,
    int coins = 0,
    bool achievementUnlocked = false,
  }) {
    _generalStats['totalPlayTime'] += playTime;
    _generalStats['totalGamesPlayed']++;
    _generalStats['totalScore'] += score;
    
    if (combo > (_generalStats['maxCombo'] ?? 0)) {
      _generalStats['maxCombo'] = combo;
    }
    
    _generalStats['totalCoinsEarned'] += coins;
    
    if (achievementUnlocked) {
      _generalStats['achievementsUnlocked'] = 
          (_generalStats['achievementsUnlocked'] ?? 0) + 1;
    }
  }

  // İstatistikleri JSON formatına dönüştür
  Map<String, dynamic> exportStats() {
    return {
      'modeStats': _modeStats,
      'moleStats': _moleStats,
      'powerUpStats': _powerUpStats,
      'generalStats': _generalStats,
    };
  }

  // JSON'dan istatistikleri yükle
  void importStats(Map<String, dynamic> data) {
    if (data.containsKey('modeStats')) {
      for (var mode in GameMode.values) {
        if (data['modeStats'][mode.toString()] != null) {
          _modeStats[mode]?.addAll(Map<String, dynamic>.from(
            data['modeStats'][mode.toString()]));
        }
      }
    }

    if (data.containsKey('moleStats')) {
      for (var type in MoleType.values) {
        if (data['moleStats'][type.toString()] != null) {
          _moleStats[type]?.addAll(Map<String, int>.from(
            data['moleStats'][type.toString()]));
        }
      }
    }

    if (data.containsKey('powerUpStats')) {
      for (var type in PowerUpType.values) {
        if (data['powerUpStats'][type.toString()] != null) {
          _powerUpStats[type]?.addAll(Map<String, dynamic>.from(
            data['powerUpStats'][type.toString()]));
        }
      }
    }

    if (data.containsKey('generalStats')) {
      _generalStats.addAll(Map<String, dynamic>.from(data['generalStats']));
    }
  }

  // İstatistikleri sıfırla
  void resetStats() {
    for (var mode in GameMode.values) {
      _modeStats[mode]?.clear();
    }
    
    for (var type in MoleType.values) {
      _moleStats[type]?.clear();
    }
    
    for (var type in PowerUpType.values) {
      _powerUpStats[type]?.clear();
    }
    
    _generalStats.clear();
  }
}