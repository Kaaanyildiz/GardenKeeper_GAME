import '../enums/message_type.dart';

class GameMessage {
  final String text;
  final DateTime timestamp;
  final MessageType type;
  final int? score;  // Opsiyonel puan gösterimi
  final bool isAnimated;  // Animasyonlu gösterim
  
  GameMessage({
    required this.text, 
    required this.timestamp,
    this.type = MessageType.info,
    this.score,
    this.isAnimated = true,
  });
  
  // Mesajın yaşını kontrol et (milisaniye)
  int get age => DateTime.now().difference(timestamp).inMilliseconds;
  
  // Mesajın gösterilip gösterilmeyeceğini kontrol et
  bool get shouldShow => age < type.animationDuration;
  
  // Opaklık değeri (animasyon için)
  double get opacity {
    if (!isAnimated) return 1.0;
    final duration = type.animationDuration;
    if (age >= duration) return 0.0;
    if (age <= duration * 0.1) return age / (duration * 0.1); // Fade in
    if (age >= duration * 0.8) return 1.0 - ((age - duration * 0.8) / (duration * 0.2)); // Fade out
    return 1.0;
  }
  
  // Ölçek değeri (animasyon için)
  double get scale {
    if (!isAnimated) return 1.0;
    final duration = type.animationDuration;
    if (age >= duration) return 0.8;
    if (age <= duration * 0.1) return 0.8 + (0.2 * age / (duration * 0.1)); // Scale up
    if (age >= duration * 0.8) return 1.0 - (0.2 * (age - duration * 0.8) / (duration * 0.2)); // Scale down
    return 1.0;
  }
} 