import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:yumpro/models/user.dart';
import 'package:yumpro/screens/login_screen.dart'; // Assurez-vous d'avoir cet import

class SettingsScreen extends StatefulWidget {
  final User user;

  const SettingsScreen({super.key, required this.user});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late User _user;
  Uint8List? _imageBytes;
  bool _anonymousComments = false;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _firstNameController.text = _user.firstName;
    _lastNameController.text = _user.lastName;
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          setState(() {
            _imageBytes = file.bytes;
            // Mettre à jour l'utilisateur avec un chemin fictif ou un URL de l'image par défaut
            _user = _user.copyWith(
                photoUrl:
                    'path/to/default/image'); // Mettez ici le lien vers une image par défaut ou gérez comme vous le souhaitez.
          });
        }
      }
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  void _saveSettings() {
    setState(() {
      _user = _user.copyWith(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
      );
      // Sauvegarder d'autres paramètres ici si nécessaire
    });
    // Ajouter des actions de sauvegarde ici (par exemple, envoyer les données au serveur)
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Commentaires Anonymes:',
                  style: TextStyle(fontSize: 18),
                ),
                Switch(
                  value: _anonymousComments,
                  onChanged: (value) {
                    setState(() {
                      _anonymousComments = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Changer sa photo:',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _imageBytes != null
                        ? MemoryImage(_imageBytes!)
                        : NetworkImage(_user.photoUrl) as ImageProvider,
                    child: Icon(Icons.camera_alt,
                        size: 40, color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Changer son nom:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nom',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Changer son prénom:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Prénom',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Voir son rôle dans le workspace:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Rôle: ${_user.roleInWorkspace}',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(), // Ajoute un espace flexible pour pousser le bouton en bas
            ElevatedButton(
              onPressed: () {
                // Redirection vers l'écran de connexion
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
              ),
              child: const Text(
                'Se déconnecter',
                style: TextStyle(color: Colors.white), // Texte en blanc
              ),
            ),
          ],
        ),
      ),
    );
  }
}
