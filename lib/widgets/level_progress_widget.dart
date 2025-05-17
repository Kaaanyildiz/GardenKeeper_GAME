/*
 * Copyright © 2025 Mehmet Kaan YILDIZ
 * Garden Keeper - Köstebek vurma oyunu
 * Tüm hakları saklıdır.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game/game_provider.dart';

class LevelProgressWidget extends StatelessWidget {
  const LevelProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.brown.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Seviye ve XP bilgisi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Selector<GameProvider, int>(
                selector: (_, p) => p.currentLevel,
                builder: (_, level, __) => Text(
                  'Seviye $level',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Selector<GameProvider, int>(
                selector: (_, p) => p.xp,
                builder: (_, xp, __) => Text(
                  '$xp XP',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // İlerleme çubuğu
          Selector<GameProvider, double>(
            selector: (_, p) => p.levelProgress,
            builder: (_, progress, __) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.brown.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.brown.shade600,
                ),
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Sonraki seviye bilgisi
          Selector<GameProvider, int>(
            selector: (_, p) => p.nextLevelXP,
            builder: (_, nextLevelXP, __) => Text(
              'Sonraki seviye: $nextLevelXP XP',
              style: TextStyle(
                fontSize: 14,
                color: Colors.brown.shade600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Para bilgisi
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/coin.png',
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.monetization_on,
                    color: Colors.amber.shade700,
                    size: 24,
                  );
                },
              ),
              const SizedBox(width: 8),
              Selector<GameProvider, int>(
                selector: (_, p) => p.coins,
                builder: (_, coins, __) => Text(
                  '$coins',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}