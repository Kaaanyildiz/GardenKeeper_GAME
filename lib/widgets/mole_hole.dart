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
import '../utils/game_provider.dart';

class MoleHole extends StatefulWidget {
  final int index;
  final bool isVisible;
  final bool isHit;
  final MoleType moleType; // Yeni eklenen köstebek türü
  final VoidCallback onTap;

  const MoleHole({
    super.key,
    required this.index,
    required this.isVisible,
    required this.isHit,
    this.moleType = MoleType.normal, // Varsayılan olarak normal köstebek
    required this.onTap,
  });

  @override
  State<MoleHole> createState() => _MoleHoleState();
}

class _MoleHoleState extends State<MoleHole> {
  bool _showHammer = false;
  Offset _hammerPosition = Offset.zero;

  void _handleTap(Offset tapPosition) {
    // Çekici göster
    setState(() {
      _showHammer = true;
      _hammerPosition = tapPosition;
    });
    
    // Köstebeğe vurma işlevini çağır
    widget.onTap();
    
    // Kısa bir süre sonra çekici gizle
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showHammer = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        // Köstebek boyutunu ekran boyutuna göre ayarla
        final moleSize = size * 0.7;
        final moleYPosition = widget.isHit ? -size * 0.1 : size * 0.1;
        
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
              children: [
                // Köstebek deliği (daima görünür)
                SizedBox.expand(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(size * 0.2),
                    child: Image.asset(
                      'assets/images/hole.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                // Köstebek (koşullu olarak görünür)
                if (widget.isVisible)
                  Positioned(
                    bottom: moleYPosition, // Vurulduğunda daha aşağıya iner
                    left: 0,
                    right: 0,
                    child: SizedBox(
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
                    
                // Altın köstebek efekti
                if (widget.isVisible && widget.moleType == MoleType.golden && !widget.isHit)
                  Positioned.fill(
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
                  Positioned.fill(
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
                    
                // Çekiç animasyonu
                if (_showHammer)
                  Positioned(
                    left: _hammerPosition.dx - (size * 0.4), // Çekicin merkezi tıklama noktasında olsun
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
              ],
            ),
          ),
        );
      }
    );
  }
  
  // Köstebek türüne göre doğru resmi döndür
  Widget _buildMoleImage() {
    if (widget.isHit) {
      return Image.asset(
        'assets/images/mole_hit.png',
        fit: BoxFit.contain,
      );
    }
    
    // Köstebek türüne göre resim seç
    switch (widget.moleType) {
      case MoleType.golden:
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            1.2, 0.0, 0.0, 0.0, 35.0, // Kırmızı
            0.0, 1.2, 0.0, 0.0, 25.0, // Yeşil
            0.0, 0.0, 0.8, 0.0, 0.0,  // Mavi
            0.0, 0.0, 0.0, 1.0, 0.0,  // Alfa
          ]),
          child: Image.asset(
            'assets/images/mole_normal.png',
            fit: BoxFit.contain,
          ),
        );
      
      case MoleType.speedy:
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            1.0, 0.0, 0.0, 0.0, 0.0,  // Kırmızı
            0.0, 1.0, 0.0, 0.0, 0.0,  // Yeşil
            0.0, 0.0, 1.2, 0.0, 35.0, // Mavi
            0.0, 0.0, 0.0, 1.0, 0.0,  // Alfa
          ]),
          child: Image.asset(
            'assets/images/mole_normal.png',
            fit: BoxFit.contain,
          ),
        );
      
      case MoleType.tough:
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            1.3, 0.0, 0.0, 0.0, 30.0, // Kırmızı - daha kızıl
            0.0, 0.8, 0.0, 0.0, 0.0,  // Yeşil - azalt
            0.0, 0.0, 0.8, 0.0, 0.0,  // Mavi - azalt
            0.0, 0.0, 0.0, 1.0, 0.0,  // Alfa
          ]),
          child: Image.asset(
            'assets/images/mole_normal.png',
            fit: BoxFit.contain,
          ),
        );
      
      case MoleType.normal:
        return Image.asset(
          'assets/images/mole_normal.png',
          fit: BoxFit.contain,
        );
    }
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
      case MoleType.normal:
        return 4;
    }
  }
}