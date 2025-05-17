import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game/enums/message_type.dart';
import '../providers/game/game_provider.dart';
import '../providers/game/models/game_message.dart';

// Oyun içi mesajları görüntülemek için widget
class GameMessagesOverlay extends StatelessWidget {
  const GameMessagesOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<GameProvider, List<GameMessage>>(
      selector: (_, provider) => List.unmodifiable(provider.messages),
      builder: (context, messages, child) {
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
                          color: color.withAlpha(230),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(80),
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
                            fontSize: 18,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ).animate()
                    .fadeIn(duration: const Duration(milliseconds: 200))
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.1, 1.1),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                    )
                    .then()
                    .fadeOut(
                      delay: const Duration(milliseconds: 1500),
                      duration: const Duration(milliseconds: 400),
                    );
                }).toList(),
              ),
            ),
          ],
        );
      },
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
      case MessageType.combo:
        return Colors.purple.shade700;
      case MessageType.reward:
        return Colors.amber.shade700;
      case MessageType.task:
        return Colors.teal.shade700;
    }
  }
}