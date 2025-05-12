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
  late AnimationController _confettiController;
  late AnimationController _moleAnimationController;
  final List<Confetti> _confetti = [];
  final Random _random = Random();
  int _stars = 0;
  bool _showMole = false;
  bool _confettiGenerated = false;
  
  @override
  void initState() {
    super.initState();
    
    // Konfeti animasyonu için controller - daha düşük fps ile çalıştır
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    
    // Köstebek animasyonu için controller
    _moleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Skor bazlı yıldız hesapla
    _calculateStars();
    
    // Sadece rekor kırıldıysa konfeti göster
    if (widget.score > widget.highScore && widget.score > 0) {
      // Animasyonu biraz gecikmeli başlat
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _confettiController.forward();
        }
      });
    }
    
    // Köstebeği rastgele zamanlarda göster - sadece yüksek skorlarda
    if (widget.score > 15) {
      _showRandomMole();
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Konfetileri sadece bir kez oluştur ve sadece yüksek skor varsa
    if (!_confettiGenerated && widget.score > widget.highScore && widget.score > 0) {
      _generateConfetti();
      _confettiGenerated = true;
    }
  }
  
  void _generateConfetti() {
    // Konfeti sayısını azalt - daha az konfeti ile daha iyi performans
    final int confettiCount = MediaQuery.of(context).size.width < 400 ? 20 : 30;
    
    for (int i = 0; i < confettiCount; i++) {
      _confetti.add(
        Confetti(
          position: Offset(
            _random.nextDouble() * MediaQuery.of(context).size.width,
            -20 - _random.nextDouble() * 100,
          ),
          color: Color.fromRGBO(
            _random.nextInt(255),
            _random.nextInt(255),
            _random.nextInt(255),
            1,
          ),
          size: 6 + _random.nextDouble() * 6, // Konfeti boyutunu azalt
          speed: 80 + _random.nextDouble() * 120, // Hızı biraz azalt
        ),
      );
    }
  }
  
  void _calculateStars() {
    // Skor bazlı yıldız sayısını hesapla
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
    // Rastgele zamanlarda köstebeği göster
    Future.delayed(Duration(seconds: 2 + _random.nextInt(4)), () {
      if (mounted) {
        setState(() {
          _showMole = true;
        });
        
        _moleAnimationController.reset();
        _moleAnimationController.forward();
        
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _showMole = false;
            });
            _showRandomMole(); // Rekursif olarak devam et
          }
        });
      }
    });
  }
  
  @override
  void dispose() {
    _confettiController.dispose();
    _moleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400 || size.height < 600;
    
    return Dialog(
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
                // Oyun Bitti Başlığı - daha basit animasyon
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
                ).animate()
                  .fade(duration: 400.ms)
                  .scale(begin: const Offset(0.5, 0.5), duration: 500.ms, curve: Curves.elasticOut),
                
                SizedBox(height: isSmallScreen ? 16 : 25),
                
                // Yıldız Derecesi - daha basit animasyon
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
                      ).animate(
                        target: index < _stars ? 1 : 0,
                      )
                        .fadeIn(delay: Duration(milliseconds: 500 + index * 200), duration: 300.ms)
                        .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0), 
                               delay: Duration(milliseconds: 500 + index * 200), 
                               duration: 500.ms, 
                               curve: Curves.elasticOut),
                    );
                  }),
                ),
                
                SizedBox(height: isSmallScreen ? 16 : 25),
                
                // Skor Bölümü - daha basit animasyon
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
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/star.png',
                                width: isSmallScreen ? 24 : 30,
                                height: isSmallScreen ? 24 : 30,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.score}',
                                style: TextStyle(
                                  fontFamily: 'JungleAdventurer',
                                  fontSize: isSmallScreen ? 24 : 32,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 2,
                                      color: Colors.black.withOpacity(0.5),
                                      offset: const Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/star.png',
                                width: isSmallScreen ? 24 : 30,
                                height: isSmallScreen ? 24 : 30,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.highScore}',
                                style: TextStyle(
                                  fontFamily: 'JungleAdventurer',
                                  fontSize: isSmallScreen ? 24 : 32,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 2,
                                      color: Colors.black.withOpacity(0.5),
                                      offset: const Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate()
                  .fade(delay: 400.ms, duration: 400.ms)
                  .slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOut),
                
                // Yeni Rekor Mesajı - daha basit animasyon
                if (widget.score > widget.highScore && widget.score > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade700,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      'YENİ REKOR!',
                      style: TextStyle(
                        fontFamily: 'JungleAdventurer',
                        fontSize: isSmallScreen ? 18 : 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ).animate()
                    .fadeIn(delay: 800.ms, duration: 400.ms)
                    .slideY(begin: 0.3, duration: 400.ms),
                
                // Motivasyon Mesajı - daha basit animasyon
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
                ).animate()
                  .fadeIn(delay: 1000.ms, duration: 400.ms),
                
                SizedBox(height: isSmallScreen ? 20 : 30),
                
                // Butonlar row - butonlar içindeki animasyonları kaldırıyoruz
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Ana Menü butonu
                    _buildButton(
                      text: 'ANA MENÜ',
                      icon: Icons.home,
                      color: Colors.brown.shade700,
                      onTap: widget.onHome,
                      delay: 600,
                      isSmallScreen: isSmallScreen,
                      slideDirection: -0.5,
                    ),
                    
                    // Tekrar Oyna butonu
                    _buildButton(
                      text: 'TEKRAR OYNA',
                      icon: Icons.replay,
                      color: Colors.green.shade700,
                      onTap: widget.onRestart,
                      delay: 700,
                      isSmallScreen: isSmallScreen,
                      slideDirection: 0.5,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Üstteki Köstebek Görseli - daha basit animasyon
          Positioned(
            top: 0,
            child: Container(
              width: isSmallScreen ? 100 : 140,
              height: isSmallScreen ? 100 : 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.brown.shade800,
                border: Border.all(
                  color: Colors.brown.shade900,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Köstebek deliği (arka plan)
                    ClipOval(
                      child: Image.asset(
                        'assets/images/hole.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    
                    // Zıplayan köstebek 
                    if (_showMole)
                      AnimatedBuilder(
                        animation: _moleAnimationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 15 * (1 - _moleAnimationController.value * 2).abs() - 20),
                            child: Image.asset(
                              'assets/images/mole_normal.png',
                              width: isSmallScreen ? 70 : 100,
                              height: isSmallScreen ? 70 : 100,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ).animate()
            .fadeIn(duration: 300.ms)
            .scale(begin: const Offset(0.2, 0.2), end: const Offset(1.0, 1.0), duration: 400.ms, curve: Curves.easeOut),
          
          // Konfeti efekti - sadece yeni rekor kırıldığında göster
          if (widget.score > widget.highScore && widget.score > 0)
            Positioned.fill(
              child: CustomPaint(
                isComplex: true, // Kompleks çizim olduğunu belirt
                willChange: true, // Sürekli değişeceğini belirt
                painter: ConfettiPainter(
                  confetti: _confetti,
                  animation: _confettiController,
                ),
              ),
            ),
        ],
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
  
  // Özel buton oluşturucu
  Widget _buildButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required int delay,
    required bool isSmallScreen,
    required double slideDirection,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: isSmallScreen ? 30 : 40,
            ),
            SizedBox(height: 5),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'JungleAdventurer',
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .fade(delay: delay.ms, duration: 400.ms)
      .slideX(begin: slideDirection, duration: 500.ms, curve: Curves.easeOutQuad);
  }
}

// Konfeti animasyonu için gerekli sınıflar
class Confetti {
  Offset position;
  Color color;
  double size;
  double speed;
  double angle = 0;

  Confetti({
    required this.position,
    required this.color,
    required this.size,
    required this.speed,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<Confetti> confetti;
  final Animation<double> animation;
  final double lastValue;

  ConfettiPainter({
    required this.confetti,
    required this.animation,
  }) : lastValue = animation.value, super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Konfetileri 2 frame'de bir çiz (performans için)
    final int frameSkip = 2;
    final int step = (confetti.length ~/ frameSkip) + 1;
    
    for (var i = 0; i < confetti.length; i += step) {
      final confetto = confetti[i];
      
      // Animasyon değerine göre konfetinin pozisyonunu güncelle
      final newPosition = Offset(
        confetto.position.dx,
        confetto.position.dy + confetto.speed * animation.value,
      );
      
      confetto.position = newPosition;
      confetto.angle += 0.05;
      
      // Ekrandan çıktıysa, tekrar üst kısımdan başlat
      if (confetto.position.dy > size.height) {
        confetto.position = Offset(
          confetto.position.dx,
          -20,
        );
      }
      
      final paint = Paint()..color = confetto.color;
      
      // Konfetileri döndürerek çiz
      canvas.save();
      canvas.translate(confetto.position.dx, confetto.position.dy);
      canvas.rotate(confetto.angle);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: confetto.size,
          height: confetto.size / 2,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) {
    // Yalnızca animasyon değeri değiştiğinde repaint et
    return lastValue != oldDelegate.lastValue;
  }
}