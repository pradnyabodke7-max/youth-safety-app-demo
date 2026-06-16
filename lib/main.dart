
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:youth_safety_app/screens/splash_screen.dart';
import 'package:youth_safety_app/screens/login_screen.dart';
import 'package:youth_safety_app/screens/signup_screen.dart';
import 'package:youth_safety_app/screens/home_screen.dart';
import 'package:youth_safety_app/screens/contacts_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App Name
      title: 'Youth Safety',

      // Hide the debug banner on top right
      debugShowCheckedModeBanner: false,

      // App Colors
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935),
        ),
        useMaterial3: true,
      ),

      // Routes
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/contacts': (context) => const ContactsScreen(),
      },
    );
  }
}