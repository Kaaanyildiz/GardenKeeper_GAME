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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 400;
    
    return Scaffold(
      // Scaffold'un tüm arkaplanını dolduracak şekilde arka plan görselini ayarlama
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover, // Tüm ekranı kaplayacak şekilde ayarla
          ),
        ),
        // Tüm içeriği ekranı kaplamak için genişlik ve yükseklik değerlerini belirle
        width: double.infinity,  
        height: double.infinity,
        // Alt ve üst boşlukları doğru şekilde ayarlamak için safeArea'yı mantıklı kullan
        child: SafeArea(
          bottom: true, // Alt kısmın da güvenli alan içinde olmasını sağla
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
                      bottom: maxHeight * 0.08, // Alt kısımdaki boşluğu artır
                    ),
                    child: Column(
                      children: [
                        // Üst boşluk - daha az boşluk
                        SizedBox(height: maxHeight * 0.02),
                        
                        // Oyun Logosu - Daha büyük boyut
                        SizedBox(
                          width: maxWidth * 0.8, // 0.7'den 0.8'e artırıldı
                          height: maxHeight * 0.25, // 0.2'den 0.25'e artırıldı
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ).animate()
                            .fade(duration: 300.ms)
                            .scale(delay: 300.ms),
                        ),
                        
                        // Daha az boşluk
                        SizedBox(height: maxHeight * 0.02), // 0.04'den 0.02'ye düşürüldü
                        
                        // Köstebek animasyonu - biraz daha küçük
                        Container(
                          width: maxWidth * 0.25, // 0.3'den 0.25'e düşürüldü
                          height: maxHeight * 0.12, // 0.15'den 0.12'ye düşürüldü
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Image.asset(
                            'assets/images/mole_normal.png',
                            fit: BoxFit.contain,
                          ).animate(
                            onPlay: (controller) => controller.repeat(),
                          )
                            .fade(duration: 500.ms)
                            .scale(delay: 300.ms)
                            .then()
                            .moveY(
                              begin: 0,
                              end: 20,
                              duration: 700.ms,
                              curve: Curves.easeInOut,
                            )
                            .then()
                            .moveY(
                              begin: 20,
                              end: 0,
                              duration: 700.ms,
                              curve: Curves.easeInOut,
                            ),
                        ),
                        
                        SizedBox(height: maxHeight * 0.04),
                        
                        // Yüksek skoru göster
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: maxWidth * 0.05,
                            vertical: maxHeight * 0.01,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.brown.shade700.withAlpha(180),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'YÜKSEK SKOR: ${gameProvider.highScore}',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ).animate()
                          .fade(duration: 500.ms, delay: 400.ms),
                        
                        // Geriye kalan alanı doldurmak için spacer
                        const Spacer(),
                        
                        // Butonlar - ekran boyutuna göre ölçeklenecek şekilde, maksimum boyut sınırlaması ile
                        Padding(
                          padding: EdgeInsets.only(bottom: maxHeight * 0.02),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Başlat butonu - maksimum genişlik sınırlaması ile
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/game');
                                },
                                child: SizedBox(
                                  width: buttonWidth,
                                  child: Image.asset(
                                    'assets/images/button_play.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ).animate()
                                .fade(duration: 500.ms, delay: 600.ms)
                                .slideY(begin: 0.5, end: 0),
                              
                              SizedBox(height: maxHeight * 0.025),
                              
                              // Ayarlar butonu - Daha belirgin ve tıklanabilir görünüm
                              Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/settings');
                                    },
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: Container(
                                      width: buttonWidth * 0.4,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.brown.shade600.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 5,
                                            spreadRadius: 1,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Colors.brown.shade800,
                                          width: 2,
                                        ),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Buton içeriği - özel efekt ve gölge ile
                                          Image.asset(
                                            'assets/images/button_settings.png',
                                            fit: BoxFit.contain,
                                          ),
                                          
                                          // Hover efekti - tıklanabilir görünüm için
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(context, '/settings');
                                              },
                                              splashColor: Colors.white.withOpacity(0.2),
                                              highlightColor: Colors.white.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(15),
                                              child: Container(
                                                width: buttonWidth * 0.6,
                                                height: 60,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  // Buton etiketi - daha açıklayıcı
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      'AYARLAR',
                                      style: TextStyle(
                                        color: Colors.brown.shade800,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmallScreen ? 14 : 20,
                                        shadows: [
                                          Shadow(
                                            color: Colors.white.withOpacity(0.5),
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ).animate()
                                .fade(duration: 500.ms, delay: 800.ms)
                                .slideY(begin: 0.5, end: 0),
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
      ),
    );
  }
}