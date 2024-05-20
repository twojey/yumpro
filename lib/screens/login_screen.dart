import 'package:flutter/material.dart';
import 'package:yumpro/screens/register_screen.dart';
import 'package:yumpro/widgets/custom_text_button.dart';
import 'package:yumpro/services/api_service.dart';
import 'package:yumpro/services/auth_service.dart'; // Importer AuthService

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService(); // Instancier AuthService

  Future<void> _login() async {
    final String email = _emailController.text.trim().toLowerCase();
    final String password = _passwordController.text.trim();

    try {
      final response = await _apiService.login(email, password);

      // Sauvegarder le token après la connexion réussie
      await _authService.saveToken(
          response); // Utiliser AuthService pour sauvegarder le token

      // Si la connexion réussit, rediriger vers la page d'onboarding
      Navigator.pushReplacementNamed(context, '/onboarding');
    } catch (error) {
      // Afficher une erreur si la connexion échoue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $error')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 16),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
              ),
              child: const Text('Login'),
            ),
            const SizedBox(height: 20.0),
            CustomTextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
              text: 'Register',
              textStyle: const TextStyle(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
