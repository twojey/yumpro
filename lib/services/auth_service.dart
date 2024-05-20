import 'dart:html'
    as html; // Importer dart:html pour accéder à window.localStorage

class AuthService {
  static const String _tokenKey = 'auth_token';

  // Sauvegarder le token
  Future<void> saveToken(String token) async {
    // Sur le web
    html.window.localStorage[_tokenKey] = token;
    }

  // Récupérer le token
  Future<String?> getToken() async {
    // Sur le web
    return html.window.localStorage[_tokenKey];
    }

  // Supprimer le token
  Future<void> removeToken() async {
    // Sur le web
    html.window.localStorage.remove(_tokenKey);
    }
}
