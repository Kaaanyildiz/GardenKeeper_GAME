import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game/game_provider.dart';
import '../utils/level_system.dart';

class LevelProgressBar extends StatelessWidget {
  final bool showNextReward;
  const LevelProgressBar({super.key, this.showNextReward = true});

  @override
  Widget build(BuildContext context) {
    final level = context.select((GameProvider p) => p.currentLevel);
    final xp = context.select((GameProvider p) => p.xp);
    final progress = context.select((GameProvider p) => p.levelProgress);
    final nextLevelXP = context.select((GameProvider p) => p.nextLevelXP);
    final coins = context.select((GameProvider p) => p.coins);
    final reward = LevelSystem.getLevelRewards(level + 1);
    final size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.brown.shade900.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Seviye rozeti
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber.shade700,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '$level',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black, blurRadius: 2)],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // İlerleme çubuğu ve XP
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.brown.shade700.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      height: 14,
                      width: (progress.clamp(0.0, 1.0)) * MediaQuery.of(context).size.width * 0.48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade400,
                            Colors.amber.shade700,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$xp / $nextLevelXP XP',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber.shade100,
                    fontWeight: FontWeight.w600,
                    shadows: const [Shadow(color: Colors.black, blurRadius: 1)],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Coin
          Row(
            children: [
              Image.asset(
                'assets/images/coin.png',
                width: 22,
                height: 22,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.monetization_on, color: Colors.amber.shade700, size: 22),
              ),
              const SizedBox(width: 4),
              Text('$coins', style: TextStyle(fontSize: 15, color: Colors.amber.shade200, fontWeight: FontWeight.bold)),
            ],
          ),
          // Sonraki ödül simgesi
          if (showNextReward && reward != null) ...[
            const SizedBox(width: 10),
            Tooltip(
              message: 'Sonraki seviye ödülü: +${reward.coins} coin${reward.items.isNotEmpty ? ", ${reward.items.join(", ")}" : ""}',
              child: Icon(Icons.card_giftcard, color: Colors.greenAccent.shade400, size: 28),
            ),
          ],
        ],
      ),
    );
  }
}
