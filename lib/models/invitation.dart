import 'restaurant.dart';

class Invitation {
  final int id;
  final int createdAt;
  final int restaurantsId;
  final int workspaceId;
  bool isRead;
  bool consumed;
  final Restaurant restaurant;
  final int code;
  final int? dateExpiration; // Utilisation de nullable int
  final RestaurantDetails restaurantDetails;
  final int? dateUsage;

  Invitation({
    required this.id,
    required this.createdAt,
    required this.restaurantsId,
    required this.workspaceId,
    this.isRead = false,
    this.consumed = false,
    required this.code,
    required this.restaurant,
    this.dateExpiration,
    required this.restaurantDetails,
    this.dateUsage,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'],
      createdAt: json['created_at'],
      restaurantsId: json['restaurants_id'],
      workspaceId: json['workspace_id'],
      isRead: json['read'],
      code: json['code'],
      consumed: json['consumed'],
      dateExpiration: json['date_expiration'],
      restaurant: Restaurant.fromJson(json['restaurant']),
      restaurantDetails:
          RestaurantDetails.fromJson(json['_resto_yumpro_of_restaurants']),
      dateUsage: json['date_usage'],
    );
  }
}

// Le modèle pour les informations supplémentaires sur le restaurant et l'espace de travail
class RestaurantDetails {
  final String presentation;
  final String instagram;
  final String instructions;

  RestaurantDetails({
    required this.presentation,
    required this.instagram,
    required this.instructions,
  });

  factory RestaurantDetails.fromJson(Map<String, dynamic> json) {
    return RestaurantDetails(
      presentation: json['presentation'],
      instagram: json['instagram'],
      instructions: json['instructions'],
    );
  }
}
