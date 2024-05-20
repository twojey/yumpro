import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String BASE_URL =
      'https://x8ki-letl-twmt.n7.xano.io/api:LYxWamUX';

  Future<String> login(String email, String password) async {
    final response = await _postRequest('/auth/login', {
      'email': email,
      'password': password,
    });

    return response['authToken'];
  }

  Future<Map<String, dynamic>> getUser(String token) async {
    final response = await _getRequest('/auth/me', token: token);
    return response;
  }

  Future<void> signup(String email, String password) async {
    await _postRequest('/auth/signup', {
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> addCuisine(Map<String, dynamic> cuisine) async {
    return await _postRequest('/cuisine', cuisine);
  }

  Future<Map<String, dynamic>> getCuisine(int cuisineId) async {
    return await _getRequest('/cuisine/$cuisineId');
  }

  Future<Map<String, dynamic>> editCuisine(
      int cuisineId, Map<String, dynamic> cuisine) async {
    return await _patchRequest('/cuisine/$cuisineId', cuisine);
  }

  Future<void> deleteCuisine(int cuisineId) async {
    await _deleteRequest('/cuisine/$cuisineId');
  }

  Future<List<dynamic>> getAllCuisines() async {
    final response = await _getRequest('/cuisine');
    return response['data'];
  }

  Future<List<dynamic>> getAllRestaurants() async {
    final response = await _getRequest('/restaurants');
    return response['data'];
  }

  Future<Map<String, dynamic>> addRestaurant(
      Map<String, dynamic> restaurant) async {
    return await _postRequest('/restaurants', restaurant);
  }

  Future<void> updateUser(
      String authToken, Map<String, dynamic> userData) async {
    await _patchRequest('/auth/me', userData, token: authToken);
  }

  // Methods to handle requests
  Future<Map<String, dynamic>> _postRequest(
      String endpoint, Map<String, dynamic> body,
      {String? token}) async {
    final response = await http.post(
      Uri.parse('$BASE_URL$endpoint'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _getRequest(String endpoint,
      {String? token}) async {
    final response = await http.get(
      Uri.parse('$BASE_URL$endpoint'),
      headers: _headers(token),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _patchRequest(
      String endpoint, Map<String, dynamic> body,
      {String? token}) async {
    final response = await http.patch(
      Uri.parse('$BASE_URL$endpoint'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<void> _deleteRequest(String endpoint, {String? token}) async {
    final response = await http.delete(
      Uri.parse('$BASE_URL$endpoint'),
      headers: _headers(token),
    );
    _handleResponse(response);
  }

  Map<String, String> _headers(String? token) {
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final responseData = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    } else {
      throw Exception(
          '${response.statusCode}: ${responseData['message'] ?? 'An error occurred'}');
    }
  }

  final String _baseUrl =
      'https://dmscenr32d.execute-api.eu-west-1.amazonaws.com/main';

  Future<void> uploadPhotoToS3(String photoUrl, String s3Key) async {
    final Uri uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'url': photoUrl,
        's3_key': s3Key,
      },
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        print('Photo uploaded successfully: ${response.body}');
      } else {
        print(
            'Failed to upload photo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error uploading photo: $e');
    }
  }

  final String _brevoApiUrl = 'https://api.brevo.com/v3/smtp/email';
  final String tryc = '';

  Future<void> sendBasicTransactionalEmail() async {
    final Map<String, dynamic> requestBody = {
      'sender': {
        'name': 'Sender Alex',
        'email': 'senderalex@example.com',
      },
      'to': [
        {
          'email': 'johndoe@example.com',
          'name': 'John Doe',
        }
      ],
      'subject': 'Hello world',
      'htmlContent':
          '<html><head></head><body><p>Hello,</p>This is my first transactional email sent from Brevo.</p></body></html>',
    };

    try {
      final response = await http.post(
        Uri.parse(_brevoApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'api-key': tryc,
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        print('Email d\'invitation envoyé avec succès.');
      } else {
        print(
            'Erreur lors de l\'envoi de l\'email d\'invitation: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de l\'envoi de l\'email d\'invitation: $e');
    }
  }
}
