import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yumpro/services/api_service.dart';

class Step2Hotel extends StatefulWidget {
  final Function(Map<String, dynamic>) onNextPressed;

  const Step2Hotel({Key? key, required this.onNextPressed}) : super(key: key);

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
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

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

  void _submitCreate() async {
    setState(() {
      _isLoading = true;
    });

    print("LETS GO ");

    try {
      Map<String, dynamic> hotelInfo = await _apiService.postHotelInfo(
          _hotelNameController.text, _hotelAddressController.text, _teamSize!);

      int hotelid = hotelInfo['hotelId'];
      String hotelPlaceID = hotelInfo['hotelPlaceID'];
      String hotelNameNoAccent = hotelInfo['name_no_accent'];

      Fluttertoast.showToast(
        msg: "Le Workspace a bien été créé",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Enregistrer le workspace localement
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('workspaceName', _hotelNameController.text);
      prefs.setInt('workspace_id', hotelid);
      prefs.setString('workspace_place_id', hotelPlaceID);
      prefs.setString('name_no_accent', hotelNameNoAccent);

      // Passer à l'étape suivante une fois le workspace créé avec succès
      Map<String, dynamic> data = {
        'hotelName': _hotelNameController.text,
        'hotelAddress': _hotelAddressController.text,
        'teamSize': _teamSize,
        'name_no_accent': hotelNameNoAccent
      };
      widget.onNextPressed(data);
    } catch (e) {
      print('___ ERROR CREATE WORKSPACE ___');
      print(e.toString());
      String errorMessage = "Erreur lors de la création du workspace: $e";
      if (e.toString().contains("403")) {
        errorMessage = "Ce workspace existe déjà";
      }
      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
        webBgColor: "linear-gradient(to right, #dc1c13, #dc1c13)",
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _submitJoin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ??
          0; // Utilisez la valeur par défaut que vous souhaitez

      Map<String, dynamic> workspaceData = await _apiService.joinWorkspace(
        _workspaceNameController.text,
        userId,
        int.parse(_invitationCodeController.text),
      );

      // Enregistrer l'ID du workspace localement
      await prefs.setString('workspaceName', _workspaceNameController.text);
      await prefs.setString('workspace_place_id', workspaceData['placeID']);
      await prefs.setString('name_no_accent', workspaceData['name_no_accent']);
      await prefs.setInt(
          'workspace_id',
          workspaceData[
              'id']); // Assurez-vous que 'id' est le champ approprié dans votre réponse

      Fluttertoast.showToast(
        msg: "Vous avez rejoint le workspace avec succès",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Passer à l'étape suivante une fois le workspace rejoint avec succès
      Map<String, dynamic> data = {
        'workspaceName': _workspaceNameController.text,
        'invitationCode': _invitationCodeController.text,
      };
      widget.onNextPressed(data);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur lors de la tentative de rejoindre le workspace: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
        webBgColor: "linear-gradient(to right, #dc1c13, #dc1c13)",
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: SharedPreferences.getInstance()
          .then((prefs) => prefs.getInt('workspace_id')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.data != null && snapshot.data != 0) {
          return Card(
            child: ListTile(
              leading: Icon(Icons.work),
              title: Text('Vous faites partie d\'un workspace'),
              subtitle: Text(
                  'Vous pouvez accéder aux fonctionnalités de votre workspace.'),
            ),
          );
        } else {
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
                      decoration:
                          const InputDecoration(labelText: 'Nom de l\'hôtel'),
                    ),
                    TextFormField(
                      controller: _hotelAddressController,
                      decoration: const InputDecoration(
                          labelText: 'Adresse de l\'hôtel'),
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
                      decoration: const InputDecoration(
                          labelText: 'Taille de l\'équipe'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitCreate,
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : const Text('Créer le workspace'),
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
                      decoration: const InputDecoration(
                          labelText: 'Code d\'invitation'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitJoin,
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : const Text('Rejoindre'),
                    ),
                  ],
                ),
            ],
          );
        }
      },
    );
  }
}
