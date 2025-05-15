import 'package:flutter/material.dart';

enum MessageType {
  info,     // Bilgi mesajı
  success,  // Başarı mesajı
  warning,  // Uyarı mesajı
  error,    // Hata mesajı
  combo,    // Kombo mesajı
  reward,   // Ödül mesajı
  task,     // Görev mesajı
} 

// Mesaj türlerine göre stil özellikleri
extension MessageTypeStyle on MessageType {
  // Mesaj rengi
  Color get color {
    switch (this) {
      case MessageType.info:
        return Colors.blue;
      case MessageType.success:
        return Colors.green;
      case MessageType.warning:
        return Colors.orange;
      case MessageType.error:
        return Colors.red;
      case MessageType.combo:
        return Colors.purple;
      case MessageType.reward:
        return Colors.amber;
      case MessageType.task:
        return Colors.teal;
    }
  }
  
  // İkon
  IconData get icon {
    switch (this) {
      case MessageType.info:
        return Icons.info_outline;
      case MessageType.success:
        return Icons.check_circle_outline;
      case MessageType.warning:
        return Icons.warning_amber_outlined;
      case MessageType.error:
        return Icons.error_outline;
      case MessageType.combo:
        return Icons.flash_on;
      case MessageType.reward:
        return Icons.star_outline;
      case MessageType.task:
        return Icons.task_alt;
    }
  }
  
  // Animasyon süresi (milisaniye)
  int get animationDuration {
    switch (this) {
      case MessageType.combo:
        return 800;  // Hızlı
      case MessageType.reward:
        return 1500; // Normal
      case MessageType.success:
      case MessageType.task:
        return 2000; // Normal
      default:
        return 3000; // Uzun
    }
  }
} 