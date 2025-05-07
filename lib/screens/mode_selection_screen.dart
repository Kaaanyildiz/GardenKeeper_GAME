/*
 * Copyright © 2025 Mehmet Kaan YILDIZ
 * Garden Keeper - Köstebek vurma oyunu
 * Tüm hakları saklıdır.
 * 
 * Bu yazılım, MIT Lisansı altında lisanslanmıştır.
 * Lisans bilgisi için LICENSE dosyasını inceleyiniz.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/game_provider.dart';
import 'game_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400 || size.height < 600;
    
    return Scaffold(
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
              // Üst Panel - Başlık ve Geri Butonu
              Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back, size: isSmallScreen ? 24 : 30),
                      color: Colors.brown.shade800,
                    ),
                    const Spacer(),
                    Text(
                      'OYUN MODLARI',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade800,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(width: isSmallScreen ? 30 : 48), // Dengelemek için boş alan
                  ],
                ),
              ),
              
              // Mod Açıklaması
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  'İstediğin oyun modunu seçerek bahçende köstebekleri vur! Her mod farklı bir oynanış sunuyor.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 15 : 18,
                    color: Colors.brown.shade700,
                  ),
                ),
              ),
              
              // Oyun Modları Listesi - Daha az yükseklik kullanmak için padding değerleri azaltıldı
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  children: [
                    // Klasik Mod
                    _buildModeCard(
                      context: context,
                      isSmallScreen: isSmallScreen,
                      title: 'Klasik Mod',
                      description: 'Klasik köstebek vurma deneyimi. 60 saniye içinde mümkün olduğunca çok köstebek vur!',
                      icon: Icons.watch_later_outlined,
                      color: Colors.blue.shade700,
                      gameMode: GameMode.classic,
                    ),
                    
                    // Hayatta Kalma Modu
                    _buildModeCard(
                      context: context,
                      isSmallScreen: isSmallScreen,
                      title: 'Hayatta Kalma',
                      description: 'Zorlaştıkça zorlaşan sonsuz bir mod. 3 köstebek kaçırırsan oyun biter!',
                      icon: Icons.favorite,
                      color: Colors.red.shade700,
                      gameMode: GameMode.survival,
                    ),
                    
                    // Zamana Karşı Modu
                    _buildModeCard(
                      context: context,
                      isSmallScreen: isSmallScreen,
                      title: 'Zamana Karşı',
                      description: 'Her vuruşta biraz daha süre kazan. Ne kadar uzun süre hayatta kalabilirsin?',
                      icon: Icons.timer,
                      color: Colors.amber.shade700,
                      gameMode: GameMode.timeAttack,
                    ),
                    
                    // Özel Köstebekler Modu
                    _buildModeCard(
                      context: context,
                      isSmallScreen: isSmallScreen,
                      title: 'Özel Köstebekler',
                      description: 'Altın, hızlı ve dayanıklı köstebekler! Her biri farklı puanlar ve zorluklar sunuyor.',
                      icon: Icons.auto_awesome,
                      color: Colors.purple.shade700,
                      gameMode: GameMode.special,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildModeCard({
    required BuildContext context,
    required bool isSmallScreen,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required GameMode gameMode,
  }) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    
    // Kart yüksekliği daha kompakt hale getirildi
    final cardHeight = isSmallScreen ? 120.0 : 140.0;
    
    return Container(
      height: cardHeight,
      margin: const EdgeInsets.only(bottom: 12), // 16'dan 12'ye düşürüldü
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16), // 20'den 16'ya düşürüldü
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 6, // 8'den 6'ya düşürüldü
            spreadRadius: 1, // 2'den 1'e düşürüldü
            offset: const Offset(0, 3), // 4'ten 3'e düşürüldü
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Oyun modunu ayarla ve oyun ekranına git
            gameProvider.setGameMode(gameMode);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GameScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16), // 20'den 16'ya düşürüldü
          splashColor: Colors.white.withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(12), // 16'dan 12'ye düşürüldü
            child: Row(
              children: [
                // Mod İkonu - daha küçük
                Container(
                  width: cardHeight * 0.45, // 0.5'ten 0.45'e düşürüldü
                  height: cardHeight * 0.45, // 0.5'ten 0.45'e düşürüldü
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1, // 2'den 1'e düşürüldü
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isSmallScreen ? 24 : 30, // 28/36'dan 24/30'a düşürüldü
                  ),
                ),
                
                const SizedBox(width: 12), // 16'dan 12'ye düşürüldü
                
                // Mod Bilgileri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 16 : 20, // 18/22'den 16/20'ye düşürüldü
                        ),
                      ),
                      const SizedBox(height: 6), // 8'den 6'ya düşürüldü
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isSmallScreen ? 11 : 13, // 12/14'ten 11/13'e düşürüldü
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Oynat Butonu
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.5),
                  size: isSmallScreen ? 18 : 22, // 20/24'ten 18/22'ye düşürüldü
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}