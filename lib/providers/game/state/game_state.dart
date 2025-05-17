import 'package:flutter/foundation.dart';
import 'dart:math';
import 'dart:async';
import '../enums/game_mode.dart';
import '../enums/power_up_type.dart';
import '../enums/mole_type.dart';
import '../enums/message_type.dart';
import '../models/game_message.dart';
import '../../../utils/audio_manager.dart';

mixin GameState on ChangeNotifier {
  final AudioManager _audioManager = AudioManager();

  final int _gridSize = 9;
  int get gridSize => _gridSize;
  
  int _score = 0;
  int get score => _score;
  void setScore(int value) {
    _score = value;
    notifyListeners();
  }

  int _highScore = 0;
  int get highScore => _highScore;
  void setHighScore(int value) {
    _highScore = value;
    notifyListeners();
  }

  int _currentCombo = 0;
  int get currentCombo => _currentCombo;
  void setCombo(int value) {
    _currentCombo = value;
    notifyListeners();
  }

  bool _hasPowerUp = false;
  bool get hasPowerUp => _hasPowerUp;
  void setPowerUp(bool value) {
    _hasPowerUp = value;
    notifyListeners();
  }

  PowerUpType? _activePowerUp;
  PowerUpType? get activePowerUp => _activePowerUp;
  void setActivePowerUp(PowerUpType? value) {
    _activePowerUp = value;
    notifyListeners();
  }

  int _powerUpDuration = 0;
  int get powerUpDuration => _powerUpDuration;
  void setPowerUpDuration(int value) {
    _powerUpDuration = value;
    notifyListeners();
  }

  int _pendingPowerUpIndex = -1;
  int get pendingPowerUpIndex => _pendingPowerUpIndex;
  void setPendingPowerUpIndex(int value) {
    _pendingPowerUpIndex = value;
    notifyListeners();
  }

  PowerUpType? _pendingPowerUpType;
  PowerUpType? get pendingPowerUpType => _pendingPowerUpType;
  void setPendingPowerUpType(PowerUpType? value) {
    _pendingPowerUpType = value;
    notifyListeners();
  }

  bool _isGameActive = false;
  bool get isGameActive => _isGameActive;
  void setGameActive(bool value) {
    _isGameActive = value;
    notifyListeners();
  }

  int _timeLeft = 60;
  int get timeLeft => _timeLeft;
  void setTimeLeft(int value) {
    _timeLeft = value;
    notifyListeners();
  }

  int _lives = 3;
  int get lives => _lives;
  void setLives(int value) {
    _lives = value;
    notifyListeners();
  }

  int _coins = 0;
  int get coins => _coins;
  void addCoins(int amount) {
    _coins += amount;
    notifyListeners();
  }
  GameMode _gameMode = GameMode.classic;
  GameMode get gameMode => _gameMode;
  void setGameMode(GameMode mode) {
    if (_gameMode != mode) {
      _gameMode = mode;
      _resetMoles();
      notifyListeners();
    }
  }
  GameMode get currentGameMode => _gameMode;

  // --- MOLE STATE ---
  List<bool> _moleVisible = List.filled(9, false);
  List<bool> _moleHit = List.filled(9, false);
  List<MoleType> _moleTypes = List.filled(9, MoleType.normal);

  List<bool> get moleVisible => _moleVisible;
  List<bool> get moleHit => _moleHit;
  List<MoleType> get moleTypes => _moleTypes;
  void setMoleVisible(int index, bool value) {
    _moleVisible[index] = value;
    notifyListeners();
  }
  void setMoleType(int index, dynamic type) {
    _moleTypes[index] = type;
    notifyListeners();
  }

  Timer? _gameTimer;
  Timer? _moleSpawnTimer;

  void startGame() {
    _isGameActive = true;
    _timeLeft = 60;
    _lives = 3;
    _resetMoles();
    _startGameTimer();
    _startMoleSpawnTimer();
    notifyListeners();
  }

  void endGame() {
    _isGameActive = false;
    _gameTimer?.cancel();
    _moleSpawnTimer?.cancel();
    _resetMoles();
    notifyListeners();
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameMode != GameMode.survival) {
        _timeLeft--;
        if (_timeLeft <= 0) {
          endGame();
        }
      }
      notifyListeners();
    });
  }

  void _startMoleSpawnTimer() {
    _moleSpawnTimer?.cancel();
    // GameProvider'dan interval alınır
    final interval = (this as dynamic).moleSpawnInterval ?? 1200;
    _moleSpawnTimer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      if (!_isGameActive) return;
      _spawnRandomMole();
    });
  }

  void _spawnRandomMole() {
    final random = Random();
    int index = random.nextInt(_gridSize);
    int tries = 0;
    
    // Boş bir delik bul
    while (_moleVisible[index] && tries < 10) {
      index = random.nextInt(_gridSize);
      tries++;
    }
    
    _moleVisible[index] = true;
    _moleHit[index] = false;

    MoleType selectedType = MoleType.normal;
    int roll = random.nextInt(100);
    
    // Mod'a göre köstebek tipini belirle
    if (_gameMode == GameMode.special) {
      // Özel modda köstebek dağılımı:
      // %35 Altın
      // %35 Hızlı
      // %20 Dayanıklı
      // %10 Normal
      if (roll < 35) {
        selectedType = MoleType.golden;
      } else if (roll < 70) {
        selectedType = MoleType.speedy;
      } else if (roll < 90) {
        selectedType = MoleType.tough;
      }
      print('[DEBUG] MOD: $_gameMode | ROLL: $roll | TYPE: $selectedType');
    } else if (_gameMode == GameMode.survival) {
      // Hayatta kalma modunda %25 şansla iyileştirici köstebek
      if (roll < 25) {
        selectedType = MoleType.healing;
      }
      print('[DEBUG] MOD: $_gameMode | ROLL: $roll | TYPE: $selectedType');
    } else {
      print('[DEBUG] MOD: $_gameMode | ROLL: $roll | TYPE: $selectedType');
    }
    
    _moleTypes[index] = selectedType;
    print('[DEBUG] moleTypes[$index] = $_moleTypes');
    notifyListeners();

    // Görünürlük süresini ayarla
    int baseDuration = (this as dynamic).moleVisibleDuration ?? 1200;
    int adjustedDuration = baseDuration;

    // Köstebek tipine göre süreyi ayarla
    switch (selectedType) {
      case MoleType.speedy:
        adjustedDuration = (baseDuration * 0.6).round(); // %40 daha hızlı
        break;
      case MoleType.tough:
        adjustedDuration = (baseDuration * 1.3).round(); // %30 daha yavaş
        break;
      case MoleType.golden:
        adjustedDuration = (baseDuration * 0.8).round(); // %20 daha hızlı
        break;
      default:
        break;
    }

    // Süre sonunda köstebeği otomatik gizle
    Future.delayed(Duration(milliseconds: adjustedDuration), () {
      if (_isGameActive && _moleVisible[index] && !_moleHit[index]) {
        _moleVisible[index] = false;
        if (_gameMode == GameMode.survival) {
          _lives--; // Hayatta kalma modunda kaçırılan köstebek can azaltır
          if (_lives <= 0) {
            endGame();
          }
        }
        notifyListeners();
      }
    });
  }

  void _resetMoles() {
    _moleVisible = List.filled(_gridSize, false);
    _moleHit = List.filled(_gridSize, false);
    _moleTypes = List.filled(_gridSize, MoleType.normal);
  }
  // Oyun puanları, mesaj ve ses sistemi
  void updateGameScore(int points, {bool showMessage = true}) {
    if (!_isGameActive) return;

    int finalPoints = points;
    
    // Combo bonusu
    if (_currentCombo >= 5) {
      finalPoints = (finalPoints * 1.5).round();
      if (showMessage) {
        showCombo(_currentCombo); // Combo mesajını göster
        _audioManager.playComboSound(); // Combo sesini çal
      }
    }

    // Güçlendirme etkisi
    if (_hasPowerUp && _activePowerUp == PowerUpType.hammer) {
      finalPoints *= 2;
      if (showMessage) {
        showSuccess('Çifte Puan! +$finalPoints');
      }
    }

    // GameScoreMixin'den gelen addScore metodunu çağır
    (this as dynamic).addScore(finalPoints);

    // Rekor kontrolü
    if (score > _highScore) {
      _highScore = score;
      if (showMessage) {
        showSuccess('Yeni Rekor! $score');
      }
    }
  }

  // Mesaj sistemi
  final List<GameMessage> _messages = [];
  List<GameMessage> get messages => _messages;
  
  void showCombo(int combo) {
    showMessage('$combo COMBO! 🔥', type: MessageType.combo);
  }

  void showSuccess(String text) {
    showMessage(text, type: MessageType.success);
  }

  void showWarning(String text) {
    showMessage(text, type: MessageType.warning);
  }
  
  void showMessage(String text, {MessageType type = MessageType.info, Duration? duration}) {
    _messages.add(GameMessage(
      text: text,
      type: type,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  // Köstebeğe vurma fonksiyonu - güncellendi
  void hitMole(int index) {
    if (!_isGameActive || !_moleVisible[index] || _moleHit[index]) return;

    MoleType moleType = _moleTypes[index];
    int basePoints = moleType.basePoints;
    
    _moleHit[index] = true;
    
    // Köstebek tipine göre özel efektler
    switch (moleType) {
      case MoleType.healing:
        _lives = min(_lives + 1, 5);
        showSuccess('Can Yenilendi! ❤️');
        break;
      case MoleType.golden:
        if (_gameMode == GameMode.timeAttack) {
          _timeLeft += 3;
          showSuccess('+3 Saniye! ⌛');
        }
        addCoins(5);
        showSuccess('Altın Köstebek! +5 Altın 🪙');
        break;
      case MoleType.tough:
        // İlk vuruşta hasar verme, ama puanı azalt
        basePoints = (basePoints * 0.5).round();
        showWarning('Dayanıklı Köstebek! 💪');
        break;
      case MoleType.speedy:
        showSuccess('Hızlı Köstebek! +${basePoints} 🏃');
        break;
      default:
        if (_gameMode == GameMode.timeAttack) {
          _timeLeft += 2;
          showSuccess('+2 Saniye! ⌛');
        }
        break;
    }

    // Combo ve puanı güncelle
    _currentCombo++;
    updateGameScore(basePoints);

    // Ses efektini çal
    // _audioManager.playHitSound(moleType); // ARTIK MoleHole içinde tetikleniyor

    // Vurulmuş hali göster ve combo timer'ı başlat
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_isGameActive && _moleVisible[index]) {
        _moleVisible[index] = false;
        _resetComboTimer();
        notifyListeners();
      }
    });

    notifyListeners();
  }

  // Combo sistemi için timer
  Timer? _comboTimer;
  void _resetComboTimer() {
    _comboTimer?.cancel();
    _comboTimer = Timer(const Duration(seconds: 2), () {
      if (_currentCombo > 0) {
        _currentCombo = 0;
        notifyListeners();
      }
    });
  }

  void resetGameState() {
    _score = 0;
    _currentCombo = 0;
    _timeLeft = 60;
    _lives = 3;
    _hasPowerUp = false;
    _activePowerUp = null;
    _powerUpDuration = 0;
    _pendingPowerUpIndex = -1;
    _pendingPowerUpType = null;
    notifyListeners();
  }
}