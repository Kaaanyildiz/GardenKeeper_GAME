import 'dart:async';
import 'dart:math';
import '../state/game_state.dart';
import '../enums/power_up_type.dart';
import '../enums/mole_type.dart';
import 'game_audio_mixin.dart';

mixin GamePowerUpMixin on GameState, GameAudioMixin {
  // Güçlendirme sistemi değişkenleri
  PowerUpType? _activePowerUp;
  bool _powerUpActive = false;
  int _powerUpDuration = 0;
  int _pendingPowerUpIndex = -1;
  PowerUpType? _pendingPowerUpType;
  Timer? _powerUpTimer;

  // Getters
  bool get hasPowerUp => _powerUpActive;
  PowerUpType? get activePowerUp => _activePowerUp;
  int get powerUpDuration => _powerUpDuration;
  int get pendingPowerUpIndex => _pendingPowerUpIndex;
  PowerUpType? get pendingPowerUpType => _pendingPowerUpType;

  // Power-up şansları ve süreleri (varsayılan değerlerle)
  final Map<PowerUpType, int> _powerUpChances = {
    PowerUpType.hammer: 40,
    PowerUpType.timeFreezer: 30,
    PowerUpType.moleReveal: 30,
  };
  final Map<PowerUpType, int> _powerUpDurations = {
    PowerUpType.hammer: 3,
    PowerUpType.timeFreezer: 5,
    PowerUpType.moleReveal: 3,
  };

  // --- MOLE STATE ---
  // Bu değişkenler ve fonksiyonlar, köstebeklerin görünürlüğü ve tipi için gereklidir
  // Artık zincir GameState'e ulaşacağı için burada UnimplementedError fırlatmaya gerek yok!
  // Bu getter/setter'lar tamamen kaldırılmalı, zincir GameState'e ulaşacak

  // Güçlendirme yönetimi
  void spawnPowerUp() {
    if (!isGameActive || _powerUpActive) return;

    // Rastgele bir konum seç
    final random = Random();
    int index = random.nextInt(9);

    // Görünür köstebekleri atla
    while (moleVisible[index]) {
      index = random.nextInt(9);
    }

    // Rastgele bir güçlendirme seç
    final PowerUpType randomPowerUp = _getRandomPowerUp();

    // Güçlendirmeyi yerleştir
    _pendingPowerUpIndex = index;
    _pendingPowerUpType = randomPowerUp;

    // Belirli bir süre sonra güçlendirmeyi kaldır
    Future.delayed(const Duration(seconds: 3), () {
      if (isGameActive && _pendingPowerUpIndex == index) {
        _pendingPowerUpIndex = -1;
        _pendingPowerUpType = null;
      }
    });
  }

  // Rastgele güçlendirme seçimi (şans oranlarına göre)
  PowerUpType _getRandomPowerUp() {
    final random = Random();
    final roll = random.nextInt(100);
    var cumulative = 0;

    for (var entry in _powerUpChances.entries) {
      cumulative += entry.value;
      if (roll < cumulative) {
        return entry.key;
      }
    }

    return PowerUpType.hammer; // Varsayılan
  }

  // Güçlendirme aktifleştirme
  void activatePowerUp(PowerUpType type) {
    _activePowerUp = type;
    _powerUpActive = true;
    _powerUpDuration = _powerUpDurations[type] ?? 5;

    playPowerUpSound();

    // Güçlendirme süresini başlat
    _startPowerUpTimer();

    // Güçlendirme tipine göre özel efektler
    switch (type) {
      case PowerUpType.moleReveal:
        _revealAllMoles();
        break;
      case PowerUpType.shield:
        // Kalkan efektini başlat
        break;
      case PowerUpType.magnet:
        // Mıknatıs efektini başlat
        break;
      default:
        break;
    }
  }

  // Güçlendirme zamanlayıcısı
  void _startPowerUpTimer() {
    _powerUpTimer?.cancel();
    _powerUpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_powerUpDuration > 0) {
        _powerUpDuration--;
        if (_powerUpDuration <= 0) {
          deactivatePowerUp();
        }
      }
    });
  }

  // Güçlendirmeyi deaktive et
  void deactivatePowerUp() {
    _powerUpActive = false;
    _activePowerUp = null;
    _powerUpDuration = 0;
    _powerUpTimer?.cancel();
  }

  // Tüm köstebekleri göster (MoleReveal güçlendirmesi için)
  void _revealAllMoles() {
    for (int i = 0; i < moleVisible.length; i++) {
      if (!moleVisible[i]) {
        setMoleVisible(i, true);
        setMoleType(i, MoleType.normal);
      }
    }

    // 3 saniye sonra görünmez olanları gizle
    Future.delayed(const Duration(seconds: 3), () {
      for (int i = 0; i < moleVisible.length; i++) {
        if (isGameActive && moleVisible[i] && !moleHit[i]) {
          setMoleVisible(i, false);
        }
      }
    });
  }

  // Güçlendirmeleri sıfırla
  void resetPowerUps() {
    _powerUpActive = false;
    _activePowerUp = null;
    _powerUpDuration = 0;
    _pendingPowerUpIndex = -1;
    _pendingPowerUpType = null;
    _powerUpTimer?.cancel();
  }

  // Temizleme
  void disposePowerUps() {
    _powerUpTimer?.cancel();
  }
}