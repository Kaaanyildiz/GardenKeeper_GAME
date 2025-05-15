import 'package:flutter/foundation.dart';
import 'dart:math';
import '../enums/game_mode.dart';
import '../enums/power_up_type.dart';

mixin GameState on ChangeNotifier {
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
    _gameMode = mode;
    notifyListeners();
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