import 'package:flutter/material.dart';
import 'package:yumpro/services/auth_service.dart';
import 'package:yumpro/services/api_service.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late Map<String, dynamic> _userInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final authService = AuthService();
      final userInfo = await authService.getUserInfo();

      setState(() {
        _userInfo = userInfo;
        _isLoading = false;
      });
    } catch (error) {
      // Handle potential errors during user info retrieval
      print('Failed to retrieve user information: $error');
    }
  }

  Future<void> _sendEvent() async {
    if (_userInfo.isNotEmpty) {
      final apiService = ApiService();
      final event = {
        'invitation_id': 19,
        // Add any additional event data here if needed
      };
      try {
        await apiService.sendEvent('dinnerValidated', event);
        print('Event sent successfully.');
      } catch (error) {
        print('Failed to send event: $error');
      }
    } else {
      print('User information is not available.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Screen'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _sendEvent,
                child: const Text('Send Event'),
              ),
      ),
    );
  }
}
