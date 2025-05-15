enum MoleType {
  normal,   // Normal köstebek
  golden,   // Altın köstebek (ekstra puan)
  speedy,   // Hızlı köstebek (kısa süre görünür)
  tough,    // Dayanıklı köstebek (2 vuruş gerektirir)
  healing,  // İyileştirici köstebek (can yeniler)
} 

// Köstebek türlerine göre puan değerleri
extension MoleTypePoints on MoleType {
  int get basePoints {
    switch (this) {
      case MoleType.normal:
        return 100;
      case MoleType.golden:
        return 300;
      case MoleType.speedy:
        return 200;
      case MoleType.tough:
        return 150;
      case MoleType.healing:
        return 50;
    }
  }
  
  // Görünme süresi (milisaniye)
  int get visibilityDuration {
    switch (this) {
      case MoleType.normal:
        return 1500;
      case MoleType.golden:
        return 1000;
      case MoleType.speedy:
        return 800;
      case MoleType.tough:
        return 2000;
      case MoleType.healing:
        return 1200;
    }
  }
  
  // Spawn olma şansı (yüzde)
  int get spawnChance {
    switch (this) {
      case MoleType.normal:
        return 60;
      case MoleType.golden:
        return 10;
      case MoleType.speedy:
        return 15;
      case MoleType.tough:
        return 10;
      case MoleType.healing:
        return 5;
    }
  }
} 