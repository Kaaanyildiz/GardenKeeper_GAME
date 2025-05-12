import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../utils/game_provider.dart';

// Oyun içi mesajları görüntülemek için widget
class GameMessagesOverlay extends StatelessWidget {
  const GameMessagesOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final messages = gameProvider.messages;
    
    return Stack(
      children: [
        // Ekrandaki mesajlar (can kaybı, süre, vb.)
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Column(
            children: messages.map((message) {
              final color = _getMessageColor(message.type);
                return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha(230), // Daha belirgin arka plan
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(80), // Daha belirgin gölge
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      message.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Daha büyük yazı tipi
                        letterSpacing: 0.5, // Harfler arası boşluk
                      ),
                    ),
                  ),
                ),
              ).animate()
                .fadeIn(duration: const Duration(milliseconds: 200)) // Daha hızlı görünme
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.1, 1.1), // Biraz daha büyük ölçekte
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut, // Daha çarpıcı animasyon
                )
                .then()
                .fadeOut(
                  delay: const Duration(milliseconds: 1500), // Daha kısa süre görünsün
                  duration: const Duration(milliseconds: 400),
                );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  // Mesaj tipine göre renk belirle
  Color _getMessageColor(MessageType type) {
    switch (type) {
      case MessageType.success:
        return Colors.green.shade700;
      case MessageType.warning:
        return Colors.orange.shade700;
      case MessageType.error:
        return Colors.red.shade700;
      case MessageType.info:
        return Colors.blue.shade700;
    }
  }
}