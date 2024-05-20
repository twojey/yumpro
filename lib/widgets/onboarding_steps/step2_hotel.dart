import 'package:flutter/material.dart';

class Step2Hotel extends StatefulWidget {
  final Function(Map<String, dynamic>) onNextPressed;

  const Step2Hotel({super.key, required this.onNextPressed});

  @override
  _Step2HotelState createState() => _Step2HotelState();
}

class _Step2HotelState extends State<Step2Hotel> {
  bool _showCreateForm = false;
  bool _showJoinForm = false;
  final TextEditingController _hotelNameController = TextEditingController();
  final TextEditingController _hotelAddressController = TextEditingController();
  final TextEditingController _workspaceNameController =
      TextEditingController();
  final TextEditingController _invitationCodeController =
      TextEditingController();
  int? _teamSize;

  void _toggleCreateFormVisibility() {
    setState(() {
      _showCreateForm = !_showCreateForm;
      _showJoinForm = false;
    });
  }

  void _toggleJoinFormVisibility() {
    setState(() {
      _showJoinForm = !_showJoinForm;
      _showCreateForm = false;
    });
  }

  void _submitCreate() {
    Map<String, dynamic> data = {
      'hotelName': _hotelNameController.text,
      'hotelAddress': _hotelAddressController.text,
      'teamSize': _teamSize,
    };
    widget.onNextPressed(data);
  }

  void _submitJoin() {
    Map<String, dynamic> data = {
      'workspaceName': _workspaceNameController.text,
      'invitationCode': _invitationCodeController.text,
    };
    widget.onNextPressed(data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Étape 2 : Choisir un workspace (Compte Hôtel)'),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _toggleCreateFormVisibility,
              child: const Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Créer un nouveau Workspace'),
                ],
              ),
            ),
            TextButton(
              onPressed: _toggleJoinFormVisibility,
              child: const Text(
                'Rejoindre un workspace déjà existant',
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_showCreateForm)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _hotelNameController,
                decoration: const InputDecoration(labelText: 'Nom de l\'hôtel'),
              ),
              TextFormField(
                controller: _hotelAddressController,
                decoration:
                    const InputDecoration(labelText: 'Adresse de l\'hôtel'),
              ),
              DropdownButtonFormField<int>(
                value: _teamSize,
                items: const [
                  DropdownMenuItem<int>(
                    value: 1,
                    child: Text('1-10 employés'),
                  ),
                  DropdownMenuItem<int>(
                    value: 2,
                    child: Text('10-20 employés'),
                  ),
                  DropdownMenuItem<int>(
                    value: 3,
                    child: Text('20-50 employés'),
                  ),
                  DropdownMenuItem<int>(
                    value: 4,
                    child: Text('50+ employés'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _teamSize = value;
                  });
                },
                decoration:
                    const InputDecoration(labelText: 'Taille de l\'équipe'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitCreate,
                child: const Text('Créer le workspace'),
              ),
            ],
          ),
        if (_showJoinForm)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _workspaceNameController,
                decoration:
                    const InputDecoration(labelText: 'Nom du workspace'),
              ),
              TextFormField(
                controller: _invitationCodeController,
                decoration:
                    const InputDecoration(labelText: 'Code d\'invitation'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitJoin,
                child: const Text('Rejoindre'),
              ),
            ],
          ),
      ],
    );
  }
}
