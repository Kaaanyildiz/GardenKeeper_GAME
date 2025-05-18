/*
 * Copyright © 2025 Mehmet Kaan YILDIZ
 * Garden Keeper - Köstebek vurma oyunu
 * Tüm hakları saklıdır.
 */

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

class LevelUpAnimation extends StatelessWidget {
  final int level;
  final String title;
  final int coins;
  final List<String> unlockedItems;
  final VoidCallback onComplete;

  const LevelUpAnimation({
    super.key,
    required this.level,
    required this.title,
    required this.coins,
    required this.unlockedItems,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Konfeti animasyonu (Lottie)
            Positioned.fill(
              child: Lottie.asset(
                'assets/images/confetti.json',
                repeat: false,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24.0),
              margin: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.brown.shade100,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animasyonlu seviye rozeti
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade400, Colors.amber.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$level',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 12),
                  // Seviye yazısı
                  Text(
                    'SEVİYE $level',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.5, curve: Curves.easeOutBack),
                  const SizedBox(height: 8),
                  // Unvan
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.brown.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(),
                  const SizedBox(height: 24),
                  // Ödüller
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.brown.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.brown.shade200,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Para ödülü
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+$coins',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 400.ms).slideX(),
                        if (unlockedItems.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Yeni Eşyalar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...unlockedItems.map((item) => Text(
                            item,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.brown,
                            ),
                          ).animate().fadeIn(delay: 600.ms).slideX()),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Devam butonu
                  ElevatedButton(
                    onPressed: onComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade600,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'DEVAM ET',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms).scale(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}