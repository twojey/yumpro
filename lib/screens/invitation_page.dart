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
  bool _isMixpanelInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeMixpanel();
  }

  Future<void> _initializeMixpanel() async {
    await AnalyticsManager().init("1f791bb9a5e27c54a6f0443e425a143d");
    setState(() {
      _isMixpanelInitialized = true;
    });
  }

  Future<void> _validateCode() async {
    if (!_isMixpanelInitialized) return;

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
      print(invitationData);

      // Récupérer les informations de `workspace` ou `newsletter`
      final restaurantName = invitationData['_restaurant']['name'];
      final hotelName = invitationData['_workspace']?['name'] ??
          invitationData['_newsletter']?['name'] ??
          'Nom inconnu';

      setState(() {
        _errorMessage = null;
        _invitationData = invitationData;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code d\'invitation valide!')),
      );

      // Envoyer l'événement à Mixpanel avec restaurantName et hotelName
      AnalyticsManager().trackEvent('Invitation Code Validated', {
        'invitationId': widget.invitationId,
        'code': code,
        'restaurantName': restaurantName,
        'hotelName': hotelName,
      });

      // Envoyer l'événement à AWS
      await _apiService.sendEvent('dinnerValidated', {
        'invitation_id': widget.invitationId,
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
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
          duration: const Duration(seconds: 7),
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
    final newsletter = data['_newsletter'];
    final source = workspace ?? newsletter;

    final team = workspace != null
        ? List<Map<String, dynamic>>.from(workspace['team'])
        : [];

    final hotelName = source['name'];
    final photoUrl = source['photo_url'] ??
        'https://yummap.s3.eu-north-1.amazonaws.com/yumpro/hotel_yummap.webp';

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
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'Code Validé !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'Merci pour votre venue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  photoUrl,
                  width: 150,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$hotelName',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20),
              if (workspace != null && team.isNotEmpty)
                Container(
                  height: 200,
                  child: ListView(
                    shrinkWrap: true,
                    children: team.map((member) {
                      final user = member['_user'];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(user['photo_url']),
                        ),
                        title: Text('${user['first_name']} ${user['name']}'),
                        subtitle: Text('Role: ${member['role']}'),
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
        child: _isMixpanelInitialized
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (_invitationData == null) ...[
                    const Text('Entrez le code de votre invitation'),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 250,
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
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
