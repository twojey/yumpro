import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';

  // Sauvegarder le token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Récupérer le token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Supprimer le token
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Sauvegarder les informations utilisateur
  Future<void> saveUserInfo(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    if (userData.containsKey('user_id')) {
      await prefs.setInt('user_id', userData['user_id'] as int);
    } else {
      await prefs.setInt('user_id', userData['id'] as int);
    }

    if (userData.containsKey('name')) {
      await prefs.setString('name', userData['name']);
    }

    if (userData.containsKey('first_name')) {
      await prefs.setString('first_name', userData['first_name']);
    }
    if (userData.containsKey('photo_url')) {
      await prefs.setString('photo_url', userData['photo_url']);
    }
    if (userData.containsKey('name_no_accent')) {
      await prefs.setString('name_no_accent', userData['name_no_accent']);
    }
    await prefs.setString('email', userData['email']);
    await prefs.setInt('workspace_id', userData['workspace_id']);

    if (userData.containsKey('workspace') &&
        userData['workspace'].containsKey('placeID')) {
      await prefs.setString(
          'workspace_place_id', userData['workspace']['placeID']);
    } else {
      //await prefs.remove('workspace_place_id');
    }

    if (userData.containsKey('anonymous_com')) {
      await prefs.setBool('anonymous_com', userData['anonymous_com']);
    }
  }

  // Récupérer les informations utilisateur
  Future<Map<String, dynamic>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'user_id': prefs.getInt('user_id'),
      'name': prefs.getString('name'),
      'first_name': prefs.getString('first_name'),
      'email': prefs.getString('email'),
      'workspace_id': prefs.getInt('workspace_id'),
      'workspace_place_id': prefs.getString('workspace_place_id'),
      'photo_url': prefs.getString('photo_url'),
      'name_no_accent': prefs.getString("name_no_accent"),
      'anonymous_com': prefs.getBool("anonymous_com")
    };
  }
}
