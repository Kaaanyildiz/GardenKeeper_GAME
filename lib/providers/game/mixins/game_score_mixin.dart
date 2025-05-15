import 'dart:async';
import 'package:flutter/material.dart';

mixin GameScoreMixin on ChangeNotifier {
  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  double _multiplier = 1.0;
  Timer? _comboTimer;

  // Getters
  int get score => _score;
  int get combo => _combo;
  int get maxCombo => _maxCombo;
  double get multiplier => _multiplier;

  // Score methods
  void addScore(int points) {
    _score += (points * _multiplier).round();
    _increaseCombo();
    notifyListeners();
  }

  void _increaseCombo() {
    _combo++;
    if (_combo > _maxCombo) {
      _maxCombo = _combo;
    }

    _updateMultiplier();
    _resetComboTimer();
    notifyListeners();
  }

  void _updateMultiplier() {
    if (_combo >= 10) {
      _multiplier = 2.0;
    } else if (_combo >= 5) {
      _multiplier = 1.5;
    } else {
      _multiplier = 1.0;
    }
  }

  void _resetComboTimer() {
    _comboTimer?.cancel();
    _comboTimer = Timer(const Duration(seconds: 2), () {
      _combo = 0;
      _multiplier = 1.0;
      notifyListeners();
    });
  }

  void resetScore() {
    _score = 0;
    _combo = 0;
    _maxCombo = 0;
    _multiplier = 1.0;
    _comboTimer?.cancel();
    notifyListeners();
  }
}