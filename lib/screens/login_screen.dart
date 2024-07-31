import 'package:flutter/material.dart';
import 'package:yumpro/services/api_service.dart';
import 'package:yumpro/services/auth_service.dart'; // Importer AuthService
import 'package:yumpro/utils/custom_widgets.dart';

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

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      final response = await _apiService.login(email, password);

      // Save token
      await _authService.saveToken(response);

      // Get user information after successful login
      final userData = await _apiService.getUser(response);

      // Save user information in SharedPreferences
      await _authService.saveUserInfo(userData);

      // Vérification du champ workspace_id et redirection appropriée
      if (userData.containsKey('workspace_id') &&
          userData['workspace_id'] != null &&
          userData['workspace_id'] != 0) {
        // Rediriger vers "/"
        Navigator.pushReplacementNamed(context, '/');
      } else {
        // Rediriger vers "/onboarding"
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    } catch (error) {
      // Handle login error
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
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 40),
            const SizedBox(width: 10),
            const Text('Yummap Pro'),
          ],
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
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
                  labelText: 'Mot de passe',
                ),
              ),
              const SizedBox(height: 50.0),
              Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: CustomWidgets.primaryButton(
                        text: "Login", onPressed: _login)),
              ),
              const SizedBox(height: 20.0),
              CustomWidgets.textButton(
                  onPressed: () {
                    // Naviguer vers la route de l'écran d'enregistrement
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  text: "Si vous n'avez pas encore de compte, cliquez ici"),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
