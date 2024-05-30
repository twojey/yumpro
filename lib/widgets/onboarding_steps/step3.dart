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

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Retrieve existing user data
    final userData = await AuthService().getUserInfo();

    // Update user data with profile data
    userData['name'] = _lastNameController.text;
    userData['first_name'] = _firstNameController.text;
    userData['anonymous_com'] = false;
    userData['user_id'] = userData['user_id'] as int;
    userData['id'] = userData['user_id'] as int;
    String wId = userData['workspace_place_id'];
    userData['photo_url'] =
        "https://yummaptest2.s3.eu-north-1.amazonaws.com/$wId/profile.jpg";

    print("--- STEP 3 -----");

    print(userData); // For debugging purposes

    // Save updated user data
    await AuthService().saveUserInfo(userData);

    // Call onCompletion with updated user data
    widget.onCompletion(userData);

    // Navigate to home screen
    // Navigator.pushReplacementNamed(context, '/');
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
          onPressed: _submitForm,
          child: const Text('Terminer'),
        ),
      ],
    );
  }
}
