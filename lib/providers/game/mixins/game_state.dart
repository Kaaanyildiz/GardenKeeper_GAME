import 'dart:async';
import 'dart:math';
import '../enums/game_mode.dart';
import '../enums/mole_type.dart';

mixin GameState {
  Timer? _gameTimer;
  bool _isGameActive = false;
  int _timeLeft = 60;
  int _lives = 3;
  GameMode _currentGameMode = GameMode.classic;
  List<bool> _moleVisible = List.filled(9, false);
  List<bool> _moleHit = List.filled(9, false);
  List<MoleType> _moleTypes = List.filled(9, MoleType.normal);

  // Getters
  bool get isGameActive => _isGameActive;
  int get timeLeft => _timeLeft;
  int get lives => _lives;
  GameMode get currentGameMode => _currentGameMode;
  List<bool> get moleVisible => _moleVisible;
  List<bool> get moleHit => _moleHit;
  List<MoleType> get moleTypes => _moleTypes;

  // Setters
  void setGameMode(GameMode mode) {
    _currentGameMode = mode;
  }

  void setGameTimer(Timer? timer) {
    _gameTimer = timer;
  }

  Timer? get gameTimer => _gameTimer;

  // Game control methods
  void startGame() {
    _isGameActive = true;
    _timeLeft = 60;
    _lives = 3;
    _resetMoles();
    _startGameTimer();
  }

  void endGame() {
    _isGameActive = false;
    _gameTimer?.cancel();
    _resetMoles();
  }

  void resetGame() {
    _isGameActive = false;
    _timeLeft = 60;
    _lives = 3;
    _gameTimer?.cancel();
    _resetMoles();
  }

  void _resetMoles() {
    _moleVisible = List.filled(9, false);
    _moleHit = List.filled(9, false);
    _moleTypes = List.filled(9, MoleType.normal);
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentGameMode != GameMode.survival) {
        _timeLeft--;
        if (_timeLeft <= 0) {
          endGame();
        }
      }
    });
  }

  // Mole control methods
  void setMoleVisible(int index, bool visible) {
    _moleVisible[index] = visible;
  }

  void setMoleHit(int index, bool hit) {
    _moleHit[index] = hit;
  }

  void setMoleType(int index, MoleType type) {
    _moleTypes[index] = type;
  }
}