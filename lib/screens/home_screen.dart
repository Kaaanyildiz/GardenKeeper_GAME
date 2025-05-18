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
import '../providers/game/game_provider.dart';
import 'mode_selection_screen.dart'; // Yeni eklenen ekran
import '../widgets/level_progress_bar.dart';
import 'daily_tasks_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 400;
    
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            width: double.infinity,
            height: double.infinity,
          ),
          // Profil butonu (sağ üst)
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.brown.shade700.withOpacity(0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
          // Ana içerik
          SafeArea(
            bottom: true,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Kullanılabilir alan sınırlarını al
                final maxHeight = constraints.maxHeight;
                final maxWidth = constraints.maxWidth;
              
                // Butonlar için boyut hesaplama - ekranın %50'sinden fazla olmamasını sağla
                final buttonWidth = maxWidth * 0.5 > 200 ? 200.0 : maxWidth * 0.5;
              
                return Center( // İçeriği merkeze yerleştir
                  child: SizedBox(
                    width: maxWidth,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: maxWidth * 0.08,
                        right: maxWidth * 0.08,
                        bottom: maxHeight * 0.04, // Alt kısımdaki boşluğu azalttım
                      ),
                      child: Column(
                        children: [
                          // Üst boşluk - daha az boşluk
                          SizedBox(height: maxHeight * 0.01), // 0.02'den 0.01'e düşürdüm
                        
                          // Oyun Logosu - Daha küçük boyut
                          SizedBox(
                            width: maxWidth * 0.8, 
                            height: maxHeight * 0.20, // 0.25'ten 0.20'ye düşürdüm
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        
                          // Daha az boşluk
                          SizedBox(height: maxHeight * 0.01), // 0.02'den 0.01'e düşürdüm
                        
                          // Köstebek animasyonu - biraz daha küçük
                          Container(
                            width: maxWidth * 0.20, // 0.25'ten 0.20'ye düşürdüm
                            height: maxHeight * 0.09, // 0.12'den 0.09'a düşürdüm
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: Image.asset(
                              'assets/images/mole_normal.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        
                          // Modern Seviye Barı (yeni)
                          const LevelProgressBar(),
                          SizedBox(height: maxHeight * 0.01),
                        
                          // Yüksek skoru göster (Selector ile optimize)
                          Selector<GameProvider, int>(
                            selector: (_, provider) => provider.highScore,
                            builder: (_, highScore, __) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: maxWidth * 0.05,
                                vertical: maxHeight * 0.01,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.brown.shade700.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                'YÜKSEK SKOR: $highScore',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          
                          // Günlük Görev göstergesi
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const DailyTasksScreen()),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: EdgeInsets.symmetric(
                                horizontal: maxWidth * 0.05,
                                vertical: maxHeight * 0.008,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade700.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.green.shade900, width: 2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today, color: Colors.white, size: isSmallScreen ? 16 : 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'GÜNLÜK GÖREV HAZIR!',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 12 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        
                          // Butonlara daha fazla alan yaratmak için
                          const SizedBox(height: 20),
                        
                          // Butonlar - ekran boyutuna göre ölçeklenecek şekilde
                          Expanded( // Spacer yerine kalan alana buton alanını yerleştirdim
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center, // Butonları dikey olarak ortala
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Başlat butonu - yeni mod seçimi ekranına yönlendirildi
                                GestureDetector(
                                  onTap: () {
                                    gameProvider.fullResetGameState(); // Ana menüden oyun başlatılırken state'i tam sıfırla
                                    gameProvider.playButtonSound();
                                    Navigator.push(
                                      context, 
                                      MaterialPageRoute(
                                        builder: (context) => const ModeSelectionScreen(),
                                      )
                                    );
                                  },
                                  child: SizedBox(
                                    width: buttonWidth,
                                    height: maxHeight * 0.12,
                                    child: Image.asset(
                                      'assets/images/button_play.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              
                                SizedBox(height: maxHeight * 0.02),
                              
                                // Başarımlar butonu
                                buildSimpleMenuButton(
                                  context: context,
                                  icon: Icons.emoji_events,
                                  label: 'BAŞARIMLAR',
                                  buttonWidth: buttonWidth * 0.4,
                                  color: Colors.amber.shade800,
                                  onTap: () {
                                    gameProvider.playButtonSound();
                                    Navigator.pushNamed(context, '/achievements');
                                  },
                                ),
                              
                                SizedBox(height: maxHeight * 0.015),
                              
                                // Ayarlar butonu
                                buildSimpleMenuButton(
                                  context: context,
                                  icon: Icons.settings,
                                  label: 'AYARLAR',
                                  buttonWidth: buttonWidth * 0.4,
                                  color: Colors.brown.shade600,
                                  onTap: () {
                                    gameProvider.playButtonSound();
                                    Navigator.pushNamed(context, '/settings');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // Basitleştirilmiş menü butonu widget'ı
  Widget buildSimpleMenuButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required double buttonWidth,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    
    return Column(
      mainAxisSize: MainAxisSize.min, // Sadece gerektiği kadar yer kaplasın
      children: [
        InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            width: buttonWidth,
            padding: const EdgeInsets.all(8), // 10'dan 8'e düşürdüm
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: color,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isSmallScreen ? 24 : 32, // 28/36'dan 24/32'ye düşürdüm
            ),
          ),
        ),
        
        // Buton etiketi
        Padding(
          padding: const EdgeInsets.only(top: 4), // 8'den 4'e düşürdüm
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 12 : 16, // 14/18'den 12/16'ya düşürdüm
              shadows: [
                Shadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}