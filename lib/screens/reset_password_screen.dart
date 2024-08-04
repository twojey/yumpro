import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  ResetPasswordScreen({required this.email});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Variables d'état pour la visibilité des mots de passe
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email); // Préremplir le champ email
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final url = 'https://x8ki-letl-twmt.n7.xano.io/api:LYxWamUX/user/password/$email';

      final response = await http.patch(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'user_email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Password updated successfully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mot de passe réinitialisé avec succès')),
        );
      } else {
        // Error occurred
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la réinitialisation du mot de passe')),
        );
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez entrer un email valide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réinitialiser le mot de passe'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  readOnly: true,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    suffixIcon: GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          _isPasswordVisible = true;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          _isPasswordVisible = false;
                        });
                      },
                      child: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmez le mot de passe',
                    suffixIcon: GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          _isConfirmPasswordVisible = true;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          _isConfirmPasswordVisible = false;
                        });
                      },
                      child: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  obscureText: !_isConfirmPasswordVisible,
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _resetPassword,
                  child: const Text('Réinitialiser le mot de passe'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
