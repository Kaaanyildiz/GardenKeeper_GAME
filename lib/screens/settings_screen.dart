/*
 * Copyright © 2025 Mehmet Kaan YILDIZ
 * Garden Keeper - Köstebek vurma oyunu
 * Tüm hakları saklıdır.
 * 
 * Bu yazılım, MIT Lisansı altında lisanslanmıştır.
 * Lisans bilgisi için LICENSE dosyasını inceleyiniz.
 */

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../utils/game_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 400 || size.height < 600;
    final double paddingFactor = size.width > 600 ? 0.1 : 0.05;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Arkaplan resmi
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Üst panel
              Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back, size: isSmallScreen ? 24 : 30),
                      color: Colors.brown.shade800,
                    ),
                    const Spacer(),
                    Text(
                      'AYARLAR',
                      style: TextStyle(
                        fontSize: size.width * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade800,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(width: isSmallScreen ? 30 : 48), // Dengelemek için boş alan
                  ],
                ),
              ),
              
              SizedBox(height: size.height * 0.03),
              
              // Ayarlar Kartı
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * paddingFactor),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.brown.shade100,
                  child: Padding(
                    padding: EdgeInsets.all(size.width * 0.05),
                    child: Column(
                      children: [
                        // Zorluk seviyesi ayarı
                        Text(
                          'ZORLUK SEVİYESİ',
                          style: TextStyle(
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown.shade800,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        
                        // Zorluk seviyeleri butonları
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildDifficultyButton(
                              context, 
                              'KOLAY', 
                              gameProvider.difficulty == 'easy',
                              () => gameProvider.setDifficulty('easy'),
                              Colors.green,
                            ),
                            _buildDifficultyButton(
                              context, 
                              'NORMAL', 
                              gameProvider.difficulty == 'normal',
                              () => gameProvider.setDifficulty('normal'),
                              Colors.orange,
                            ),
                            _buildDifficultyButton(
                              context, 
                              'ZOR', 
                              gameProvider.difficulty == 'hard',
                              () => gameProvider.setDifficulty('hard'),
                              Colors.red,
                            ),
                          ],
                        ),
                        
                        SizedBox(height: size.height * 0.02),
                        const Divider(thickness: 2),
                        SizedBox(height: size.height * 0.02),
                        
                        // Ses ayarları
                        Text(
                          'SES AYARLARI',
                          style: TextStyle(
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown.shade800,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        
                        // Ses efektleri açma/kapama
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.04, 
                            vertical: size.height * 0.01
                          ),
                          decoration: BoxDecoration(
                            color: Colors.brown.shade200,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                gameProvider.soundEnabled ? 
                                  'assets/images/icon_sound_on.png' : 
                                  'assets/images/icon_sound_off.png',
                                width: isSmallScreen ? 24 : 30,
                                height: isSmallScreen ? 24 : 30,
                              ),
                              SizedBox(width: size.width * 0.03),
                              Text(
                                'Ses Efektleri',
                                style: TextStyle(
                                  fontSize: size.width * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown.shade800,
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                value: gameProvider.soundEnabled,
                                onChanged: (value) => gameProvider.setSoundEnabled(value),
                                activeColor: Colors.green.shade600,
                                activeTrackColor: Colors.green.shade200,
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: size.height * 0.015),
                        
                        // Müzik açma/kapama
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.04, 
                            vertical: size.height * 0.01
                          ),
                          decoration: BoxDecoration(
                            color: Colors.brown.shade200,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                gameProvider.musicEnabled ? 
                                  'assets/images/icon_music_on.png' : 
                                  'assets/images/icon_music_off.png',
                                width: isSmallScreen ? 24 : 30,
                                height: isSmallScreen ? 24 : 30,
                              ),
                              SizedBox(width: size.width * 0.03),
                              Text(
                                'Müzik',
                                style: TextStyle(
                                  fontSize: size.width * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown.shade800,
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                value: gameProvider.musicEnabled,
                                onChanged: (value) => gameProvider.setMusicEnabled(value),
                                activeColor: Colors.green.shade600,
                                activeTrackColor: Colors.green.shade200,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate()
                .fade(duration: 500.ms)
                .slide(begin: const Offset(0, 0.2), end: Offset.zero),
              
              const Spacer(),
              
              // En yüksek skor gösterimi
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.02,
                  horizontal: size.width * 0.04
                ),
                decoration: BoxDecoration(
                  color: Colors.brown.shade700,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'EN YÜKSEK SKOR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/star.png',
                          width: isSmallScreen ? 24 : 30,
                          height: isSmallScreen ? 24 : 30,
                        ),
                        SizedBox(width: size.width * 0.02),
                        Text(
                          '${gameProvider.highScore}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 22 : 28,
                            fontWeight: FontWeight.bold,
                          ),
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
  
  // Zorluk seviyesi butonu oluştur
  Widget _buildDifficultyButton(
    BuildContext context, 
    String text, 
    bool isSelected, 
    VoidCallback onTap,
    MaterialColor color,
  ) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 400;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 16, 
          vertical: isSmallScreen ? 8 : 12
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.shade600 : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.shade800.withValues(alpha: 128),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 12 : 16,
          ),
        ),
      ),
    );
  }
}