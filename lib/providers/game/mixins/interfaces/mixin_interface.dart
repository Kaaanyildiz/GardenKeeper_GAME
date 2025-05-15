import 'package:flutter/foundation.dart';

/// Tüm mixin'lerin ortak interface'i
abstract class MixinInterface with ChangeNotifier {
  void notifyListenersInternal() {
    notifyListeners();
  }
}
