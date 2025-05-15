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
  
  // Yeni günlük görevler oluştur
  Future<void> _generateDailyTasks() async {
    _dailyTasks.clear();
    _taskProgresses.clear();
    
    // Temel görevler
    _addTask(
      DailyTask(
        id: 'daily_hits',
        title: '50 Köstebek Vur',
        description: 'Bugün 50 köstebek vur',
        requiredCount: 50,
        rewardPoints: 100,
        rewardCoins: 50,
        type: TaskType.hitMoles,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      ),
    );
    
    _addTask(
      DailyTask(
        id: 'daily_golden',
        title: '5 Altın Köstebek',
        description: 'Bugün 5 altın köstebek vur',
        requiredCount: 5,
        rewardPoints: 200,
        rewardCoins: 100,
        type: TaskType.hitGoldenMoles,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      ),
    );
    
    // Rastgele mod görevi
    final randomMode = GameMode.values[DateTime.now().day % GameMode.values.length];
    _addTask(
      DailyTask(
        id: 'daily_mode',
        title: '${_getModeTitle(randomMode)} Oyna',
        description: '${_getModeTitle(randomMode)} modunda 3 dakika geçir',
        requiredCount: 180, // 3 dakika = 180 saniye
        rewardPoints: 150,
        rewardCoins: 75,
        type: TaskType.playTimeInMode,
        gameMode: randomMode,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      ),
    );
    
    // Zorluk seviyesine göre ekstra görev
    if (difficulty == 'hard') {
      _addTask(
        DailyTask(
          id: 'daily_perfect',
          title: 'Mükemmel Oyun',
          description: 'Hiç köstebek kaçırmadan bir oyun tamamla',
          requiredCount: 1,
          rewardPoints: 300,
          rewardCoins: 150,
          type: TaskType.perfectGame,
          difficulty: 'hard',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 1)),
        ),
      );
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
  
  // Oyun modu başlığını al
  String _getModeTitle(GameMode mode) {
    switch (mode) {
      case GameMode.classic:
        return 'Klasik Mod';
      case GameMode.timeAttack:
        return 'Zaman Yarışı';
      case GameMode.survival:
        return 'Hayatta Kalma';
      case GameMode.special:
        return 'Özel Mod';
    }
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