import 'package:flutter/material.dart';

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

  void _submit() {
    Map<String, dynamic> data = {
      'lastName': _lastNameController.text,
      'firstName': _firstNameController.text,
    };
    widget.onCompletion(data);
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
          onPressed: _submit,
          child: const Text('Suivant'),
        ),
      ],
    );
  }
}
