import '../enums/game_mode.dart';
import '../enums/achievement_category.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final String? difficulty;  // Zorluk seviyesi başarımları için
  final GameMode? gameMode;  // Mod başarımları için
  final int points;         // Başarım puanı
  final bool isHidden;      // Gizli başarım mı?
  final String? iconPath;   // Başarım ikonu
  final DateTime? unlockedAt; // Açıldığı tarih
  
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.points,
    this.difficulty,
    this.gameMode,
    this.isHidden = false,
    this.iconPath,
    this.unlockedAt,
  });
  
  // Başarım açık mı?
  bool get isUnlocked => unlockedAt != null;
  
  // Başarımın açılma tarihi (formatlanmış)
  String? get unlockedDate {
    if (unlockedAt == null) return null;
    return '${unlockedAt!.day}.${unlockedAt!.month}.${unlockedAt!.year}';
  }
  
  // Başarım kategorisine göre renk kodu
  String get categoryColor {
    switch (category) {
      case AchievementCategory.general:
        return '#2196F3'; // Mavi
      case AchievementCategory.difficulty:
        return '#4CAF50'; // Yeşil
      case AchievementCategory.mode:
        return '#9C27B0'; // Mor
      case AchievementCategory.special:
        return '#FFC107'; // Sarı
    }
  }
  
  // JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.toString(),
      'difficulty': difficulty,
      'gameMode': gameMode?.toString(),
      'points': points,
      'isHidden': isHidden,
      'iconPath': iconPath,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }
  
  // JSON'dan oluştur
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: AchievementCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
      ),
      difficulty: json['difficulty'],
      gameMode: json['gameMode'] != null
          ? GameMode.values.firstWhere(
              (e) => e.toString() == json['gameMode'],
            )
          : null,
      points: json['points'],
      isHidden: json['isHidden'] ?? false,
      iconPath: json['iconPath'],
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
    );
  }
  
  // Başarımı aç
  Achievement unlock() {
    return Achievement(
      id: id,
      title: title,
      description: description,
      category: category,
      difficulty: difficulty,
      gameMode: gameMode,
      points: points,
      isHidden: isHidden,
      iconPath: iconPath,
      unlockedAt: DateTime.now(),
    );
  }
}