import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatelessWidget {
  final String? loadingText;
  const SplashScreen({Key? key, this.loadingText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.brown.shade800,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Oyun logosu
            Image.asset(
              'assets/images/logo.png',
              width: size.width * 0.45,
              height: size.width * 0.45,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            // Yükleniyor animasyonu
            const SpinKitFadingCircle(
              color: Colors.white,
              size: 48.0,
            ),
            const SizedBox(height: 24),
            Text(
              loadingText ?? 'Yükleniyor... Lütfen bekleyin',
              style: const TextStyle(
                fontFamily: 'LuckiestGuy',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
