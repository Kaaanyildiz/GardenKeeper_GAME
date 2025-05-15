import '../enums/task_type.dart';
import '../enums/game_mode.dart';

class DailyTask {
  final String id;
  final String title;
  final String description;
  final int requiredCount;
  final int rewardPoints;
  final int rewardCoins;
  final TaskType type;
  final GameMode? gameMode;
  final String? difficulty;
  final DateTime createdAt;
  final DateTime expiresAt;
  
  const DailyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredCount,
    required this.rewardPoints,
    this.rewardCoins = 0,
    required this.type,
    this.gameMode,
    this.difficulty,
    required this.createdAt,
    required this.expiresAt,
  });
  
  // Görevin süresi dolmuş mu?
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  // Görevin kalan süresi (saniye)
  int get remainingTime => expiresAt.difference(DateTime.now()).inSeconds;
  
  // İlerleme yüzdesi
  double calculateProgress(int currentCount) {
    return (currentCount / requiredCount).clamp(0.0, 1.0);
  }
  
  // Görev açıklaması oluştur
  String getProgressDescription(int currentCount) {
    return '$currentCount / $requiredCount ${type.progressUnit}';
  }
  
  // Görev durumu metni
  String getStatusText(int currentCount) {
    if (isExpired) return 'Süresi Doldu';
    if (currentCount >= requiredCount) return 'Tamamlandı';
    return 'Devam Ediyor';
  }
  
  // Zorluk seviyesine göre renk kodu
  String get difficultyColor {
    switch (difficulty) {
      case 'easy':
        return '#4CAF50'; // Yeşil
      case 'normal':
        return '#FFC107'; // Sarı
      case 'hard':
        return '#F44336'; // Kırmızı
      default:
        return '#9E9E9E'; // Gri
    }
  }
  
  // JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'requiredCount': requiredCount,
      'rewardPoints': rewardPoints,
      'rewardCoins': rewardCoins,
      'type': type.toString(),
      'gameMode': gameMode?.toString(),
      'difficulty': difficulty,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
  
  // JSON'dan oluştur
  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      requiredCount: json['requiredCount'],
      rewardPoints: json['rewardPoints'],
      rewardCoins: json['rewardCoins'] ?? 0,
      type: TaskType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      gameMode: json['gameMode'] != null
          ? GameMode.values.firstWhere(
              (e) => e.toString() == json['gameMode'],
            )
          : null,
      difficulty: json['difficulty'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
} 