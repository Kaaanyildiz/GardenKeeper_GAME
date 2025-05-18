import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game/game_provider.dart';
import '../providers/game/models/daily_task.dart';

class DailyTasksScreen extends StatelessWidget {
  const DailyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final dailyTasks = gameProvider.dailyTasks.values.toList();
    final progresses = gameProvider.taskProgresses;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük Görevler'),
        backgroundColor: Colors.green.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: dailyTasks.isEmpty
          ? Center(
              child: Text('Bugün için görev bulunamadı.', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: dailyTasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final task = dailyTasks[i];
                final progress = progresses[task.id] ?? 0;
                final percent = task.calculateProgress(progress);
                final isCompleted = progress >= task.requiredCount;
                final isExpired = task.isExpired;
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                  color: isCompleted ? Colors.green.shade100 : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCompleted ? Icons.check_circle : Icons.flag,
                              color: isCompleted ? Colors.green : Colors.orange,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                task.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: isCompleted ? Colors.green.shade900 : Colors.brown.shade800,
                                ),
                              ),
                            ),
                            if (isCompleted)
                              const Icon(Icons.celebration, color: Colors.amber, size: 24),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(task.description, style: TextStyle(fontSize: 15, color: Colors.grey.shade800)),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: percent,
                          minHeight: 10,
                          backgroundColor: Colors.brown.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? Colors.green : Colors.orange),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(task.getProgressDescription(progress), style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(task.getStatusText(progress), style: TextStyle(color: isCompleted ? Colors.green : isExpired ? Colors.red : Colors.orange)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.monetization_on, color: Colors.amber.shade700, size: 20),
                            Text(' +${task.rewardCoins}', style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            Icon(Icons.star, color: Colors.orange.shade400, size: 20),
                            Text(' +${task.rewardPoints}', style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (!isCompleted && !isExpired)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Kalan süre: ${_formatDuration(Duration(seconds: task.remainingTime))}',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                          ),
                        if (isCompleted)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('Ödül alındı!', style: TextStyle(fontSize: 14, color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                          ),
                        if (isExpired && !isCompleted)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('Süresi doldu', style: TextStyle(fontSize: 14, color: Colors.red.shade700, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) {
      return '${h}sa ${m}dk';
    } else if (m > 0) {
      return '${m}dk ${s}sn';
    } else {
      return '${s}sn';
    }
  }
}
