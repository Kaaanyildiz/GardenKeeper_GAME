/*
 * Copyright © 2025 Mehmet Kaan YILDIZ
 * Garden Keeper - Köstebek vurma oyunu
 * Tüm hakları saklıdır.
 */


import 'dart:math';

class LevelReward {
  final int coins;
  final List<String> items;

  const LevelReward({
    required this.coins,
    required this.items,
  });
}

class LevelSystem {
  // Seviye hesaplama formülü: level = (xp / 100)^0.5
  static int calculateLevel(int xp) {
    return sqrt(xp / 100).floor();
  }

  // Bir sonraki seviye için gereken XP
  static int nextLevelXP(int currentLevel) {
    return (currentLevel + 1) * (currentLevel + 1) * 100;
  }

  // Seviye ilerleme yüzdesi
  static double levelProgress(int xp) {
    final currentLevel = calculateLevel(xp);
    final currentLevelXP = currentLevel * currentLevel * 100;
    final nextLevelXP = (currentLevel + 1) * (currentLevel + 1) * 100;
    return (xp - currentLevelXP) / (nextLevelXP - currentLevelXP);
  }

  // Seviye ödülleri
  static LevelReward? getLevelRewards(int level) {
    // Seviye bazlı ödüller
    switch (level) {
      case 1:
        return const LevelReward(
          coins: 100,
          items: ['Bronz Çekiç'],
        );
      case 2:
        return const LevelReward(
          coins: 200,
          items: ['Hızlı Vuruş'],
        );
      case 3:
        return const LevelReward(
          coins: 300,
          items: ['Gümüş Çekiç'],
        );
      case 5:
        return const LevelReward(
          coins: 500,
          items: ['Altın Çekiç', 'Süper Vuruş'],
        );
      case 10:
        return const LevelReward(
          coins: 1000,
          items: ['Elmas Çekiç', 'Ultra Vuruş', 'Zaman Yavaşlatıcı'],
        );
      default:
        // Her 5 seviyede bir bonus para ödülü
        if (level % 5 == 0) {
          return LevelReward(
            coins: level * 100,
            items: const [],
          );
        }
        return null;
    }
  }

  // Belirli bir seviyenin kilidini açtığı özellikler
  static List<String> getUnlockedFeatures(int level) {
    final features = <int, List<String>>{
      1: ['Klasik Mod'],
      3: ['Günlük Görevler'],
      5: ['Zaman Yarışı Modu'],
      10: ['Hayatta Kalma Modu'],
      15: ['Özel Mod'],
      20: ['Özel Köstebek Görünümleri'],
      25: ['Özel Efektler'],
      30: ['Sezonluk Turnuvalar'],
      40: ['Prestij Modu'],
      50: ['Özel Bahçe Düzenleri'],
    };
    
    List<String> unlockedFeatures = [];
    features.forEach((reqLevel, featureList) {
      if (level >= reqLevel) {
        unlockedFeatures.addAll(featureList);
      }
    });
    return unlockedFeatures;
  }
}