import 'package:yumpro/models/user.dart';

class Review {
  final User user;
  final String comment;
  final double rating;

  Review({
    required this.user,
    required this.comment,
    required this.rating,
  });
}
