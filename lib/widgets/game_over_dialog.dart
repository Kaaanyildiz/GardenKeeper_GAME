/*
 * Copyright © 2025 Mehmet Kaan YILDIZ
 * Garden Keeper - Köstebek vurma oyunu
 * Tüm hakları saklıdır.
 * 
 * Bu yazılım, MIT Lisansı altında lisanslanmıştır.
 * Lisans bilgisi için LICENSE dosyasını inceleyiniz.
 */

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GameOverDialog extends StatefulWidget {
  final int score;
  final int highScore;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.highScore,
    required this.onRestart,
    required this.onHome,
  });

  @override
  State<GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends State<GameOverDialog> with TickerProviderStateMixin {
  late AnimationController _moleAnimationController;
  int _stars = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Köstebek animasyonu için controller
    _moleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Skor bazlı yıldız hesapla
    _calculateStars();
    
    // Köstebeği rastgele zamanlarda göster - sadece yüksek skorlarda
    if (widget.score > 15) {
      _showRandomMole();
    }
  }
  
  @override
  void dispose() {
    _moleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400 || size.height < 600;
    
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Ana Dialog İçeriği
            Container(
              margin: EdgeInsets.only(top: 60),
              padding: EdgeInsets.only(
                top: 70,
                left: isSmallScreen ? 16.0 : 24.0,
                right: isSmallScreen ? 16.0 : 24.0,
                bottom: isSmallScreen ? 16.0 : 24.0,
              ),
              width: size.width * 0.9,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.brown.shade200, 
                    Colors.brown.shade100
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
                border: Border.all(
                  color: Colors.brown.shade800,
                  width: 4,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Oyun Bitti Başlığı
                  Text(
                    'OYUN BİTTİ!',
                    style: TextStyle(
                      fontFamily: 'JungleAdventurer',
                      fontSize: isSmallScreen ? 32 : 40,
                      color: Colors.brown.shade900,
                      shadows: [
                        Shadow(
                          blurRadius: 5,
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isSmallScreen ? 16 : 25),
                  
                  // Yıldız Derecesi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Image.asset(
                          'assets/images/star.png',
                          width: isSmallScreen ? 40 : 60,
                          height: isSmallScreen ? 40 : 60,
                          color: index < _stars ? null : Colors.grey.withOpacity(0.5),
                        ),
                      );
                    }),
                  ),
                  
                  SizedBox(height: isSmallScreen ? 16 : 25),
                  
                  // Skor Bölümü
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.brown.shade800.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SKOR:',
                              style: TextStyle(
                                fontFamily: 'JungleAdventurer',
                                fontSize: isSmallScreen ? 18 : 24,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${widget.score}',
                              style: TextStyle(
                                fontFamily: 'JungleAdventurer',
                                fontSize: isSmallScreen ? 24 : 32,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'REKOR:',
                              style: TextStyle(
                                fontFamily: 'JungleAdventurer',
                                fontSize: isSmallScreen ? 18 : 24,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${widget.highScore}',
                              style: TextStyle(
                                fontFamily: 'JungleAdventurer',
                                fontSize: isSmallScreen ? 24 : 32,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Yeni Rekor Mesajı
                  if (widget.score > widget.highScore && widget.score > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade700,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'YENİ REKOR!',
                        style: TextStyle(
                          fontFamily: 'JungleAdventurer',
                          fontSize: isSmallScreen ? 18 : 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  
                  // Motivasyon Mesajı
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      _getMotivationMessage(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'JungleAdventurer',
                        fontSize: isSmallScreen ? 14 : 18,
                        color: Colors.brown.shade900,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: isSmallScreen ? 20 : 30),
                  
                  // Butonlar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Ana Menü butonu
                      ElevatedButton(
                        onPressed: widget.onHome,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade700,
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.home,
                              color: Colors.white,
                              size: isSmallScreen ? 30 : 40,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'ANA MENÜ',
                              style: TextStyle(
                                fontFamily: 'JungleAdventurer',
                                fontSize: isSmallScreen ? 14 : 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Tekrar Oyna butonu
                      ElevatedButton(
                        onPressed: widget.onRestart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.replay,
                              color: Colors.white,
                              size: isSmallScreen ? 30 : 40,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'TEKRAR OYNA',
                              style: TextStyle(
                                fontFamily: 'JungleAdventurer',
                                fontSize: isSmallScreen ? 14 : 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
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
    );
  }
  
  // Skor durumuna göre motivasyon mesajı
  String _getMotivationMessage() {
    if (_stars == 3) {
      return 'Muhteşem! Bahçeni mükemmel korudun!';
    } else if (_stars == 2) {
      return 'Harika iş çıkardın! Biraz daha pratikle bahçeni daha iyi koruyabilirsin.';
    } else if (_stars == 1) {
      return 'İyi bir başlangıç! Bahçe koruma becerilerini geliştirmeye devam et.';
    } else {
      return 'Üzülme, bir dahaki sefere bahçeni daha iyi koruyabileceksin!';
    }
  }
  
  void _calculateStars() {
    if (widget.score >= 350) {
      _stars = 3;
    } else if (widget.score >= 250) {
      _stars = 2;
    } else if (widget.score >= 200) {
      _stars = 1;
    } else {
      _stars = 0;
    }
  }
  
  void _showRandomMole() {
    Future.delayed(Duration(seconds: 2 + Random().nextInt(4)), () {
      if (mounted) {
        setState(() {
          
        });
        
        _moleAnimationController.reset();
        _moleAnimationController.forward();
        
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _showRandomMole();
          }
        });
      }
    });
  }
}