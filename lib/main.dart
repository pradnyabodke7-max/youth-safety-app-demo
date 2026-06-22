import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/contacts_screen.dart';
import 'screens/journey_timer_screen.dart';
import 'package:youth_safety_app/providers/profile_provider.dart';
import 'package:youth_safety_app/screens/profile_screen.dart';
import 'package:youth_safety_app/providers/contact_provider.dart';
import 'package:youth_safety_app/providers/sos_provider.dart';
import 'package:youth_safety_app/screens/sos_history_screen.dart';
import 'package:youth_safety_app/providers/journey_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const YouthSafetyApp());
}

class YouthSafetyApp extends StatelessWidget {
  const YouthSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ContactProvider()),
        ChangeNotifierProvider(create: (_) => SosProvider()),
        ChangeNotifierProvider(create: (_) => JourneyProvider()),
      ],
      child: MaterialApp(
        title: 'Youth Safety',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFFE53935),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/contacts': (context) => const ContactsScreen(),
          '/sos-history': (context) => const SosHistoryScreen(),
          '/journey': (context) => const JourneyTimerScreen(),
        },
      ),
    );
  }
}