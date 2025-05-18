import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_task.dart';
import '../models/task.dart';  
import '../enums/task_type.dart';
import '../enums/game_mode.dart';
import '../enums/message_type.dart';
import 'interfaces/mixin_interface.dart';
import '../../../widgets/achievement_animation.dart';

mixin GameTaskMixin on MixinInterface {
  // Game state properties
  String difficulty = 'normal';
  GlobalKey<NavigatorState> gameScreenKey = GlobalKey<NavigatorState>();

  // Task collections
  final Map<String, DailyTask> _dailyTasks = {};
  final Map<String, int> _taskProgresses = {};
  DateTime? _lastTaskUpdate;
  final List<Task> _activeTasks = [];
  final List<Task> _completedTasks = [];

  // Getters
  Map<String, DailyTask> get dailyTasks => Map.unmodifiable(_dailyTasks);
  Map<String, int> get taskProgresses => Map.unmodifiable(_taskProgresses);
  DateTime? get lastTaskUpdate => _lastTaskUpdate;
  List<Task> get activeTasks => List.unmodifiable(_activeTasks);
  List<Task> get completedTasks => List.unmodifiable(_completedTasks);

  // Task notification helper
  void showTask(String message, {Duration? duration}) {
    // Görev mesajı için özel bir MessageType kullanılabilir (ör: task)
    (this as dynamic).addMessage(message, type: MessageType.task);
  }

  // Görevleri kontrol et ve güncelle
  Future<void> checkDailyTasks() async {
    final now = DateTime.now();
    
    // İlk kez çalıştırılıyorsa veya son güncellemeden bu yana 24 saat geçtiyse
    if (_lastTaskUpdate == null || 
        !isSameDay(_lastTaskUpdate!, now)) {
      await _generateDailyTasks();
      _lastTaskUpdate = now;
      await _saveTasks();
    }
    
    // Süresi dolan görevleri temizle
    _cleanupExpiredTasks();
    
    notifyListeners();
  }
  
  // Yeni günlük görevler oluştur (gelişmiş görev havuzu)
  Future<void> _generateDailyTasks() async {
    _dailyTasks.clear();
    _taskProgresses.clear();
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    // Görev havuzu
    final List<DailyTask> pool = [
      DailyTask(
        id: 'hit_50',
        title: '50 Köstebek Vur',
        description: 'Bugün 50 köstebek vur.',
        requiredCount: 50,
        rewardPoints: 100,
        rewardCoins: 50,
        type: TaskType.hitMoles,
        createdAt: now,
        expiresAt: tomorrow,
      ),
      DailyTask(
        id: 'hit_5_golden',
        title: '5 Altın Köstebek',
        description: 'Bugün 5 altın köstebek vur.',
        requiredCount: 5,
        rewardPoints: 200,
        rewardCoins: 100,
        type: TaskType.hitGoldenMoles,
        createdAt: now,
        expiresAt: tomorrow,
      ),
      DailyTask(
        id: 'reach_2000_score',
        title: '2000 Puan Yap',
        description: 'Tek bir oyunda 2000 puana ulaş.',
        requiredCount: 2000,
        rewardPoints: 150,
        rewardCoins: 75,
        type: TaskType.reachScore,
        createdAt: now,
        expiresAt: tomorrow,
      ),
      DailyTask(
        id: 'combo_10',
        title: '10 Kombo Yap',
        description: 'Bir oyunda 10 kombo yap.',
        requiredCount: 10,
        rewardPoints: 120,
        rewardCoins: 60,
        type: TaskType.achieveCombo,
        createdAt: now,
        expiresAt: tomorrow,
      ),
      DailyTask(
        id: 'play_3_classic',
        title: 'Klasik Modda 3 Oyun Oyna',
        description: 'Klasik modda 3 oyun tamamla.',
        requiredCount: 3,
        rewardPoints: 100,
        rewardCoins: 50,
        type: TaskType.winGames,
        gameMode: GameMode.classic,
        createdAt: now,
        expiresAt: tomorrow,
      ),
      DailyTask(
        id: 'play_2_timeattack',
        title: 'Zaman Yarışı Modu',
        description: 'Zaman Yarışı modunda 2 oyun tamamla.',
        requiredCount: 2,
        rewardPoints: 120,
        rewardCoins: 60,
        type: TaskType.winGames,
        gameMode: GameMode.timeAttack,
        createdAt: now,
        expiresAt: tomorrow,
      ),
      DailyTask(
        id: 'collect_10_powerups',
        title: '10 Güçlendirme Topla',
        description: 'Bugün 10 güçlendirme topla.',
        requiredCount: 10,
        rewardPoints: 100,
        rewardCoins: 50,
        type: TaskType.collectPowerUps,
        createdAt: now,
        expiresAt: tomorrow,
      ),
      DailyTask(
        id: 'perfect_game',
        title: 'Mükemmel Oyun',
        description: 'Hiç köstebek kaçırmadan bir oyun tamamla.',
        requiredCount: 1,
        rewardPoints: 300,
        rewardCoins: 150,
        type: TaskType.perfectGame,
        difficulty: 'hard',
        createdAt: now,
        expiresAt: tomorrow,
      ),
      DailyTask(
        id: 'survive_120',
        title: '120 Saniye Hayatta Kal',
        description: 'Bir oyunda 120 saniye hayatta kal.',
        requiredCount: 120,
        rewardPoints: 180,
        rewardCoins: 90,
        type: TaskType.surviveTime,
        createdAt: now,
        expiresAt: tomorrow,
      ),
      DailyTask(
        id: 'play_5_any',
        title: '5 Oyun Oyna',
        description: 'Bugün toplam 5 oyun oyna.',
        requiredCount: 5,
        rewardPoints: 100,
        rewardCoins: 50,
        type: TaskType.winGames,
        createdAt: now,
        expiresAt: tomorrow,
      ),
      DailyTask(
        id: 'earn_500_xp',
        title: '500 XP Kazan',
        description: 'Bugün toplam 500 XP kazan.',
        requiredCount: 500,
        rewardPoints: 120,
        rewardCoins: 60,
        type: TaskType.reachScore, // XP için özel bir TaskType eklenebilir, şimdilik reachScore kullanıldı
        createdAt: now,
        expiresAt: tomorrow,
      ),
    ];

    // Her gün 3 farklı görev seç (çeşitlilik için karıştır)
    pool.shuffle();
    final selected = pool.take(3).toList();
    for (final task in selected) {
      _addTask(task);
    }
  }
  
  // Görev ekle
  void _addTask(DailyTask task) {
    _dailyTasks[task.id] = task;
    _taskProgresses[task.id] = 0;
  }
  
  // Görev ilerlemesini güncelle
  void updateTaskProgress(String taskId, int progress) {
    if (!_dailyTasks.containsKey(taskId)) return;
    
    final task = _dailyTasks[taskId]!;
    if (task.isExpired) return;
    
    final oldProgress = _taskProgresses[taskId] ?? 0;
    _taskProgresses[taskId] = progress;
    
    // Görev tamamlandıysa ödül ver
    if (oldProgress < task.requiredCount && 
        progress >= task.requiredCount) {
      _onTaskCompleted(task);
    }
    
    _saveTasks();
    notifyListeners();
  }
  
  // Görev tamamlandığında
  void _onTaskCompleted(DailyTask task) {
    // Ödülleri ver
    addScore(task.rewardPoints);
    addCoins(task.rewardCoins);

    // Bildirim göster
    showTask(
      'Görev Tamamlandı: ${task.title}\n+${task.rewardPoints} puan, +${task.rewardCoins} altın!'
    );

    // Kutlama animasyonu (popup) tetikle
    // Eğer context erişimi varsa, popup göster
    final context = (this as dynamic).gameScreenKey?.currentContext;
    if (context != null) {
      Future.delayed(const Duration(milliseconds: 400), () {
        // showAchievementPopup fonksiyonu widgets/achievement_animation.dart içinde mevcut
        showAchievementPopup(
          context,
          task.title,
          task.description + '\n+${task.rewardPoints} XP, +${task.rewardCoins} altın',
          isTask: true,
        );
      });
    }
  }
  
  // Süresi dolan görevleri temizle
  void _cleanupExpiredTasks() {
    final expiredTasks = _dailyTasks.values
        .where((task) => task.isExpired)
        .map((task) => task.id)
        .toList();
    
    for (final taskId in expiredTasks) {
      _dailyTasks.remove(taskId);
      _taskProgresses.remove(taskId);
    }
  }
  
  // Görevleri kaydet
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Görevleri JSON'a dönüştür
    final tasksJson = jsonEncode(_dailyTasks.map(
      (key, value) => MapEntry(key, value.toJson())
    ));
    
    // İlerlemeleri JSON'a dönüştür
    final progressJson = jsonEncode(_taskProgresses);
    
    // Kaydet
    await prefs.setString('daily_tasks', tasksJson);
    await prefs.setString('task_progresses', progressJson);
    await prefs.setString('last_task_update', 
      _lastTaskUpdate?.toIso8601String() ?? '');
  }
  
  // Görevleri yükle
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Görevleri yükle
    final tasksJson = prefs.getString('daily_tasks');
    if (tasksJson != null) {
      final Map<String, dynamic> tasksMap = jsonDecode(tasksJson);
      _dailyTasks.clear();
      tasksMap.forEach((key, value) {
        _dailyTasks[key] = DailyTask.fromJson(value);
      });
    }
    
    // İlerlemeleri yükle
    final progressJson = prefs.getString('task_progresses');
    if (progressJson != null) {
      final Map<String, dynamic> progressMap = jsonDecode(progressJson);
      _taskProgresses.clear();
      progressMap.forEach((key, value) {
        _taskProgresses[key] = value as int;
      });
    }
    
    // Son güncelleme tarihini yükle
    final lastUpdateStr = prefs.getString('last_task_update');
    if (lastUpdateStr != null && lastUpdateStr.isNotEmpty) {
      _lastTaskUpdate = DateTime.parse(lastUpdateStr);
    }
  }
  
  // İki tarihin aynı gün olup olmadığını kontrol et
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  void addTask(Task task) {
    _activeTasks.add(task);
    notifyListenersInternal();
  }

  void removeTask(Task task) {
    _activeTasks.remove(task);
    notifyListenersInternal();
  }

  void markTaskAsCompleted(Task task) {
    if (_activeTasks.contains(task)) {
      _activeTasks.remove(task);
      _completedTasks.add(task);
      notifyListenersInternal();

      // Ödülleri ver
      _giveRewards(task);
    }
  }

  void _giveRewards(Task task) {
    addScore(task.scoreReward);
    addCoins(task.coinReward);
  }

  // Skor ekleme metodu - GameState'den override edilecek
  void addScore(int points);

  // Para ekleme metodu - GameState'den override edilecek
  void addCoins(int amount);
}