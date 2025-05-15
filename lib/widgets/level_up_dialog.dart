/*
 * Copyright © 2025 Mehmet Kaan YILDIZ
 * Garden Keeper - Köstebek vurma oyunu
 * Tüm hakları saklıdır.
 */

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LevelUpDialog extends StatelessWidget {
  final int level;
  final int coins;
  final List<String> unlockedItems;
  final VoidCallback onComplete;

  const LevelUpDialog({
    super.key,
    required this.level,
    required this.coins,
    required this.unlockedItems,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.brown.shade800,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.amber.shade600,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Seviye başlığı
            Text(
              'Seviye $level!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ).animate()
              .scale(
                duration: 600.ms,
                curve: Curves.elasticOut,
              ),
            
            const SizedBox(height: 16),
            
            // Para ödülü
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/coin.png',
                    width: 32,
                    height: 32,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+$coins',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ).animate()
              .slideX(
                begin: -1,
                duration: 400.ms,
                curve: Curves.easeOutBack,
                delay: 200.ms,
              ),
            
            // Açılan eşyalar
            if (unlockedItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Yeni Eşyalar!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: unlockedItems.map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ).animate()
                    .scale(
                      duration: 400.ms,
                      delay: 400.ms,
                      curve: Curves.easeOutBack,
                    );
                }).toList(),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Devam et butonu
            ElevatedButton(
              onPressed: onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Devam Et',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate()
              .slideY(
                begin: 1,
                duration: 400.ms,
                delay: 600.ms,
                curve: Curves.easeOutBack,
              ),
          ],
        ),
      ),
    );
  }
} 