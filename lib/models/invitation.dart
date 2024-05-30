import 'restaurant.dart';

class Invitation {
  final int id;
  final int createdAt;
  final int restaurantsId;
  final int workspaceId;
  bool isRead;
  final Restaurant restaurant;

  Invitation({
    required this.id,
    required this.createdAt,
    required this.restaurantsId,
    required this.workspaceId,
    this.isRead = false,
    required this.restaurant,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    //print(json);
    return Invitation(
      id: json['id'],
      createdAt: json['created_at'],
      restaurantsId: json['restaurants_id'],
      workspaceId: json['workspace_id'],
      isRead: false,
      restaurant: Restaurant.fromJson(json['restaurant']),
    );
  }
}
