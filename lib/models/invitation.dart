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
    );
  }
}
