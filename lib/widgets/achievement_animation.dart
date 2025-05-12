import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

class AchievementAnimation extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onClose;
  final bool isTask; // Görev mi başarım mı?

  const AchievementAnimation({
    super.key,
    required this.title,
    required this.description,
    required this.onClose,
    this.isTask = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isTask ? Colors.green.shade800 : Colors.amber.shade800,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(77), // 0.3 opasiteye eşdeğer
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animasyonlu başlık
              Text(
                isTask ? 'Görev Tamamlandı!' : 'Başarım Açıldı!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Lottie animasyonu
              SizedBox(
                height: 120,
                child: Lottie.asset(
                  isTask 
                      ? 'assets/animations/task_complete.json' 
                      : 'assets/animations/achievement_unlocked.json',
                  fit: BoxFit.contain,
                  repeat: false,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Başarım/Görev başlığı
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Açıklama
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Kapatma butonu
              ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  'Tamam',
                  style: TextStyle(
                    color: isTask ? Colors.green.shade800 : Colors.amber.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ).animate().scale(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
        ).then().shake(
          duration: const Duration(milliseconds: 300),
          hz: 2,
        ),
      ),
    );
  }
}

// Başarım animasyonunu göstermek için yardımcı fonksiyon
void showAchievementPopup(
  BuildContext context, 
  String title, 
  String description,
  {bool isTask = false}
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AchievementAnimation(
        title: title,
        description: description,
        isTask: isTask,
        onClose: () {
          Navigator.of(context).pop();
        },
      );
    },
  );
}