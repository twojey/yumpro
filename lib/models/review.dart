import 'package:yumpro/models/user.dart';

class Review {
  final int id;
  final User user;
  final String comment;
  final double rating;

  Review({
    required this.id,
    required this.user,
    required this.comment,
    required this.rating,
  });

  // Méthode factory pour créer une instance de Review à partir d'un objet JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 1,
      user: User.fromJson(json['_user'] ??
          {}), // Utilisation des données utilisateur par défaut si elles sont nulles
      comment: json['comment'] ?? '',
      rating: double.parse(json['rating'].toString()),
    );
  }
}
