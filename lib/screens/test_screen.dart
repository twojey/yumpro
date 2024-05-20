import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  TextEditingController _urlController = TextEditingController();
  TextEditingController _s3KeyController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _s3KeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Screen'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(labelText: 'URL de la photo'),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _s3KeyController,
              decoration: InputDecoration(labelText: 'Clé S3'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                String url = _urlController.text;
                String s3Key = _s3KeyController.text;
                // Vous pouvez appeler votre fonction d'envoi ici
                print('URL: $url, S3 Key: $s3Key');
              },
              child: Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }
}
