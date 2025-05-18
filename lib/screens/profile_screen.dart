import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game/game_provider.dart';
import '../widgets/level_progress_bar.dart';
import '../utils/level_system.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400 || size.height < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & İstatistikler'),
        backgroundColor: Colors.brown.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Seviye Barı
              const LevelProgressBar(),
              const SizedBox(height: 24),
              // Genel Bilgiler
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 24),
                  child: Column(
                    children: [
                      Text('Toplam XP', style: TextStyle(fontSize: isSmallScreen ? 16 : 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('${gameProvider.xp}', style: TextStyle(fontSize: isSmallScreen ? 22 : 32, color: Colors.orange, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text('En Yüksek Seviye', style: TextStyle(fontSize: isSmallScreen ? 16 : 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('${gameProvider.currentLevel}', style: TextStyle(fontSize: isSmallScreen ? 22 : 32, color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Kilometre Taşı Ödülleri (dinamik)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.emoji_events, color: Colors.amber.shade700),
                          const SizedBox(width: 8),
                          Text('Kilometre Taşı Ödülleri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 15 : 18)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Dinamik milestone badge ve ödül listesi
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          for (int lvl = 1; lvl <= gameProvider.currentLevel; lvl++)
                            if (LevelSystem.getLevelRewards(lvl) != null)
                              _buildMilestoneBadgeWithReward(lvl, true, LevelSystem.getLevelRewards(lvl)!),
                          // Sonraki milestone'u da gri olarak göster
                          if (LevelSystem.getLevelRewards(gameProvider.currentLevel + 1) != null)
                            _buildMilestoneBadgeWithReward(gameProvider.currentLevel + 1, false, LevelSystem.getLevelRewards(gameProvider.currentLevel + 1)!),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Genel İstatistikler (placeholder)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bar_chart, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text('Genel İstatistikler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 15 : 18)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildStatRow('Toplam Oyun', gameProvider.stats['totalGamesPlayed'] ?? 0),
                      _buildStatRow('En Yüksek Skor', gameProvider.highScore),
                      _buildStatRow('Toplam Kazanılan Coin', gameProvider.stats['totalCoinsEarned'] ?? 0),
                      // Diğer istatistikler eklenebilir
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Açılan Özellikler (dinamik)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lock_open, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Text('Açılan Özellikler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 15 : 18)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (LevelSystem.getUnlockedFeatures(gameProvider.currentLevel).isEmpty)
                        Text('Henüz özel bir özellik açılmadı.', style: TextStyle(color: Colors.grey.shade600)),
                      if (LevelSystem.getUnlockedFeatures(gameProvider.currentLevel).isNotEmpty)
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            for (final feature in LevelSystem.getUnlockedFeatures(gameProvider.currentLevel))
                              Chip(
                                label: Text(feature, style: const TextStyle(fontWeight: FontWeight.bold)),
                                backgroundColor: Colors.green.shade100,
                                avatar: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dinamik milestone badge ve ödül gösterimi
  Widget _buildMilestoneBadgeWithReward(int level, bool unlocked, LevelReward reward) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: unlocked ? Colors.amber : Colors.grey.shade400,
          child: Text(
            '$level',
            style: TextStyle(
              color: unlocked ? Colors.white : Colors.black38,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('Seviye $level', style: TextStyle(fontSize: 12, color: unlocked ? Colors.black : Colors.grey)),
        if (reward.items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.card_giftcard, size: 16, color: unlocked ? Colors.deepOrange : Colors.grey),
          ),
        if (reward.coins > 0)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on, size: 14, color: unlocked ? Colors.amber : Colors.grey),
                Text(' +${reward.coins}', style: TextStyle(fontSize: 12, color: unlocked ? Colors.amber.shade900 : Colors.grey)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}
