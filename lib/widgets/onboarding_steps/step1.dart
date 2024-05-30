import 'package:flutter/material.dart';

class Step1 extends StatefulWidget {
  final Function(bool, Map<String, dynamic>) onCompletion;

  const Step1({super.key, required this.onCompletion});

  @override
  _Step1State createState() => _Step1State();
}

class _Step1State extends State<Step1> {
  String _selectedOption = 'hotel';

  void _nextStep() {
    Map<String, dynamic> data = {
      'accountType': _selectedOption,
    };
    widget.onCompletion(_selectedOption == 'hotel', data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Étape 1 : Choisir le type de compte'),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          value: _selectedOption,
          onChanged: (value) {
            setState(() {
              _selectedOption = value!;
            });
          },
          items: const [
            DropdownMenuItem(
              value: 'hotel',
              child: Text('Compte hôtel'),
            ),
            // DropdownMenuItem(
            //   value: 'influenceur',
            //   child: Text('Créer un compte influenceur'),
            // ),
          ],
          decoration: const InputDecoration(
            labelText: 'Choisir le type de compte',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _nextStep,
          child: const Text('Suivant'),
        ),
      ],
    );
  }
}
