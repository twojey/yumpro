import 'package:flutter/material.dart';
import 'package:yumpro/screens/login_screen.dart';
import 'package:yumpro/screens/onboarding_screen.dart';
import 'package:yumpro/services/api_service.dart';
import 'package:yumpro/services/auth_service.dart';
import 'package:yumpro/services/mixpanel_service.dart';
import 'package:yumpro/utils/custom_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  bool _isLoading =
      false; // Ajout de la variable d'état pour suivre le chargement

  void _register() async {
    final String email = _emailController.text.trim().toLowerCase();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Désactive le bouton au début de la requête
    });

    try {
      final response = await _apiService.signup(email, password);

      // Si l'inscription réussit, redirige vers la page d'onboarding ou de login
      await _authService.saveToken(response);

      // Obtenir les informations utilisateur après l'inscription
      final userData = await _apiService.getUser(response);

      // Sauvegarder les informations utilisateur
      await _authService.saveUserInfo(userData);
      AnalyticsManager().trackEvent("New user");

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        ),
      );
    } catch (error) {
      // Afficher une erreur si l'inscription échoue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Réactive le bouton une fois la requête terminée
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            const Text('Yummap Pro - Enregistrement'),
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
                  labelText: 'Créez un mot de passe',
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmez le mot de passe',
                ),
              ),
              const SizedBox(height: 50.0),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: CustomWidgets.secondaryButton(
                    text: _isLoading
                        ? "Veuillez patienter..."
                        : "Créer mon compte",
                    onPressed: _isLoading ? () {} : _register,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              // TextButton pour revenir à l'écran de connexion
              CustomWidgets.textButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                text: 'Vous avez déjà un compte ? Connectez-vous',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
