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
import '../providers/game/enums/mole_type.dart';
import '../providers/game/enums/power_up_type.dart';
import 'dart:math';
import '../utils/audio_manager.dart';

// Parçacık efekti için yeni sınıf
class ParticleEffect extends StatelessWidget {
  final Color color;
  final Offset position;
  final double size;
  final double angle;
  final double speed;

  const ParticleEffect({
    super.key,
    required this.color,
    required this.position,
    required this.size,
    required this.angle,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ).animate(
        onPlay: (controller) => controller.repeat(),
      )
      .move(
        begin: Offset.zero,
        end: Offset(
          cos(angle) * speed,
          sin(angle) * speed,
        ),
        duration: 500.ms,
        curve: Curves.easeOut,
      )
      .fadeOut(duration: 500.ms),
    );
  }
}

class MoleHole extends StatefulWidget {
  final int index;
  final bool isVisible;
  final bool isHit;
  final MoleType moleType; // Yeni eklenen köstebek türü
  final VoidCallback onTap;
  final bool isPowerUp; // Güçlendirme mi?
  final PowerUpType? powerUpType; // Güçlendirme tipi

  const MoleHole({
    super.key,
    required this.index,
    required this.isVisible,
    required this.isHit,
    this.moleType = MoleType.normal, // Varsayılan olarak normal köstebek
    required this.onTap,
    this.isPowerUp = false, // Varsayılan olarak güçlendirme değil
    this.powerUpType,
  });

  @override
  State<MoleHole> createState() => _MoleHoleState();
}

class _MoleHoleState extends State<MoleHole> {
  bool _showHammer = false;
  Offset _hammerPosition = Offset.zero;
  List<ParticleEffect> _particles = [];
  final Random _random = Random();

