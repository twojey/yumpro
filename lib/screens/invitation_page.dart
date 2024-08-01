import 'package:flutter/material.dart';
import 'package:yumpro/utils/appcolors.dart';
import 'package:yumpro/utils/custom_widgets.dart';
import 'package:yumpro/services/api_service.dart';
import 'package:yumpro/services/mixpanel_service.dart';

class InvitationPage extends StatefulWidget {
  final String invitationId;

  const InvitationPage({super.key, required this.invitationId});

  @override
  _InvitationPageState createState() => _InvitationPageState();
}

class _InvitationPageState extends State<InvitationPage> {
  final TextEditingController _codeController = TextEditingController();
  String? _errorMessage;
  Map<String, dynamic>? _invitationData;

  final ApiService _apiService = ApiService();

  void _validateCode() async {
    final code = _codeController.text;
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Le code de l\'invitation ne peut pas être vide.';
      });
      return;
    }

    try {
      final invitationData = await _apiService.consumeInvitation(
          int.parse(widget.invitationId), int.parse(code));
      setState(() {
        _errorMessage = null;
        _invitationData = invitationData;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code d\'invitation valide!')),
      );

      // Send event to Mixpanel
      AnalyticsManager().trackEvent('Invitation Code Validated', {
        'invitationId': widget.invitationId,
        'code': code,
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          action: SnackBarAction(
            label: 'OK',
            textColor: AppColors.primaryGold,
            onPressed: () {
              // Code pour fermer la SnackBar
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
          duration: const Duration(
              seconds: 7), // La SnackBar ne disparait pas automatiquement
        ),
      );
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Widget _buildInvitationDetails(Map<String, dynamic> data) {
    final workspace = data['_workspace'];
    final team = List<Map<String, dynamic>>.from(workspace['team']);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.check_circle,
                color: Colors.green, // Couleur verte pour l'icône
                size: 100, // Taille de l'icône
              ),
              const SizedBox(height: 20),
              const Text(
                'Code Validé, merci pour votre venue',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // Couleur verte pour le texte
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0), // Coins arrondis
                child: Image.network(
                  workspace['photo_url'],
                  width: 150, // Largeur fixe de l'image
                  height: 100, // Hauteur fixe de l'image
                  fit: BoxFit.cover, // Ajuster l'image pour remplir le cadre
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${workspace['name']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold, // Titre en gras
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20),
              // Utilisation de ListView pour centrer la liste des membres
              Container(
                height: 200, // Hauteur fixe pour la liste
                child: ListView(
                  shrinkWrap: true,
                  children: team.map((member) {
                    final user = member['_user'];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20, // Taille petite
                        backgroundImage: NetworkImage(user['photo_url']),
                      ),
                      title: Text('${user['first_name']} ${user['name']}'),
                      subtitle: Text(
                          'Role: ${member['role']}'), // Retrait du champ "status"
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_invitationData == null) ...[
              const Text('Entrez le code de votre invitation'),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 250, // Limiter la largeur à 250 pixels
                  ),
                  child: TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Code de l\'invitation',
                      errorText: _errorMessage,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              SizedBox(
                width: 250,
                child: CustomWidgets.primaryButton(
                    text: "Valider", onPressed: _validateCode),
              ),
            ] else ...[
              _buildInvitationDetails(_invitationData!),
            ],
          ],
        ),
      ),
    );
  }
}
