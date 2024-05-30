import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yumpro/models/user.dart';
import 'package:yumpro/screens/login_screen.dart';
import 'package:yumpro/services/api_service.dart';
import 'package:yumpro/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? _user;
  Uint8List? _imageBytes;
  bool _anonymousComments = true;
  bool _isLoading = true; // Indicateur de chargement
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  late Map<String, dynamic> _userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    print("load...");
    final userInfo = await _authService.getUserInfo();
    _userInfo = await _authService.getUserInfo();
    _anonymousComments = _userInfo['anonymous_com'];
    print(_userInfo);
    setState(() {
      _user = User(
        firstName: userInfo['first_name'] ?? '',
        lastName: userInfo['name'] ?? '',
        photoUrl: userInfo['photo_url'] ?? '',
        workspace: '',
        roleInWorkspace: '',
        numComments: 0,
      );
      _firstNameController.text = _user!.firstName;
      _lastNameController.text = _user!.lastName;
      _isLoading = false; // Mettre à jour l'état de chargement
    });
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          setState(() {
            _imageBytes = file.bytes;
          });

          // Appeler l'API pour uploader la photo
          await _uploadProfilePhoto(file.bytes!);
        }
      }
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  Future<void> _uploadProfilePhoto(Uint8List imageData) async {
    try {
      await _apiService.uploadProfilePhoto('profile.jpg', imageData);
      Fluttertoast.showToast(
        msg: "Photo modifiée, la mise à jour peut prendre du temps",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      String wId = _userInfo['workspace_place_id'];
      String uId = _userInfo['user_id'].toString();
      _userInfo['photo_url'] =
          'https://yummaptest2.s3.eu-north-1.amazonaws.com/$wId/$uId/profile.jpg';
      _authService.saveUserInfo(_userInfo);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur lors de la mise à jour de la photo de profil: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      // _user = _user!.copyWith(
      //   firstName: _firstNameController.text,
      //   lastName: _lastNameController.text,
      // );
      _user?.setFirstName(_firstNameController.text);
      _user?.setLastName(_lastNameController.text);
      _firstNameController.text = _user!.firstName;
      _lastNameController.text = _user!.lastName;
    });

    _userInfo['first_name'] = _firstNameController.text;
    _userInfo['name'] = _lastNameController.text;
    _userInfo['anonymous_com'] = _anonymousComments;
    print("___ SAVE INFOS ____");
    print(_userInfo);

    _authService.saveUserInfo(_userInfo);

    // Récupérer les informations de l'utilisateur depuis les SharedPreferences
    final userInfo = await _authService.getUserInfo();
    final userId = userInfo['user_id'];
    final workspaceId = userInfo['workspace_id'];
    final workspacePlaceId = userInfo['workspace_place_id'];

    if (userId == null || workspaceId == null || workspacePlaceId == null) {
      Fluttertoast.showToast(
        msg: "Erreur: informations utilisateur incomplètes",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    // Appeler l'API pour mettre à jour les informations de l'utilisateur
    try {
      await _apiService.updateUserInfo(
          userId: userId,
          workspaceId: workspaceId,
          userName: _lastNameController.text,
          isAnonymous: _anonymousComments,
          userFirstName: _firstNameController.text,
          workspacePlaceId: workspacePlaceId,
          userPhotoUrl: userInfo['photo_url']);
      Fluttertoast.showToast(
        msg: "Informations mises à jour avec succès",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur lors de la mise à jour des informations: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const defaultPhotoUrl =
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            iconSize: 40,
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                              : NetworkImage(_user!.photoUrl.isNotEmpty
                                  ? _user!.photoUrl
                                  : defaultPhotoUrl) as ImageProvider,
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
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Nom',
                      hintStyle: TextStyle(color: Colors.grey[600]),
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
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Prénom',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Voir son rôle dans le workspace:',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Rôle: ${_user!.roleInWorkspace}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 180,
                    child: ElevatedButton(
                      onPressed: () {
                        // Redirection vers l'écran de connexion
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all<Color>(Colors.red),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Centre l'icône et le texte dans le bouton
                        children: [
                          Icon(
                            Icons.power_settings_new, // Icône de déconnexion
                            color: Colors.white,
                          ),
                          SizedBox(
                              width: 3), // Espacement entre l'icône et le texte
                          Text(
                            'Se déconnecter',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
