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
import '../utils/game_provider.dart';
import '../widgets/mole_hole.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/power_up_widget.dart'; // Yeni güçlendirme widget'ı

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // GameProvider referansını sınıf düzeyinde saklayalım
  late GameProvider _gameProvider;
  bool _dialogShowing = false;
  
  @override
  void initState() {
    super.initState();
    // Provider referansını başlangıçta al ve sakla
    _gameProvider = Provider.of<GameProvider>(context, listen: false);
    
    // Oyunu otomatik olarak başlat
    Future.delayed(Duration.zero, () {
      if (mounted) {
        _gameProvider.startGame();
      }
    });
  }

  @override
  void dispose() {
    // Saklanan referansı kullan, context üzerinden erişme
    // Oyunu güvenli bir şekilde bitirmek için Future.microtask kullanıyoruz
    if (_gameProvider.isGameActive) {
      Future.microtask(() {
        _gameProvider.endGame();
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 400 || size.height < 600;
    
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
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
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
                        color: Colors.brown.shade800,
                      ),
                      
                      // Oyun modu başlığı (yeni)
                      Text(
                        _getGameModeTitle(gameProvider.currentGameMode),
                        style: TextStyle(
                          color: Colors.brown.shade900,
                          fontSize: isSmallScreen ? 14 : 18,
                          fontWeight: FontWeight.bold,
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
                
                // Güçlendirme göstergesi (yeni)
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
                      ),
                      child: Center(
                        // Köstebekler ve delikler
                        child: LayoutBuilder(
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
                              itemBuilder: (context, index) {
                                return MoleHole(
                                  index: index,
                                  isVisible: gameProvider.moleVisible[index],
                                  isHit: gameProvider.moleHit[index],
                                  moleType: gameProvider.moleTypes[index], // Yeni köstebek türü parametresi
                                  onTap: () => gameProvider.hitMole(index),
                                );
                              },
                            );
                          }
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
                    color: Colors.brown.shade700,
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
        return 'KLASİK MOD';
      case GameMode.timeAttack:
        return 'ZAMANA KARŞI';
      case GameMode.survival:
        return 'HAYATTA KALMA';
      case GameMode.special:
        return 'ÖZEL KÖSTEBEKLER';
    }
  }
  
  // Oyun modu açıklamasını döndür
  String _getGameModeDescription(GameMode mode) {
    switch (mode) {
      case GameMode.classic:
        return 'En Yüksek Skor: ${_gameProvider.highScore}';
      case GameMode.timeAttack:
        return 'Her vuruş +2 saniye';
      case GameMode.survival:
        return 'Köstebekleri kaçırma!';
      case GameMode.special:
        return 'Özel köstebekler daha çok puan!';
    }
  }
  
  // Oyun modu ikonunu döndür
  IconData _getGameModeIcon(GameMode mode) {
    switch (mode) {
      case GameMode.classic:
        return Icons.timer;
      case GameMode.timeAttack:
        return Icons.hourglass_top;
      case GameMode.survival:
        return Icons.favorite;
      case GameMode.special:
        return Icons.star;
    }
  }

  // Güçlendirme adı döndürme
  String _getPowerUpName(PowerUpType type) {
    switch (type) {
      case PowerUpType.hammer:
        return 'Çekiç Güçlendirmesi';
      case PowerUpType.timeFreezer:
        return 'Zaman Dondurma';
      case PowerUpType.moleReveal:
        return 'Köstebekleri Göster';
    }
  }

  // Güçlendirme açıklaması döndürme
  String _getPowerUpDescription(PowerUpType type) {
    switch (type) {
      case PowerUpType.hammer:
        return 'Sonraki vuruşta ekstra puan!';
      case PowerUpType.timeFreezer:
        return 'Zamanı kısa süreliğine durdur!';
      case PowerUpType.moleReveal:
        return 'Tüm köstebekleri kısa süre göster!';
    }
  }

  // Güçlendirme ikonunu döndürme
  IconData _getPowerUpIcon(PowerUpType type) {
    switch (type) {
      case PowerUpType.hammer:
        return Icons.hardware;
      case PowerUpType.timeFreezer:
        return Icons.access_time_filled;
      case PowerUpType.moleReveal:
        return Icons.visibility;
    }
  }

  // Güçlendirme rengini döndürme
  Color _getPowerUpColor(PowerUpType type) {
    switch (type) {
      case PowerUpType.hammer:
        return Colors.brown.shade700;
      case PowerUpType.timeFreezer:
        return Colors.blue.shade600;
      case PowerUpType.moleReveal:
        return Colors.green.shade600;
    }
  }
}