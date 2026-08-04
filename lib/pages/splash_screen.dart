import 'package:flutter/material.dart';
import '../main.dart';
import '../data/app_data.dart';
import '../l10n/strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final data = AppData.instance;
      if (!data.loggedIn) {
        Navigator.pushReplacementNamed(context, '/login');
      } else if (!data.hasChild) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        Navigator.pushReplacementNamed(context, '/main');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3F0D1F), kTeal, kTeal2],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
              ),
              const SizedBox(height: 16),
              Text(tr('app_name'), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1)),
              const SizedBox(height: 4),
              Text(tr('app_tagline'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.7))),
              const SizedBox(height: 18),
              const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
              )
            ],
          ),
        ),
      ),
    );
  }
}
