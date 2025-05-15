enum TaskType {
  hitMoles,      // Köstebek vurma görevi
  hitGoldenMoles, // Altın köstebek vurma görevi
  reachScore,    // Belirli bir puana ulaşma görevi
  playTimeInMode, // Belirli bir modda belirli süre geçirme görevi
  useBoosts,     // Güçlendirme kullanma görevi
  achieveCombo,  // Kombo yapma görevi
  surviveTime,   // Belirli süre hayatta kalma görevi
  perfectGame,   // Hatasız oyun tamamlama görevi
  collectPowerUps,
  winGames,
} 

// Görev türlerine göre açıklamalar
extension TaskTypeDescription on TaskType {
  String get description {
    switch (this) {
      case TaskType.hitMoles:
        return "Belirtilen sayıda köstebek vur";
      case TaskType.hitGoldenMoles:
        return "Belirtilen sayıda altın köstebek vur";
      case TaskType.reachScore:
        return "Belirtilen puana ulaş";
      case TaskType.playTimeInMode:
        return "Belirtilen modda süre geçir";
      case TaskType.useBoosts:
        return "Belirtilen sayıda güçlendirme kullan";
      case TaskType.achieveCombo:
        return "Belirtilen kombo sayısına ulaş";
      case TaskType.surviveTime:
        return "Belirtilen süre hayatta kal";
      case TaskType.perfectGame:
        return "Hiç köstebek kaçırmadan oyunu tamamla";
      case TaskType.collectPowerUps:
        return "Belirtilen güçlendirme öğelerini topla";
      case TaskType.winGames:
        return "Belirtilen sayıda oyun kazan";
    }
  }
  
  // İlerleme birimi
  String get progressUnit {
    switch (this) {
      case TaskType.hitMoles:
      case TaskType.hitGoldenMoles:
      case TaskType.useBoosts:
        return "adet";
      case TaskType.reachScore:
        return "puan";
      case TaskType.playTimeInMode:
      case TaskType.surviveTime:
        return "saniye";
      case TaskType.achieveCombo:
        return "kombo";
      case TaskType.perfectGame:
        return "oyun";
      case TaskType.collectPowerUps:
        return "güçlendirme öğesi";
      case TaskType.winGames:
        return "oyun";
    }
  }
} 