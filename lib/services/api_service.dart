import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yumpro/models/restaurant.dart';
import 'package:yumpro/services/auth_service.dart';

class ApiService {
  static const String BASE_URL =
      'https://x8ki-letl-twmt.n7.xano.io/api:LYxWamUX';
  late final AuthService _authService = AuthService();

  // Headers CORS

  // Méthodes pour gérer les requêtes HTTP

  Future<String> login(String email, String password) async {
    final response = await _postRequest('/auth/login', {
      'email': email,
      'password': password,
    });

    return response['authToken'];
  }

  Future<Map<String, dynamic>> getUser(String token) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/auth/me'),
      headers: _headers(token),
    );

    return _handleResponse(response);
  }

  Future<String> signup(String email, String password) async {
    final response = await _postRequest('/auth/signup', {
      'email': email,
      'password': password,
    });

    return response['authToken'];
  }

  Future<Map<String, dynamic>> addCuisine(Map<String, dynamic> cuisine) async {
    return await _postRequest('/cuisine', cuisine);
  }

  Future<Map<String, dynamic>> getCuisine(int cuisineId) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/cuisine/$cuisineId'),
      headers: _headers(null),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> editCuisine(
      int cuisineId, Map<String, dynamic> cuisine) async {
    return await _patchRequest('/cuisine/$cuisineId', cuisine);
  }

  Future<void> deleteCuisine(int cuisineId) async {
    await _deleteRequest('/cuisine/$cuisineId', {});
  }

  Future<List<dynamic>> getAllCuisines() async {
    final response = await http.get(
      Uri.parse('$BASE_URL/cuisine'),
      headers: _headers(null),
    );

    return _handleResponse(response)['data'];
  }

  Future<List<dynamic>> getAllRestaurants() async {
    final response = await http.get(
      Uri.parse('$BASE_URL/restaurants'),
      headers: _headers(null),
    );

    return _handleResponse(response)['data'];
  }

  Future<Map<String, dynamic>> addRestaurant(
      Map<String, dynamic> restaurant) async {
    return await _postRequest('/restaurants', restaurant);
  }

  Future<void> updateUser(int userId, Map<String, dynamic> userData,
      {String? token}) async {
    final endpoint =
        'https://x8ki-letl-twmt.n7.xano.io/api:LYxWamUX/user/$userId';

    final response = await http.patch(
      Uri.parse(endpoint),
      headers: _headers(token),
      body: jsonEncode(userData),
    );

    _handleResponse(response);
  }

  Future<Map<String, dynamic>> joinWorkspace(
      String alias, int userId, int code) async {
    final requestData = {
      'alias': alias,
      'user_id': userId,
      'code': code,
    };

    final response = await http.post(
      Uri.parse('$BASE_URL/workspace/join'),
      headers: _headers(null),
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to join workspace: ${response.statusCode}');
    }
  }

  // AWS Endpoints
  static const String AWS_UPLOAD_URL =
      'https://dmscenr32d.execute-api.eu-west-1.amazonaws.com/main';
  static const String AWS_GET_PLACE_INFO_URL =
      'https://eflk4mkrh5.execute-api.eu-west-1.amazonaws.com/main';
  static const String AWS_GET_WORKSPACE_CODE_URL =
      'https://m1tamh0es0.execute-api.eu-west-1.amazonaws.com/main';

  Future<void> uploadUrlContentToS3(String s3Key, String url) async {
    final response = await http.post(
      Uri.parse(AWS_UPLOAD_URL),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'s3_key': s3Key, 'url': url}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to upload URL content to S3');
    }
  }

  Future<Map<String, dynamic>> getPlacesInfos(
      String name, String address) async {
    var uri =
        Uri.https('eflk4mkrh5.execute-api.eu-west-1.amazonaws.com', '/main');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'name': name, 'address': address}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get place infos');
    }

    Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (responseBody.containsKey('body')) {
      responseBody = jsonDecode(responseBody['body']);
    }

    return responseBody;
  }

  final String apiUrl =
      'https://rk2q32wk65.execute-api.eu-west-1.amazonaws.com/main';

  Future<void> uploadProfilePhoto(String fileName, Uint8List imageData) async {
    final prefs = await SharedPreferences.getInstance();
    final workspacePlaceId = prefs.getString('workspace_place_id');
    final userId = prefs.getInt('user_id');

    if (workspacePlaceId == null || userId == null) {
      throw Exception("Workspace Place ID or User ID is not available.");
    }

    final s3FileName = '$workspacePlaceId/$userId/profile.jpg';
    final encodedImage = base64Encode(imageData);

    final body = jsonEncode({
      'file_name': s3FileName,
      'image_data': encodedImage,
    });

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to upload image: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getWorkspaceInfo(int workspaceId) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/workspace/$workspaceId'),
      headers: _headers(null),
    );

    return _handleResponse(response);
  }

  String getPhotoUrl(String photoReference) {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/photo',
      {
        'maxwidth': '400',
        'photoreference': photoReference,
        'key': "AIzaSyBM05T0u8LoAKr2MtbTIjXtFmrU-06ye6U",
      },
    );

    return uri.toString();
  }

  Future<String> getWorkspaceCode() async {
    final response = await http.get(
      Uri.parse(AWS_GET_WORKSPACE_CODE_URL),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get workspace code');
    }

    print("Code : ${jsonDecode(response.body)['body']}");

    return jsonDecode(response.body)['body'].toString();
  }

  Future<void> updateUserInfo({
    required int userId,
    required int workspaceId,
    required String userName,
    required bool isAnonymous,
    required String userFirstName,
    required String workspacePlaceId,
    required String userPhotoUrl,
  }) async {
    final url = Uri.parse("$BASE_URL/workspace/user/$userId");
    final headers = {
      'Content-Type': 'application/json',
    };

    //userPhotoUrl = _authService.getUserInfo();

    final body = jsonEncode({
      'user_id': userId,
      'workspace_id': workspaceId,
      'user_name': userName,
      'isAnonymous': isAnonymous,
      'user_photo_url': userPhotoUrl,
      'user_first_name': userFirstName,
    });

    final response = await http.patch(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      print("User info updated successfully.");
    } else {
      print("Failed to update user info: ${response.statusCode}");
      print("Response: ${response.body}");
    }
  }

  Future<List<Restaurant>> getRestaurants(int workspaceId) async {
    final String? token = await _authService.getToken();
    if (token == null) {
      throw Exception('Token is null');
    }

    final response = await http.get(
      Uri.parse('$BASE_URL/workspace/restaurants/$workspaceId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load restaurants: ${response.statusCode}');
    }
  }

  Future<String> createAlias(String restaurantName) async {
    final Map<String, String> requestData = {
      "restaurant_name": restaurantName,
    };

    final response = await http.post(
      Uri.parse("https://ck2hfc0b4d.execute-api.eu-west-1.amazonaws.com/main"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final String responseData = response.body;
      print("Alias : ${jsonDecode(responseData)['body']}");
      return jsonDecode(responseData)['body'].toString();
    } else {
      throw Exception("Failed to create alias: ${response.statusCode}");
    }
  }

  Future<Map<String, dynamic>> postHotelInfo(
      String name, String address, int teamSize) async {
    try {
      Map<String, dynamic> placeInfo = await getPlacesInfos(name, address);
      String alias = await createAlias(placeInfo['name']);
      String code = await getWorkspaceCode();
      String photoReference = placeInfo['photos'][0]['photo_reference'];
      String photoUrl = getPhotoUrl(photoReference);
      String s3Key = '${placeInfo['place_id']}/profile.jpg';
      await uploadUrlContentToS3(s3Key, photoUrl);
      String s3PhotoUrl =
          'https://yummaptest2.s3.eu-north-1.amazonaws.com/$s3Key';
      AuthService authService = AuthService();
      Map<String, dynamic> userInfo = await authService.getUserInfo();
      int userId = userInfo['user_id'];
      Map<String, dynamic> hotelData = {
        "name": placeInfo['name'],
        "code": code,
        "alias": alias,
        "team": {"user_id": userId, "role": "admin", "status": "accepted"},
        "placeID": placeInfo['place_id'],
        "address": placeInfo['address'],
        "phone": "",
        "gps": placeInfo['geometry']['location'],
        "photo_url": s3PhotoUrl,
        "restaurants_placeID": [],
        "team_size": teamSize
      };

      // Send the POST request
      final Map<String, dynamic> response =
          await _postRequest('/workspace', hotelData);

      // Check if the request was successful and return the ID and placeID
      if (response.containsKey('id') && response.containsKey('placeID')) {
        int hotelId = response['id'];
        String hotelPlaceID = response['placeID'];
        String nameNoAccent = response['name_no_accent'];
        return {
          'hotelId': hotelId,
          'hotelPlaceID': hotelPlaceID,
          'name_no_accent': nameNoAccent,
        };
      } else {
        throw Exception('Failed to post hotel info: ${response.toString()}');
      }
    } catch (e) {
      print('Error posting hotel info: $e');
      rethrow;
    }
  }

  Future<Restaurant> addRestaurantToWorkspace({
    required int workspaceId,
    required String restaurantName,
    required int cuisine_id,
    required String address,
  }) async {
    try {
      Map<String, dynamic> placeInfo =
          await getPlacesInfos(restaurantName, address);
      print('*********************');
      print('*********************');

      String photoReference = placeInfo['photos'][0]['photo_reference'];
      String photoUrl = getPhotoUrl(photoReference);
      String s3Key = '${placeInfo['place_id']}/profile.jpg';
      await uploadUrlContentToS3(s3Key, photoUrl);
      String s3PhotoUrl =
          'https://yummaptest2.s3.eu-north-1.amazonaws.com/$s3Key';
      Map<String, dynamic> restaurantData = {
        "cuisine_id": cuisine_id,
        "address": placeInfo['address'],
        "restaurant_name": placeInfo['name'],
        "picture_profile": s3PhotoUrl,
        "place_id": placeInfo['place_id'],
        "GPS_address": {
          "lat": placeInfo['geometry']['location']['lat'],
          "lng": placeInfo['geometry']['location']['lng']
        },
        "workspace_id": workspaceId,
        "phone_number": placeInfo['formatted_phone_number'] ?? '',
        "ratings": placeInfo['rating'] ?? 0.0,
        "handicap": placeInfo['handicap'] ?? '',
        "vege": placeInfo['vege'] ?? '',
        "number_of_reviews": placeInfo['user_ratings_total'] ?? 0,
        "website_url": placeInfo['website'] ?? '',
        "schedule": placeInfo['weekday_text'] ?? [],
        "reviews": placeInfo['reviews']
                ?.map((review) => {
                      'author': review['author_name'],
                      'text': review['text'],
                      'rating': review['rating'],
                      'date_published': review['time'],
                      'author_profile_url': review['author_url'],
                      'lang': review['language'],
                    })
                .toList() ??
            [],
      };
      print('*********************');

      // Effectuer la requête POST pour ajouter le restaurant
      Map<String, dynamic> response =
          await _postRequest('/workspace/restaurant', restaurantData);
      print("SIX");
      print(response);
      // Créer une instance de Restaurant à partir de la réponse
      Restaurant restaurant = Restaurant(
        id: response['id'], // Assurez-vous que l'API retourne un identifiant
        name: response['name'],
        address: response['address_str'],
        imageUrl: response['picture_profile'],
        place_id: response['placeId'],
        videoLinks:
            (response['video_links'] as List).map((e) => e.toString()).toList(),
      );

      // Retourner l'instance de Restaurant
      return restaurant;
    } catch (e) {
      print('Error adding restaurant to workspace: $e');
      rethrow;
    }
  }

  Future<void> sendInvitationEmail(
      int workspaceId, int userId, String recipientEmail) async {
    const String apiURL =
        'https://opdbf3s8hc.execute-api.eu-west-1.amazonaws.com/main';

    final Map<String, dynamic> payload = {
      'workspace_id': workspaceId,
      'user_id': userId,
      'recipient_email': recipientEmail
    };

    try {
      final response = await http.post(
        Uri.parse(apiURL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print("Lambda function executed successfully.");
        print("Response:");
        print(jsonDecode(response.body));
      } else {
        print(
            "Failed to execute Lambda function. Status code: ${response.statusCode}");
        print("Response:");
        print(response.body);
      }
    } catch (e) {
      print("Error occurred while making the request: $e");
    }
  }

  // Nouvelles méthodes ajoutées

  Future<List<dynamic>> getReviewsByRestaurant(
      int restaurantId, int workspaceId) async {
    // Construction de l'URL de l'endpoint
    final String endpoint = '/review/restaurant/$restaurantId';

    try {
      // Envoi de la requête POST à Xano avec les données requises
      final response = await http.post(
        Uri.parse('$BASE_URL$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "restaurant_id": restaurantId,
          "workspace_id": workspaceId,
        }),
      );

      // Vérification de la réponse
      if (response.statusCode == 200) {
        // Conversion de la réponse JSON en une liste dynamique
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        // En cas d'erreur, affichage du code d'erreur
        throw Exception('Failed to get reviews: ${response.statusCode}');
      }
    } catch (e) {
      // Gestion des erreurs potentielles
      throw Exception('Error fetching reviews: $e');
    }
  }

  Future<void> deleteReview(int reviewId) async {
    final String endpoint = '/review/$reviewId';

    try {
      final response = await http.delete(
        Uri.parse('$BASE_URL$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete review: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting review: $e');
    }
  }

  Future<void> removeRestaurantFromWorkspace({
    required int workspaceId,
    required String restaurantPlaceId,
    required int userId,
  }) async {
    final String endpoint = '/workspace/restaurants/$restaurantPlaceId';

    try {
      final response = await http.delete(
        Uri.parse('$BASE_URL$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "workspace_id": workspaceId,
          "restaurant_place_id": restaurantPlaceId,
          "user_id": userId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove restaurant: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error removing restaurant: $e');
    }
  }

  Future<List<dynamic>> getWorkspaceInvitations(int workspaceId) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/workspace/invitations/$workspaceId'),
      headers: _headers(null),
    );

    return jsonDecode(response.body) as List<dynamic>;
  }

  // Nouvelle méthode pour marquer une invitation comme lue
  Future<void> markInvitationAsRead(int invitationId, {String? token}) async {
    final requestData = {'read': true, 'consumed': false};
    final endpoint = '/invitation/$invitationId';
    await http.patch(Uri.parse(BASE_URL + endpoint),
        headers: _headers(null), body: jsonEncode(requestData));

    //await _patchRequest(endpoint, {'read': true}, token: token);
  }

  Future<Map<String, dynamic>> consumeInvitation(int invitationId, int code,
      {String? token}) async {
    final requestData = {'read': true, 'consumed': true, 'code': code};
    final endpoint = '/invitation/$invitationId';
    final response = await http.patch(
      Uri.parse(BASE_URL + endpoint),
      headers: _headers(token),
      body: jsonEncode(requestData),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final String errorMessage = responseBody['message'] ?? 'Unknown error';
      print("Erreur sur l'invitation: $errorMessage");
      throw Exception("$errorMessage");
    }

    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getWorkspaceTeam(int workspaceId) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/workspace/team/$workspaceId'),
      headers: _headers(null),
    );

    return jsonDecode(response.body) as List<dynamic>;
  }

  // Méthodes HTTP génériques

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

  Future<Map<String, dynamic>> _deleteRequest(
      String endpoint, Map<String, dynamic> body,
      {String? token}) async {
    final response = await http.delete(
      Uri.parse('$BASE_URL$endpoint'),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  // Méthodes utilitaires

  Map<String, String> _headers(String? token) {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Access-Control-Allow-Origin': '*',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<Map<String, dynamic>> addReview(String comment, int rating, int userId,
      int restaurantId, int workspaceId) async {
    final reviewData = {
      "comment": comment,
      "rating": rating,
      "user_id": userId,
      "restaurants_id": restaurantId,
      "workspace_id": workspaceId,
    };
    return await _postRequest('/review', reviewData);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Request failed: ${response.statusCode}');
    }
  }
}
