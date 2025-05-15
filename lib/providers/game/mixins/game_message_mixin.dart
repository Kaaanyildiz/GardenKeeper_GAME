import 'dart:async';
import '../models/game_message.dart';
import '../enums/message_type.dart';
import 'interfaces/mixin_interface.dart';

mixin GameMessageMixin on MixinInterface {
  // Aktif mesajlar listesi
  final List<GameMessage> _messages = [];
  
  // Mesaj temizleme zamanlayıcısı
  Timer? _cleanupTimer;
  
  // Geçerli mesaj
  String _currentMessage = '';
  bool _isMessageVisible = false;
  Duration _messageDuration = const Duration(seconds: 2);

  // Getters
  List<GameMessage> get messages => List.unmodifiable(_messages);
  String get currentMessage => _currentMessage;
  bool get isMessageVisible => _isMessageVisible;

  // Mesaj ekle
  void addMessage(String text, {
    MessageType type = MessageType.info,
    int? score,
    bool isAnimated = true,
  }) {
    final message = GameMessage(
      text: text,
      timestamp: DateTime.now(),
      type: type,
      score: score,
      isAnimated: isAnimated,
    );
    
    _messages.add(message);
    _startCleanupTimer();
    notifyListeners();
  }
  
  // Başarı mesajı
  void showSuccess(String text, {int? score}) {
    addMessage(text, type: MessageType.success, score: score);
  }
  
  // Uyarı mesajı
  void showWarning(String text) {
    addMessage(text, type: MessageType.warning);
  }
  
  // Hata mesajı
  void showError(String text) {
    addMessage(text, type: MessageType.error);
  }
  
  // Kombo mesajı
  void showCombo(int combo) {
    addMessage(
      '$combo Combo!',
      type: MessageType.combo,
      isAnimated: true,
    );
  }
  
  // Ödül mesajı
  void showReward(String text, int amount) {
    addMessage(
      '$text +$amount',
      type: MessageType.reward,
      score: amount,
    );
  }
  
  // Görev mesajı
  void showTask(String text) {
    addMessage(text, type: MessageType.task);
  }
  
  // Temizleme zamanlayıcısını başlat
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _cleanupMessages(),
    );
  }
  
  // Eski mesajları temizle
  void _cleanupMessages() {
    final now = DateTime.now();
    _messages.removeWhere((message) => 
      !message.shouldShow || 
      now.difference(message.timestamp).inSeconds > 5
    );
    
    if (_messages.isEmpty) {
      _cleanupTimer?.cancel();
    }
    
    notifyListeners();
  }
  
  // Tüm mesajları temizle
  void clearMessages() {
    _messages.clear();
    _cleanupTimer?.cancel();
    notifyListeners();
  }
  
  // Temizleme
  void disposeMessages() {
    _cleanupTimer?.cancel();
    _messages.clear();
  }

  // Mesaj göster
  void showMessage(String message, {Duration? duration}) {
    _currentMessage = message;
    _isMessageVisible = true;
    _messageDuration = duration ?? const Duration(seconds: 2);
    notifyListenersInternal();

    Future.delayed(_messageDuration, () {
      if (_currentMessage == message) {
        _isMessageVisible = false;
        _currentMessage = '';
        notifyListenersInternal();
      }
    });
  }

  // Mesajı gizle
  void hideMessage() {
    _isMessageVisible = false;
    _currentMessage = '';
    notifyListenersInternal();
  }
}