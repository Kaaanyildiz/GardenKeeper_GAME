// Task modeli - Oyun içi görevler için
class Task {
  final String id;
  final String title;
  final String description;
  final int scoreReward;
  final int coinReward;
  final Duration duration;
  final DateTime createdAt;
  bool isCompleted;
  double progress;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.scoreReward,
    required this.coinReward,
    required this.duration,
    this.isCompleted = false,
    this.progress = 0.0,
  }) : createdAt = DateTime.now();

  // JSON serileştirme için
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'scoreReward': scoreReward,
    'coinReward': coinReward,
    'duration': duration.inSeconds,
    'isCompleted': isCompleted,
    'progress': progress,
    'createdAt': createdAt.toIso8601String(),
  };

  // JSON'dan Task nesnesi oluşturma
  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    scoreReward: json['scoreReward'],
    coinReward: json['coinReward'],
    duration: Duration(seconds: json['duration']),
    isCompleted: json['isCompleted'],
    progress: json['progress'],
  );
}
