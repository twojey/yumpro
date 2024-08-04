import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:yumpro/utils/custom_widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _sendPasswordResetEmail(BuildContext context) async {
    final String email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer votre email')),
      );
      return;
    }

    // Vérification de l'adresse email dans la base de données
    final bool emailExists = await _checkIfEmailExists(email);
    if (!emailExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cet email n\'existe pas dans notre base de données')),
      );
      return;
    }

    // Envoi de l'email de réinitialisation de mot de passe
    try {
      final response = await _sendEmail(email);
      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email envoyé')),
        );
      } else {
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi de l\'email: $error')),
      );
    }
  }

  Future<bool> _checkIfEmailExists(String email) async {
    final url = Uri.parse('https://x8ki-letl-twmt.n7.xano.io/api:LYxWamUX/user/email/$email');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return true; // Assuming the response contains a field 'exists' indicating the existence of the email
    } else {
      return false;
    }
  }

  Future<http.Response> _sendEmail(String email) {
    final apiKey = dotenv.env['BREVO_API_KEY'];
    if (apiKey == null) {
      throw Exception('API key is not set in the environment variables');
    }

    final url = Uri.parse('https://api.brevo.com/v3/smtp/email');
    final headers = {
      'Content-Type': 'application/json',
      'api-key': apiKey,
    };
    final body = json.encode({
      'sender': {'name': 'Yummap', 'email': 'yummap.app@gmail.com'},
      'to': [{'email': email}],
      'subject': 'Réinitialisation de mot de passe',
      //IL FAUT METTRE L4URL DANS LE MAIL EN DYNAMIQUE
      'htmlContent': '<html><body><h1>Réinitialisation de mot de passe</h1><p>Pour réinitialiser votre mot de passe, cliquez sur le lien ci-dessous:</p><a href="https://yummap-pro.web.app/reset_password?email=$email">Réinitialiser le mot de passe</a></body></html>',
    });
    return http.post(url, headers: headers, body: body);
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 20.0),
              CustomWidgets.primaryButton(
                text: "Envoyer",
                onPressed: () => _sendPasswordResetEmail(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
