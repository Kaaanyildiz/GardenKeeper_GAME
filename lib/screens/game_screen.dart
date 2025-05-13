/*
 * Copyright © 2025 Mehmet Kaan YILDIZ
 * Garden Keeper - Köstebek vurma oyunu
 * Tüm hakları saklıdır.
 * 
 * Bu yazılım, MIT Lisansı altında lisanslanmıştır.
 * Lisans bilgisi için LICENSE dosyasını inceleyiniz.
 */

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../utils/game_provider.dart';
import '../widgets/mole_hole.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/power_up_widget.dart'; // Güçlendirme widget'ı
import '../widgets/game_messages_overlay.dart'; // Mesaj overlay'i

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // GameProvider referansını sınıf düzeyinde saklayalım
  late GameProvider _gameProvider;
  bool _dialogShowing = false;
  
  // Mod değişimlerinde kullanılacak animasyon kontrolcüsü
  late AnimationController _modeTransitionController;
  
  // Oyun modları için renk haritaları
  final Map<GameMode, Color> _modeColors = {
    GameMode.classic: Colors.brown.shade800,
    GameMode.timeAttack: Colors.blue.shade700,
    GameMode.survival: Colors.red.shade700,
    GameMode.special: Colors.purple.shade700,
  };
  
  // Oyun modları için overlay renkler
  final Map<GameMode, Color> _modeOverlayColors = {
    GameMode.classic: Colors.brown.shade400,
    GameMode.timeAttack: Colors.blue.shade300,
    GameMode.survival: Colors.red.shade300,
    GameMode.special: Colors.purple.shade300,
  };
  
  // Oyun modları için dekoratif ikonlar
  final Map<GameMode, String> _modeDecorationIcons = {
    GameMode.classic: 'assets/images/hammer.png',
    GameMode.timeAttack: 'assets/images/icon_time.png', // Varsayılan zaman ikonu
    GameMode.survival: 'assets/images/heart.png', // Varsayılan kalp ikonu
    GameMode.special: 'assets/images/star.png',
  };

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  Offset _shakeOffset = Offset.zero;
    @override
  void initState() {
    super.initState();
    
    // Provider referansını başlangıçta al ve sakla
    _gameProvider = Provider.of<GameProvider>(context, listen: false);
    
    // Mod değişim animasyonu için controller
    _modeTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Oyunu otomatik olarak başlat
    Future.delayed(Duration.zero, () {
      if (mounted) {
        _gameProvider.startGame();
        // Günlük görevleri kontrol et
        _gameProvider.checkDailyTasks();
        // Mod geçiş animasyonunu başlat
        _modeTransitionController.forward();
      }
    });

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.easeInOut,
      ),
    );

    _shakeAnimation.addListener(() {
      if (mounted) {
        setState(() {
          // Rastgele yönlerde sarsıntı
          _shakeOffset = Offset(
            sin(_shakeAnimation.value * 10) * 5,
            cos(_shakeAnimation.value * 10) * 5,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    // Animasyon controller'ını dispose et
    _modeTransitionController.dispose();
    
    // Saklanan referansı kullan, context üzerinden erişme
    // Oyunu güvenli bir şekilde bitirmek için Future.microtask kullanıyoruz
    if (_gameProvider.isGameActive) {
      Future.microtask(() {
        _gameProvider.endGame();
      });
    }
    _shakeController.dispose();
    super.dispose();
  }

  // Güvenli geri dönüş fonksiyonu
  void _safeNavigateBack() {
    if (_gameProvider.isGameActive) {
      // Önce oyunu bitir ve sonra Future.microtask ile navigate et
      _gameProvider.endGame();
      Future.microtask(() {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } else {
      Navigator.pop(context);
    }
  }

  // Oyunu yeniden başlat
  void _restartGame() {
    if (mounted) {
      _gameProvider.startGame();
    }
  }

  // Ana menüye dön
  void _goToHome() {
    // Dialog'u kapatmadan önce _dialogShowing bayrağını false yap
    setState(() {
      _dialogShowing = false;
    });
    
    // Oyun durumunu zorla sıfırla (timeLeft'i pozitif bir değere ayarla)
    _gameProvider.resetGameForHomeScreen();
    
    // setState sonrası bir frame bekle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  // Oyun sonu dialogunu göster
  void _showGameOverDialog() {
    if (mounted && !_dialogShowing) {
      setState(() {
        _dialogShowing = true;
      });
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => GameOverDialog(
          score: _gameProvider.score,
          highScore: _gameProvider.highScore,
          onRestart: () {
            // Dialog'u kapat
            Navigator.of(dialogContext).pop();
            
            if (mounted) {
              setState(() {
                _dialogShowing = false;
              });
              _restartGame();
            }
          },
          onHome: () {
            // Dialog'u kapat
            Navigator.of(dialogContext).pop();
            
            if (mounted) {
              // Ana menüye dön fonksiyonunu çağır
              _goToHome();
            }
          },
        ),
      );
    }
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 400 || size.height < 600;
    
    // Mevcut mod için tema rengi
    final Color currentModeColor = _modeColors[gameProvider.currentGameMode] ?? Colors.brown.shade800;
    final Color currentOverlayColor = _modeOverlayColors[gameProvider.currentGameMode] ?? Colors.brown.withOpacity(0.15);
    
    // Oyun bittiğinde dialog'u göster - daha güvenli kontrol
    if (!gameProvider.isGameActive && gameProvider.timeLeft <= 0 && !_dialogShowing) {
      // Bir sonraki frame'de sadece bir kez çalıştır
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameOverDialog();
      });
    }
    
    // Hayatta kalma modu için canları tükendiğinde dialog'u göster
    if (gameProvider.currentGameMode == GameMode.survival && 
        !gameProvider.isGameActive && gameProvider.lives <= 0 && !_dialogShowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameOverDialog();
      });
    }
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _safeNavigateBack();
        }
      },
      child: Scaffold(
        body: Transform.translate(
          offset: _shakeOffset,
          child: Stack(
            children: [
              // Ana oyun ekranı
              Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.cover,
                  ),
                  // Mod rengine göre arka plan renk katmanı eklenir
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      currentOverlayColor.withOpacity(0.2),
                      currentOverlayColor.withOpacity(0.4),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Mod Bilgi Bandı (Yeni)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: 30,
                        width: double.infinity,
                        color: currentModeColor,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getGameModeIcon(gameProvider.currentGameMode),
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getGameModeSubtitle(gameProvider.currentGameMode),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Üst bilgi paneli
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                        height: size.height * 0.1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Geri butonu
                            IconButton(
                              onPressed: _safeNavigateBack,
                              icon: Icon(Icons.arrow_back, size: isSmallScreen ? 24 : 30),
                              color: currentModeColor,
                            ),
                            
                            // Oyun modu başlığı
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0, 
                                vertical: 6.0
                              ),
                              decoration: BoxDecoration(
                                color: currentModeColor.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(50),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                _getGameModeTitle(gameProvider.currentGameMode),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 14 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            
                            // Zaman veya Can Göstergesi (oyun moduna göre)
                            _buildGameStatusIndicator(gameProvider, isSmallScreen, size),
                            
                            // Skor
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 12 : 20, 
                                vertical: isSmallScreen ? 6 : 10
                              ),
                              decoration: BoxDecoration(
                                color: Colors.brown.shade700,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(77),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/star.png',
                                    width: isSmallScreen ? 18 : 24,
                                    height: isSmallScreen ? 18 : 24,
                                  ),
                                  SizedBox(width: isSmallScreen ? 4 : 8),
                                  Text(
                                    '${gameProvider.score}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isSmallScreen ? 16 : 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Skor göstergesi
                      Text(
                        'Skor: ${gameProvider.score}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 24 : 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      
                      // Combo göstergesi
                      if (gameProvider.currentCombo > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: Colors.white,
                                size: isSmallScreen ? 20 : 24,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${gameProvider.currentCombo}x',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 18 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ).animate()
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.0, 1.0),
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutBack,
                          ),
                      
                      // Güçlendirme göstergesi
                      if (gameProvider.hasPowerUp)
                        PowerUpWidget(
                          powerUpName: _getPowerUpName(gameProvider.activePowerUp!),
                          description: _getPowerUpDescription(gameProvider.activePowerUp!),
                          icon: _getPowerUpIcon(gameProvider.activePowerUp!),
                          color: _getPowerUpColor(gameProvider.activePowerUp!),
                          durationInSeconds: gameProvider.powerUpDuration,
                        ),
                      
                      // Oyun alanı (çimen dokusu ile)
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1.0, // Kare oyun alanı
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              vertical: size.height * 0.02, 
                              horizontal: size.width * 0.03
                            ),
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage('assets/images/grass.png'),
                                fit: BoxFit.cover,
                                repeat: ImageRepeat.repeat,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(77),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              // Mod rengine göre kenarlık
                              border: Border.all(
                                color: currentModeColor,
                                width: 4.0,
                              ),
                            ),
                            child: Center(
                              // Mod animasyonu katmanı
                              child: Stack(
                                children: [
                                  // Köstebekler ve delikler
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.all(constraints.maxWidth * 0.03),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          childAspectRatio: 1.0,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                        ),
                                        itemCount: 9, // 3x3 grid
                                        itemBuilder: (context, index) {                                        return MoleHole(
                                            index: index,
                                            isVisible: gameProvider.moleVisible[index],
                                            isHit: gameProvider.moleHit[index],
                                            moleType: gameProvider.moleTypes[index], // Köstebek türü
                                            onTap: () {
                                              // Köstebeğe vur
                                              gameProvider.hitMole(index);
                                            },
                                            // Güçlendirme sistemi desteği
                                            isPowerUp: gameProvider.pendingPowerUpIndex == index,
                                            powerUpType: gameProvider.pendingPowerUpIndex == index ? 
                                                        gameProvider.pendingPowerUpType : null,
                                          );
                                        },
                                      );
                                    }
                                  ),
                                  
                                  // Mod gösterge ikonu (yeni)
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Image.asset(
                                      _modeDecorationIcons[gameProvider.currentGameMode] ?? 'assets/images/hammer.png',
                                      width: 40,
                                      height: 40,
                                      opacity: const AlwaysStoppedAnimation<double>(0.5),
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          _getGameModeIcon(gameProvider.currentGameMode),
                                          size: 40,
                                          color: currentModeColor.withOpacity(0.5),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Alt bilgi
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.02,
                          horizontal: size.width * 0.04
                        ),
                        decoration: BoxDecoration(
                          color: currentModeColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Zorluk: ${gameProvider.difficulty == 'easy' ? 'Kolay' : gameProvider.difficulty == 'normal' ? 'Normal' : 'Zor'}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 14 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 4 : 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getGameModeIcon(gameProvider.currentGameMode),
                                  color: Colors.white,
                                  size: isSmallScreen ? 16 : 20,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  _getGameModeDescription(gameProvider.currentGameMode),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 12 : 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                // Mesaj overlay'i
              GameMessagesOverlay(),
            ],
          ),
        ),
      ),
    );
  }
  
  // Oyun moduna göre durum göstergesini oluşturur (zaman veya can)
  Widget _buildGameStatusIndicator(GameProvider gameProvider, bool isSmallScreen, Size size) {
    // Hayatta kalma modu için can göstergesi
    if (gameProvider.currentGameMode == GameMode.survival) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 20, 
          vertical: isSmallScreen ? 6 : 10
        ),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(77),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.favorite,
              color: Colors.white,
              size: isSmallScreen ? 18 : 24,
            ),
            SizedBox(width: isSmallScreen ? 4 : 8),
            Text(
              '${gameProvider.lives}',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 16 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    
    // Diğer modlar için zaman göstergesi
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 20, 
        vertical: isSmallScreen ? 6 : 10
      ),
      decoration: BoxDecoration(
        color: Colors.brown.shade700,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(77),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/icon_time.png',
            width: isSmallScreen ? 18 : 24,
            height: isSmallScreen ? 18 : 24,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.timer, color: Colors.white, size: isSmallScreen ? 18 : 24);
            },
          ),
          SizedBox(width: isSmallScreen ? 4 : 8),
          Text(
            '${gameProvider.timeLeft}',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 16 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate(
      target: gameProvider.timeLeft <= 10 ? 1 : 0,
    ).shake(
      duration: 300.ms,
      hz: 3,
    );
  }
    // Oyun modu başlığını döndür
  String _getGameModeTitle(GameMode mode) {
    switch (mode) {
      case GameMode.classic:
        return 'Klasik Mod';
      case GameMode.timeAttack:
        return 'Zaman Yarışı';
      case GameMode.survival:
        return 'Hayatta Kalma';
      case GameMode.special:
        return 'Özel Mod';
    }
  }
    // Oyun modu alt başlığını döndür
  String _getGameModeSubtitle(GameMode mode) {
    switch (mode) {
      case GameMode.classic:
        return '60 Saniye, Klasik Oyun';
      case GameMode.timeAttack:
        return 'Her Vuruş Zaman Ekler';
      case GameMode.survival:
        return '3 Can, Süre Yok';
      case GameMode.special:
        return 'Sürpriz Bonus Köstebekler';
    }
  }
    // Oyun modu açıklamasını döndür
  String _getGameModeDescription(GameMode mode) {
    switch (mode) {
      case GameMode.classic:
        return 'Süre dolmadan en yüksek puanı topla!';
      case GameMode.timeAttack:
        return 'Her köstebek +2 saniye ekler, kaçırma!';
      case GameMode.survival:
        return 'Kaçırdığın her köstebek bir can alır!';
      case GameMode.special:
        return 'Altın köstebekler ekstra puan kazandırır!';
    }
  }
    // Oyun modu ikonunu döndür
  IconData _getGameModeIcon(GameMode mode) {
    switch (mode) {
      case GameMode.classic:
        return Icons.slow_motion_video;
      case GameMode.timeAttack:
        return Icons.timer;
      case GameMode.survival:
        return Icons.favorite;
      case GameMode.special:
        return Icons.auto_awesome;
    }
  }
    // Güçlendirme ismini döndür
  String _getPowerUpName(PowerUpType powerUp) {
    switch (powerUp) {
      case PowerUpType.hammer:
        return 'Çifte Puan';
      case PowerUpType.timeFreezer:
        return 'Zaman Dondurma';
      case PowerUpType.moleReveal:
        return 'Köstebek Gösterici';
    }
  }
    // Güçlendirme açıklamasını döndür
  String _getPowerUpDescription(PowerUpType powerUp) {
    switch (powerUp) {
      case PowerUpType.hammer:
        return 'Bir sonraki vuruş 2x puan kazandırır!';
      case PowerUpType.timeFreezer:
        return 'Süre geçici olarak donduruldu!';
      case PowerUpType.moleReveal:
        return 'Tüm köstebekler kısa süre görünür!';
    }
  }
    // Güçlendirme ikonunu döndür
  IconData _getPowerUpIcon(PowerUpType powerUp) {
    switch (powerUp) {
      case PowerUpType.hammer:
        return Icons.gavel;
      case PowerUpType.timeFreezer:
        return Icons.hourglass_disabled;
      case PowerUpType.moleReveal:
        return Icons.visibility;
    }
  }
  // Güçlendirme rengini döndür
  Color _getPowerUpColor(PowerUpType powerUp) {
    switch (powerUp) {
      case PowerUpType.hammer:
        return Colors.amber.shade700;
      case PowerUpType.timeFreezer:
        return Colors.cyan.shade700;
      case PowerUpType.moleReveal:
        return Colors.green.shade700;
    }
  }
}