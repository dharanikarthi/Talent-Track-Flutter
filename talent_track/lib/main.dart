import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/onboarding/onboarding_flow.dart';

void main() {
  runApp(const ProviderScope(child: TalentTrackApp()));
}

class TalentTrackApp extends StatelessWidget {
  const TalentTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final light = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF6C5CE7),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Color(0xFFF8F9FB),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
    );

    return MaterialApp(
      title: 'TalentTrack',
      theme: light,
      debugShowCheckedModeBanner: false,
      home: const OnboardingFlow(),
    );
  }
}
