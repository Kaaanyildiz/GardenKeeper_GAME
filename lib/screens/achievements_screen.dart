/*
 * Copyright © 2025 Mehmet Kaan YILDIZ
 * Garden Keeper - Köstebek vurma oyunu
 * Tüm hakları saklıdır.
 * 
 * Bu yazılım, MIT Lisansı altında lisanslanmıştır.
 * Lisans bilgisi için LICENSE dosyasını inceleyiniz.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/game_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 400;
    
    // Başarımları kontrol et - otomatik güncelleme için
    gameProvider.checkAchievements();
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Column(
            children: [
              // Üst bar - Geri butonu ve başlık
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.brown.shade800,
                      iconSize: 30,
                    ),
                    Expanded(
                      child: Text(
                        'BAŞARIMLAR',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),  // Dengelemek için
                  ],
                ),
              ),
              
              // Başarımların açıklaması
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Text(
                  'Özel görevleri tamamlayarak başarımları açın',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.brown.shade800,
                  ),
                ),
              ),
              
              // Başarım listesi
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      // İlk oyun başarımı
                      _buildSimpleAchievement(
                        'Bahçıvan Adayı',
                        'İlk oyununu oyna',
                        Icons.play_arrow,
                        Colors.green,
                        gameProvider.achievements['first_game'] ?? false,
                      ),
                      
                      // 100 puan başarımı
                      _buildSimpleAchievement(
                        'Amatör Bahçıvan',
                        'Bir oyunda 100 puan topla',
                        Icons.score,
                        Colors.blue,
                        gameProvider.achievements['score_100'] ?? false,
                      ),
                      
                      // 500 puan başarımı
                      _buildSimpleAchievement(
                        'Köstebek Avcısı',
                        'Bir oyunda 500 puan topla',
                        Icons.stars,
                        Colors.purple,
                        gameProvider.achievements['score_500'] ?? false,
                      ),
                      
                      // Altın köstebek başarımı
                      _buildSimpleAchievement(
                        'Altın Kazıcı',
                        'İlk altın köstebeği vur',
                        Icons.monetization_on,
                        Colors.amber,
                        gameProvider.achievements['golden_mole'] ?? false,
                      ),
                      
                      // Tüm modları deneme başarımı
                      _buildSimpleAchievement(
                        'Mod Uzmanı',
                        'Tüm oyun modlarında oyna',
                        Icons.category,
                        Colors.teal,
                        gameProvider.achievements['all_modes'] ?? false,
                      ),
                      
                      // Hayatta kalma modunda uzun süre başarımı
                      _buildSimpleAchievement(
                        'Bahçenin Efendisi',
                        'Hayatta kalma modunda 2 dakika dayan',
                        Icons.favorite,
                        Colors.red,
                        gameProvider.achievements['survival_master'] ?? false,
                      ),
                      
                      // Gelecek başarımlar
                      const SizedBox(height: 20),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                        child: Text(
                          'GELECEK BAŞARIMLAR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown.shade700,
                          ),
                        ),
                      ),
                      
                      // Gelecekte eklenecek başarımlar
                      _buildSimpleLockedAchievement(
                        'Bahçe Krallığı',
                        'Gelecek güncellemede açılacak',
                      ),
                      
                      _buildSimpleLockedAchievement(
                        'Köstebek Sihirbazı',
                        'Gelecek güncellemede açılacak',
                      ),
                    ],
                  ),
                ),
              ),
              
              // İstatistik kartı - basitleştirilmiş
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade600,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Açılan başarım sayısı
                    Column(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_countUnlockedAchievements(gameProvider)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Açılan Başarımlar',
                          style: TextStyle(
                            fontSize: 12, 
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    // Tamamlanma oranı
                    Column(
                      children: [
                        Icon(
                          Icons.public,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_countUnlockedAchievements(gameProvider) * 100 ~/ 6}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Tamamlanma Oranı',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Açılmış başarım sayısını hesapla
  int _countUnlockedAchievements(GameProvider gameProvider) {
    int count = 0;
    gameProvider.achievements.forEach((key, value) {
      if (value) count++;
    });
    return count;
  }
  
  // Basitleştirilmiş başarım widget'ı
  Widget _buildSimpleAchievement(
    String title,
    String description,
    IconData icon,
    Color color,
    bool isUnlocked,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? color.withOpacity(0.15) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // İkon kısmı
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked ? color : Colors.grey.shade400,
                ),
                child: Icon(
                  isUnlocked ? icon : Icons.lock,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Başlık ve açıklama
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isUnlocked ? Colors.black87 : Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isUnlocked ? Colors.black54 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Onay ikonu
              if (isUnlocked)
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Basitleştirilmiş kilitli başarım widget'ı
  Widget _buildSimpleLockedAchievement(
    String title,
    String description,
  ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // İkon kısmı
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
              ),
              child: const Icon(
                Icons.help_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Başlık ve açıklama
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}