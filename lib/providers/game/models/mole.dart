import '../enums/mole_type.dart';

class Mole {
  final MoleType type;
  int health;
  bool isVisible;
  bool isHit;
  DateTime? spawnTime;
  DateTime? lastHitTime;
  
  Mole({
    required this.type,
    this.health = 1,
    this.isVisible = false,
    this.isHit = false,
    this.spawnTime,
    this.lastHitTime,
  });
  
  // Köstebeğin görünme süresini kontrol et
  bool get shouldHide {
    if (!isVisible || isHit || spawnTime == null) return false;
    final age = DateTime.now().difference(spawnTime!).inMilliseconds;
    return age >= type.visibilityDuration;
  }
  
  // Köstebeğe vurulduğunda
  void hit() {
    health--;
    lastHitTime = DateTime.now();
    if (health <= 0) {
      isHit = true;
    }
  }
  
  // Köstebeği göster
  void show() {
    isVisible = true;
    isHit = false;
    spawnTime = DateTime.now();
    
    // Köstebek türüne göre sağlık ayarla
    health = type == MoleType.tough ? 2 : 1;
  }
  
  // Köstebeği gizle
  void hide() {
    isVisible = false;
    isHit = false;
    spawnTime = null;
    lastHitTime = null;
  }
  
  // Köstebeğin puanını hesapla
  int calculateScore() {
    if (!isHit) return 0;
    
    // Temel puan
    int score = type.basePoints;
    
    // Hız bonusu (1 saniyeden kısa sürede vurulursa)
    if (spawnTime != null && lastHitTime != null) {
      final reactionTime = lastHitTime!.difference(spawnTime!).inMilliseconds;
      if (reactionTime < 1000) {
        score += (score * 0.5).round(); // %50 bonus
      }
    }
    
    return score;
  }
} 