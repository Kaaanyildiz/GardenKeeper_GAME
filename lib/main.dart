/*
 * Copyright © 2025 Mehmet Kaan YILDIZ
 * Garden Keeper - Köstebek vurma oyunu
 * Tüm hakları saklıdır.
 * 
 * Bu yazılım, MIT Lisansı altında lisanslanmıştır.
 * Lisans bilgisi için LICENSE dosyasını inceleyiniz.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/achievements_screen.dart'; // Yeni eklendi
import 'screens/mode_selection_screen.dart'; // Yeni eklendi
import 'screens/profile_screen.dart'; // Yeni eklendi
import 'providers/game/game_provider.dart';
import 'widgets/splash_screen.dart';
import 'utils/audio_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ekranın sadece dikey modda çalışmasını sağlayalım
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Tam ekran modu
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garden Keeper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
          primary: Colors.brown.shade700,
          secondary: Colors.green.shade700,
        ),
        useMaterial3: true,
        fontFamily: 'LuckiestGuy',
      ),
      // SplashScreen ve preload logic ile başlat
      home: const AppEntry(),
      routes: {
        '/game': (context) => const GameScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/achievements': (context) => const AchievementsScreen(),
        '/mode_selection': (context) => const ModeSelectionScreen(),
        '/profile': (context) => const ProfileScreen(), // Profil ekranı rotası
      },
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> with WidgetsBindingObserver {
  bool _isReady = false;
  String? _error;
  bool _didPreload = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      AudioManager().pauseBackgroundMusic();
    } else if (state == AppLifecycleState.resumed) {
      AudioManager().resumeBackgroundMusic();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didPreload) {
      _didPreload = true;
      _preloadAssetsAndAudio();
    }
  }

  Future<void> _preloadAssetsAndAudio() async {
    try {
      // Logo ve diğer önemli asset'leri önceden yükle
      await precacheImage(const AssetImage('assets/images/logo.png'), context);
      // Sesleri ve müziği başlatmadan önce preload
      await AudioManager().initialize();
      // Gerekirse başka asset'ler de eklenebilir
      setState(() {
        _isReady = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Yükleme sırasında hata oluştu: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.brown.shade800,
        body: Center(
          child: Text(_error!, style: const TextStyle(color: Colors.white, fontSize: 18)),
        ),
      );
    }
    if (!_isReady) {
      return const SplashScreen();
    }
    // Yükleme tamamlandıktan sonra HomeScreen'e yönlendir
    return const HomeScreen();
  }
}
