import 'package:flutter/material.dart';

class Step2Influencer extends StatefulWidget {
  final Function(Map<String, dynamic>) onNextPressed;

  const Step2Influencer({super.key, required this.onNextPressed});

  @override
  _Step2InfluencerState createState() => _Step2InfluencerState();
}

class _Step2InfluencerState extends State<Step2Influencer> {
  String _selectedNetwork = 'Tiktok';
  final TextEditingController _aliasController = TextEditingController();

  void _submit() {
    Map<String, dynamic> data = {
      'network': _selectedNetwork,
      'alias': _aliasController.text,
    };
    widget.onNextPressed(data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Étape 2 : Ajoutez votre compte influenceur'),
        DropdownButton<String>(
          value: _selectedNetwork,
          onChanged: (String? newValue) {
            setState(() {
              _selectedNetwork = newValue ?? 'Tiktok';
            });
          },
          items: <String>['Tiktok', 'Instagram', 'YouTube']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        TextFormField(
          controller: _aliasController,
          decoration: const InputDecoration(
            labelText: 'Alias du compte',
            hintText: 'Entrez l\'alias de votre compte',
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Soumettre'),
        ),
      ],
    );
  }
}
