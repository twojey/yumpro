import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart'; // Import clipboard
import 'package:yumpro/services/auth_service.dart'; // Import AuthService

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  _QRCodeScreenState createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  String _branchUrl = ''; // Initialisation de _branchUrl avec une chaîne vide
  final AuthService _authService = AuthService(); // Instance of AuthService

  @override
  void initState() {
    super.initState();
    _generateBranchLink();
  }

  Future<void> _generateBranchLink() async {
    try {
      final userInfo = await _authService.getUserInfo();
      final workspaceId = userInfo['workspace_id'] ?? 1;
      String nameNoAccent = userInfo['name_no_accent'] ?? '';
      nameNoAccent = nameNoAccent
          .replaceAll(' ', '_')
          .toLowerCase(); // Remplacer les espaces par des underscores

      const url = 'https://api2.branch.io/v1/url';
      final payload = {
        "branch_key": "key_live_dsgNrw6vwN75bbP0bZIpFfcdvFi1dN9o",
        "channel": "yumpro",
        "feature": "qr_code",
        "campaign": "workspace_invite",
        "stage": "new_user",
        "data": {
          "\$deeplink_path": "/workspace/$workspaceId",
          "custom_key": "custom_value",
          "workspace_id": workspaceId.toString(),
          // Utiliser name_no_accent pour le lien personnalisé
          "\$canonical_url": "https://yummap.app.link/$nameNoAccent",
        },
        "ios": {
          "\$ios_url": "https://apps.apple.com/app/id6479711235",
        },
        "android": {
          "\$android_url":
              "https://play.google.com/store/apps/details?id=com.domain.yummap&hl=en_US",
        },
        "desktop": {
          "\$desktop_url": "https://yourapp.com",
        },
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        json.decode(response.body);
        setState(() {
          _branchUrl = "https://yummap.app.link/$nameNoAccent";
        });
      } else {
        throw Exception('Failed to create Branch link');
      }
    } catch (e) {
      print('Error generating Branch link: $e');
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _branchUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code for Yummap'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _branchUrl.isNotEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'QR code for downloading Yummap',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: _copyToClipboard,
                        ),
                        Text(
                          _branchUrl,
                          style:
                              const TextStyle(fontSize: 16, color: Colors.blue),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    QrImageView(
                      data: _branchUrl,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
