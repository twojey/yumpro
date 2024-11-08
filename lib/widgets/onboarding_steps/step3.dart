import 'package:flutter/material.dart';
import 'package:yumpro/services/auth_service.dart';

class Step3Hotel extends StatefulWidget {
  final bool isHotelAccount;
  final Function(Map<String, dynamic>) onCompletion;

  const Step3Hotel(
      {super.key, required this.isHotelAccount, required this.onCompletion});

  @override
  _Step3HotelState createState() => _Step3HotelState();
}

class _Step3HotelState extends State<Step3Hotel> {
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  bool _isSubmitting = false; // Variable pour gérer l'état du bouton

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Désactiver le bouton avant de lancer la requête
    setState(() {
      _isSubmitting = true;
    });
    _isSubmitting = true;

    try {
      // Récupérer les informations de l'utilisateur existant
      final userData = await AuthService().getUserInfo();

      // Mettre à jour les informations de l'utilisateur
      userData['name'] = _lastNameController.text;
      userData['first_name'] = _firstNameController.text;
      userData['anonymous_com'] = false;
      userData['user_id'] = userData['user_id'] as int;
      userData['id'] = userData['user_id'] as int;
      String wId = userData['workspace_place_id'];
      userData['photo_url'] =
          "https://yummaptest2.s3.eu-north-1.amazonaws.com/$wId/profile.jpg";

      // Sauvegarder les données mises à jour
      await AuthService().saveUserInfo(userData);

      // Appelle la fonction onCompletion avec les données mises à jour
      widget.onCompletion(userData);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la soumission : $error')),
      );
    } finally {
      // Attendre 2 secondes avant de réactiver le bouton
      await Future.delayed(const Duration(seconds: 3));

      // Réactiver le bouton lorsque la requête est terminée ou si une erreur survient
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isHotelAccount) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Étape 3 : Informations personnelles'),
        const SizedBox(height: 20),
        TextFormField(
          controller: _lastNameController,
          decoration: const InputDecoration(labelText: 'Nom de famille'),
        ),
        TextFormField(
          controller: _firstNameController,
          decoration: const InputDecoration(labelText: 'Prénom'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : _submitForm, // Désactiver le bouton si en soumission
          child: _isSubmitting
              ? const Text('En cours...') // Indicateur visuel
              : const Text('Terminer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isSubmitting
                ? Colors.grey
                : null, // Couleur pour l'état désactivé
          ),
        ),
      ],
    );
  }
}
