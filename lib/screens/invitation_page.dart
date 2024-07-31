import 'package:flutter/material.dart';
import 'package:yumpro/utils/custom_widgets.dart';

class InvitationPage extends StatefulWidget {
  final String invitationId;

  const InvitationPage({super.key, required this.invitationId});

  @override
  _InvitationPageState createState() => _InvitationPageState();
}

class _InvitationPageState extends State<InvitationPage> {
  final TextEditingController _codeController = TextEditingController();
  String? _errorMessage;

  void _validateCode() {
    final code = _codeController.text;
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Le code de l\'invitation ne peut pas être vide.';
      });
      return;
    }

    // Logique pour valider le code de l'invitation
    // Par exemple, vérifier le code contre un service ou une liste
    if (code == 'expected_code') {
      // Remplacez 'expected_code' par votre logique de validation
      // Code valide, naviguer vers la page suivante ou afficher un message de succès
      setState(() {
        _errorMessage = null;
      });
      // Naviguer ou effectuer une autre action
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code d\'invitation valide!')),
      );
    } else {
      setState(() {
        _errorMessage = 'Code de l\'invitation invalide.';
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Entrez le code de votre invitation'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 250, // Limiter la largeur à 600 pixels
                ),
                child: TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Code de l\'invitation',
                    errorText: _errorMessage,
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
            ),
            SizedBox(
              width: 250,
              child: CustomWidgets.primaryButton(
                  text: "Valider", onPressed: _validateCode),
            ),
          ],
        ),
      ),
    );
  }
}
