/*
 * Copyright © 2025 Mehmet Kaan YILDIZ
 * Garden Keeper - Köstebek vurma oyunu
 * Tüm hakları saklıdır.
 * 
 * Bu yazılım, MIT Lisansı altında lisanslanmıştır.
 * Lisans bilgisi için LICENSE dosyasını inceleyiniz.
 */

import 'package:flutter/material.dart';
import '../providers/game/models/achievement.dart' as achievement;
import '../providers/game/enums/achievement_category.dart';
import 'package:provider/provider.dart';
import '../providers/game/game_provider.dart';
import '../widgets/level_progress_bar.dart';

// Çakışmayı önlemek için alias kullanıyoruz
typedef Achievement = achievement.Achievement;

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 90,
              title: Column(
                children: [
                  // Modern Seviye Barı (yeni)
                  const LevelProgressBar(),
                  const SizedBox(height: 4),
                  const Text(
                    'Başarımlar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              backgroundColor: Colors.brown.shade900,
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.brown.shade900,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    labelColor: Colors.amber,
                    unselectedLabelColor: Colors.white.withOpacity(0.5),
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 12,
                    ),
                    indicator: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.amber.shade600,
                          width: 3,
                        ),
                      ),
                    ),
                    tabs: const [
                      Tab(
                        child: Column(
                          children: [
                            Icon(Icons.star_outline, size: 26),
                            SizedBox(height: 4),
                            Text(
                              'Genel',
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Column(
                          children: [
                            Icon(Icons.trending_up, size: 26),
                            SizedBox(height: 4),
                            Text(
                              'Zorluk',
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Column(
                          children: [
                            Icon(Icons.games, size: 26),
                            SizedBox(height: 4),
                            Text(
                              'Modlar',
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Column(
                          children: [
                            Icon(Icons.auto_awesome, size: 26),
                            SizedBox(height: 4),
                            Text(
                              'Özel',
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.7),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: TabBarView(
                children: [
                  _buildAchievementList(gameProvider, AchievementCategory.general),
                  _buildAchievementList(gameProvider, AchievementCategory.difficulty),
                  _buildAchievementList(gameProvider, AchievementCategory.mode),
                  _buildAchievementList(gameProvider, AchievementCategory.special),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementList(GameProvider gameProvider, AchievementCategory category) {
    final achievements = gameProvider.getAchievementsByCategory(category);
    
    // Kategorideki toplam puanı hesapla
    int totalPoints = 0;
    int earnedPoints = 0;
    for (var achievement in achievements) {
      totalPoints += achievement.points;
      if (gameProvider.isAchievementUnlocked(achievement.id)) {
        earnedPoints += achievement.points;
      }
    }

    return Column(
      children: [
        // Kategori başlığı ve puan durumu
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.brown.shade900.withOpacity(0.8),
            border: Border(
              bottom: BorderSide(
                color: Colors.brown.shade700,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Kategori başlığı
              Text(
                _getCategoryTitle(category),
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Puan durumu
              Row(
                children: [
                  const Icon(
                    Icons.stars,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$earnedPoints / $totalPoints P',
                    style: TextStyle(
                      color: Colors.amber.shade100,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Başarım listesi
        Flexible(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              final isUnlocked = gameProvider.isAchievementUnlocked(achievement.id);
              final progress = gameProvider.getAchievementProgress(achievement.id);

              // Gizli başarımları gösterme koşulu
              if (achievement.isHidden && !isUnlocked) {
                return _buildHiddenAchievement();
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                color: Colors.brown.shade800.withOpacity(0.8),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isUnlocked ? Colors.amber : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      color: isUnlocked ? Colors.brown.shade900 : Colors.brown.shade300,
                      size: 32,
                    ),
                  ),
                  title: Text(
                    achievement.title,
                    style: TextStyle(
                      color: isUnlocked ? Colors.amber : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade800,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isUnlocked ? Colors.amber : Colors.amber.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '${achievement.points} P',
                    style: TextStyle(
                      color: isUnlocked ? Colors.amber : Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Kategori başlıklarını getir
  String _getCategoryTitle(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.general:
        return 'Genel Başarımlar';
      case AchievementCategory.difficulty:
        return 'Zorluk Başarımları';
      case AchievementCategory.mode:
        return 'Mod Başarımları';
      case AchievementCategory.special:
        return 'Özel Başarımlar';
    }
  }

  Widget _buildHiddenAchievement() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: Colors.brown.shade900.withOpacity(0.8),
      child: const ListTile(
        leading: Icon(
          Icons.lock,
          color: Colors.grey,
          size: 32,
        ),
        title: Text(
          '???',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Bu başarım gizli! Oyunu oynamaya devam et...',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        trailing: Text(
          '? P',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}