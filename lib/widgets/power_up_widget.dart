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

  const PowerUpWidget({
    super.key,
    required this.powerUpName,
    required this.description,
    required this.icon,
    required this.color,
    required this.durationInSeconds,
  });

  @override
  State<PowerUpWidget> createState() => _PowerUpWidgetState();
}

class _PowerUpWidgetState extends State<PowerUpWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    // Geri sayım animasyonu için controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationInSeconds),
    );
    
    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
    
    // Animasyonu başlat
    _controller.forward();
  }
  
  @override
  void didUpdateWidget(PowerUpWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Süre değişirse, controller'ı güncelle
    if (widget.durationInSeconds != oldWidget.durationInSeconds) {
      _controller.duration = Duration(seconds: widget.durationInSeconds);
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(widget.icon, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.powerUpName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    '${(widget.durationInSeconds * _progressAnimation.value).toInt()}s',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ).animate(
          target: _progressAnimation.value < 0.3 ? 1 : 0,
        ).shimmer(
          duration: 800.ms,
          color: Colors.white.withOpacity(0.4),
        );
      },
    );
  }
}