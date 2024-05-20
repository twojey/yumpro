import 'package:flutter/material.dart';
import 'package:yumpro/screens/login_screen.dart';
import 'package:yumpro/screens/register_screen.dart';
import 'package:yumpro/screens/home_screen.dart';
import 'package:yumpro/screens/onboarding_screen.dart';
import 'package:yumpro/services/auth_service.dart'; // Importer AuthService

void main() {
  runApp(YumProApp());
}

class YumProApp extends StatelessWidget {
  YumProApp({super.key});
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Définir la route initiale
      routes: {
        '/': (context) => FutureBuilder<String?>(
              future: _authService.getToken(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  if (snapshot.hasData && snapshot.data != null) {
                    return const HomeScreen();
                  } else {
                    return const LoginScreen();
                  }
                }
              },
            ),
        '/login': (context) =>
            const LoginScreen(), // Ajouter la route pour l'écran de connexion
        '/register': (context) => const RegisterScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }
}