  void _handleTap(Offset tapPosition) {
    // Sadece köstebek görünür, vurulmamış ve güçlendirme değilse ses ve efekt tetiklenir
    if (widget.isVisible && !widget.isHit && !widget.isPowerUp) {
      setState(() {
        _showHammer = true;
        _hammerPosition = tapPosition;
        _createParticles(tapPosition);
      });
      AudioManager().playHitSound(widget.moleType);
      widget.onTap();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _showHammer = false;
          });
        }
      });
    } else {
      // Boşa tıklama: sadece çekiç animasyonu göster, ses ve onTap yok
      setState(() {
        _showHammer = true;
        _hammerPosition = tapPosition;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _showHammer = false;
          });
        }
      });
    }
  }

  void _createParticles(Offset center) {
    // Köstebek türüne göre parçacık rengi belirle
    Color particleColor;
    switch (widget.moleType) {
      case MoleType.golden:
        particleColor = Colors.amber;
        break;
      case MoleType.speedy:
        particleColor = Colors.blue;
        break;
      case MoleType.tough:
        particleColor = Colors.red;
        break;
      case MoleType.healing:
        particleColor = Colors.green;
        break;
      default:
        particleColor = Colors.brown;
    }

    // 8 parçacık oluştur
    for (int i = 0; i < 8; i++) {
      double angle = (i * pi / 4) + (_random.nextDouble() * 0.5 - 0.25);
      double speed = 50 + _random.nextDouble() * 30;
      double size = 4 + _random.nextDouble() * 4;

      _particles.add(
        ParticleEffect(
          color: particleColor,
          position: center,
          size: size,
          angle: angle,
          speed: speed,
        ),
      );
    }

    // Parçacıkları 500ms sonra temizle
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _particles.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        // Köstebek boyutunu ve konumunu ayarla
        final moleSize = size * 0.85; // Köstebek boyutunu biraz daha büyüttüm
        final holeSize = size * 0.9;
        // Köstebeğin Y pozisyonunu deliğin ortasına göre ayarla
        final moleYPosition = widget.isHit ? size * 0.3 : size * 0.25;
        
        return GestureDetector(
          onTapDown: (details) {
            _handleTap(details.localPosition);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.brown.shade800,
              borderRadius: BorderRadius.circular(size * 0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(77),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Köstebek deliği (daima görünür)
                Center(
                  child: Container(
                    width: holeSize,
                    height: holeSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size * 0.2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(size * 0.2),
                      child: Image.asset(
                        'assets/images/hole.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                
                // Altın köstebek efekti
                if (widget.isVisible && widget.moleType == MoleType.golden && !widget.isHit)
                  Positioned(
                    bottom: moleYPosition,
                    left: (size - moleSize) / 2,
                    width: moleSize,
                    height: moleSize,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size * 0.2),
                        gradient: RadialGradient(
                          colors: [
                            Colors.yellow.withOpacity(0.3),
                            Colors.amber.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          stops: const [0.4, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ).animate(
                    onPlay: (controller) => controller.repeat(),
                  )
                  .shimmer(
                    duration: 1.seconds,
                    color: Colors.amber.shade300.withOpacity(0.7),
                  ),
                
                // Dayanıklı köstebek efekti - çift halka
                if (widget.isVisible && widget.moleType == MoleType.tough && !widget.isHit)
                  Positioned(
                    bottom: moleYPosition,
                    left: (size - moleSize) / 2,
                    width: moleSize,
                    height: moleSize,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size * 0.2),
                        border: Border.all(
                          color: Colors.red.shade800.withOpacity(0.7),
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                
                // Güçlendirme görünümü
                if (widget.isVisible && widget.isPowerUp && widget.powerUpType != null)
                  Positioned(
                    bottom: moleYPosition,
                    left: (size - moleSize) / 2,
                    width: moleSize,
                    height: moleSize,
                    child: _buildPowerUpImage(widget.powerUpType!),
                  ).animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .fadeIn(duration: 300.ms)
                  .then()
                  .moveY(
                    begin: 5, 
                    end: -5,
                    duration: 1.seconds,
                    curve: Curves.easeInOut
                  ),
                
                // Köstebek (koşullu olarak görünür)
                if (widget.isVisible && !widget.isPowerUp)
                  Positioned(
                    bottom: moleYPosition,
                    left: (size - moleSize) / 2,
                    width: moleSize,
                    height: moleSize,
                    child: _buildMoleImage().animate(
                      onPlay: (controller) => controller.repeat(),
                    )
                    .then(delay: 300.ms)
                    .shake(
                      hz: _getMoleAnimationSpeed(),
                      curve: Curves.easeInOutCubic,
                    ),
                  ),
                  
                // Vurulma efekti (koşullu olarak görünür)
                if (widget.isHit)
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/explosion.png',
                      fit: BoxFit.contain,
                    ),
                  ).animate()
                    .scale(
                      duration: 300.ms,
                      curve: Curves.easeOutBack,
                    )
                    .then()
                    .fadeOut(duration: 300.ms),
                    
                // Çekiç animasyonu
                if (_showHammer)
                  Positioned(
                    left: _hammerPosition.dx - (size * 0.4),
                    top: _hammerPosition.dy - (size * 0.4),
                    width: size * 0.8,
                    height: size * 0.8,
                    child: Image.asset(
                      'assets/images/hammer.png',
                      fit: BoxFit.contain,
                    ).animate()
                      .rotate(
                        begin: -0.6,
                        end: 0.1,
                        duration: 200.ms,
                        curve: Curves.easeOutBack,
                      )
                  ),
                
                // Parçacık efektleri
                ..._particles,
              ],
            ),
          ),
        );
      }
    );
  }
    // Köstebek türüne göre doğru resmi döndür
  Widget _buildMoleImage() {
    // Köstebek türüne göre vurulmuş halleri için doğru görseli döndür
    if (widget.isHit) {
      switch (widget.moleType) {
        case MoleType.golden:
          return Image.asset(
            'assets/images/mole_golden_hit.png',
            fit: BoxFit.contain,
          );
        case MoleType.speedy:
          return Image.asset(
            'assets/images/mole_speedy_hit.png',
            fit: BoxFit.contain,
          );
        case MoleType.tough:
          return Image.asset(
            'assets/images/mole_tough_hit.png',
            fit: BoxFit.contain,
          );
        case MoleType.healing:
          return Image.asset(
            'assets/images/mole_healing_hit.png',
            fit: BoxFit.contain,
          );
        case MoleType.normal:
          return Image.asset(
            'assets/images/mole_hit.png',
            fit: BoxFit.contain,
          );
      }
    }
    
    // Köstebek türüne göre normal görselleri döndür
    switch (widget.moleType) {
      case MoleType.golden:
        return Image.asset(
          'assets/images/mole_golden.png',
          fit: BoxFit.contain,
        );
      
      case MoleType.speedy:
        return Image.asset(
          'assets/images/mole_speedy.png',
          fit: BoxFit.contain,
        );
      
      case MoleType.tough:
        return Image.asset(
          'assets/images/mole_tough.png',
          fit: BoxFit.contain,
        );
      
      case MoleType.healing:
        return Image.asset(
          'assets/images/mole_healing.png',
          fit: BoxFit.contain,
        );
      
      case MoleType.normal:
        return Image.asset(
          'assets/images/mole_normal.png',
          fit: BoxFit.contain,
        );
    }
  }
  
  // Güçlendirme türüne göre doğru resmi döndür
  Widget _buildPowerUpImage(PowerUpType powerUpType) {
    // Kullanılabilecek görseller yok, bu nedenle renkli daireler kullanıyoruz
    Color powerUpColor;
    IconData powerUpIcon;
    
    switch (powerUpType) {
      case PowerUpType.hammer:
        powerUpColor = Colors.amber.shade700;
        powerUpIcon = Icons.gavel;
        break;
      case PowerUpType.timeFreezer:
        powerUpColor = Colors.cyan.shade700;
        powerUpIcon = Icons.hourglass_disabled;
        break;
      case PowerUpType.moleReveal:
        powerUpColor = Colors.green.shade700;
        powerUpIcon = Icons.visibility;
        break;
      default:
        powerUpColor = Colors.purple.shade700;
        powerUpIcon = Icons.auto_awesome;
    }
    
    return Container(
      decoration: BoxDecoration(
        color: powerUpColor.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: powerUpColor.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Icon(
        powerUpIcon,
        color: Colors.white,
        size: 32,
      ),
    );
  }
  
  // Köstebek türüne göre animasyon hızını ayarla
  double _getMoleAnimationSpeed() {
    switch (widget.moleType) {
      case MoleType.speedy:
        return 8; // Daha hızlı
      case MoleType.golden:
        return 5;
      case MoleType.tough:
        return 3; // Daha yavaş
      case MoleType.healing:
        return 4.5; // İyileştirici köstebek animasyon hızı
      case MoleType.normal:
        return 4;
    }
  }
}
// (Bu dosyada Provider veya GameProvider kullanılmıyor, optimize etmek için ana ekranda GridView.builder'da Selector kullanılmalı. Burada ek bir değişiklik gerekmiyor.)