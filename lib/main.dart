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
      title: 'Yumpro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Définir la route initiale
      routes: {
        '/': (context) => FutureBuilder<Map<String, dynamic>>(
              future: _checkUserStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else {
                  if (snapshot.hasData) {
                    final userData = snapshot.data!;
                    final String? token = userData['token'];
                    final String? name = userData['name'];

                    if (token != null) {
                      if (name != "") {
                        return const HomeScreen();
                      } else {
                        return const OnboardingScreen();
                      }
                    } else {
                      return const LoginScreen();
                    }
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

  Future<Map<String, dynamic>> _checkUserStatus() async {
    final token = await _authService.getToken();
    final userInfo = await _authService.getUserInfo();
    userInfo['token'] = token;
    return userInfo;
  }
}
