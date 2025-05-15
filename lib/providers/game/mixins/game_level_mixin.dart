import 'package:flutter/foundation.dart';
import '../state/game_state.dart';
import '../../../utils/level_system.dart';

mixin GameLevelMixin on GameState {
  int _xp = 0;
  int _coins = 0;
  Map<String, bool> _unlockedItems = {};
  List<String> _unlockedFeatures = [];

  // Getters
  int get xp => _xp;
  int get coins => _coins;
  Map<String, bool> get unlockedItems => _unlockedItems;
  List<String> get unlockedFeatures => _unlockedFeatures;
  int get currentLevel => LevelSystem.calculateLevel(_xp);
  double get levelProgress => LevelSystem.levelProgress(_xp);
  int get nextLevelXP => LevelSystem.nextLevelXP(currentLevel);

  // XP ekle ve seviye atlama kontrolü
  void addXp(int amount, {VoidCallback? onLevelUp}) {
    int oldLevel = currentLevel;
    _xp += amount;
    int newLevel = currentLevel;
    if (newLevel > oldLevel) {
      // Seviye atlandı, ödülleri ver
      final reward = LevelSystem.getLevelRewards(newLevel);
      if (reward != null) {
        _coins += reward.coins;
        for (var item in reward.items) {
          _unlockedItems[item] = true;
        }
      }
      // Açılan özellikleri güncelle
      _unlockedFeatures = LevelSystem.getUnlockedFeatures(newLevel);
      if (onLevelUp != null) onLevelUp();
    }
  }

  // XP ve coinleri sıfırla (yeni oyun/başlangıç için)
  void resetLevelData() {
    _xp = 0;
    _coins = 0;
    _unlockedItems.clear();
    _unlockedFeatures.clear();
  }
}