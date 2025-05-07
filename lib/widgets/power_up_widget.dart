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

class PowerUpWidget extends StatefulWidget {
  final String powerUpName;
  final String description;
  final IconData icon;
  final Color color;
  final int durationInSeconds;
  final VoidCallback? onComplete;

  const PowerUpWidget({
    super.key,
    required this.powerUpName,
    required this.description,
    required this.icon,
    required this.color,
    required this.durationInSeconds,
    this.onComplete,
  });

  @override
  State<PowerUpWidget> createState() => _PowerUpWidgetState();
}

class _PowerUpWidgetState extends State<PowerUpWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  String _remainingTime = "";

  @override
  void initState() {
    super.initState();
    
    // Animasyon kontrolcüsü oluştur
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationInSeconds),
    );
    
    // İlerleme çubuğu animasyonu
    _progressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_animationController);
    
    // Kalan süre hesaplama listener'ı
    _animationController.addListener(() {
      final int remainingSeconds = (_progressAnimation.value * widget.durationInSeconds).ceil();
      setState(() {
        _remainingTime = "$remainingSeconds sn";
      });
    });
    
    // Tamamlandığında callback çağır
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
    
    // Animasyonu başlat
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 400;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.color.withOpacity(0.8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // İkon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: isSmallScreen ? 18 : 24,
                ),
              ),
              
              SizedBox(width: 8),
              
              // Güçlendirme Bilgisi ve İlerleme
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Güçlendirme Adı
                  Text(
                    widget.powerUpName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 12 : 14,
                      color: widget.color,
                    ),
                  ),
                  
                  SizedBox(height: 4),
                  
                  // İlerleme Çubuğu ve Kalan Süre
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // İlerleme Çubuğu
                      Container(
                        width: isSmallScreen ? 80 : 100,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progressAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getProgressColor(widget.color),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 8),
                      
                      // Kalan Süre
                      Text(
                        _remainingTime,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          fontWeight: FontWeight.bold,
                          color: widget.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ).animate(target: _animationController.value < 0.2 ? 1 : 0)
          .shimmer(duration: 400.ms, color: widget.color.withOpacity(0.7));
      },
    );
  }
  
  // İlerleme çubuğu rengi
  Color _getProgressColor(Color baseColor) {
    if (_progressAnimation.value > 0.6) {
      return baseColor;
    } else if (_progressAnimation.value > 0.3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}