import 'package:flutter/material.dart';
import 'package:yumpro/models/restaurant.dart';
import 'package:yumpro/models/review.dart';
import 'package:yumpro/models/user.dart';
import 'package:yumpro/services/api_service.dart';
import 'package:yumpro/services/auth_service.dart';
import 'package:yumpro/utils/appcolors.dart';
import 'package:yumpro/utils/custom_widgets.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  List<Review> reviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      final userInfo = await _authService.getUserInfo();
      List<dynamic>? response = await _apiService.getReviewsByRestaurant(
          widget.restaurant.id, userInfo['workspace_id'] ?? 4);
      if (response.isNotEmpty) {
        setState(() {
          reviews = response
              .map((data) {
                if (data is Map<String, dynamic>) {
                  return Review.fromJson(data);
                } else {
                  print(
                      'Element in response is not a Map<String, dynamic>: $data');
                  return null;
                }
              })
              .whereType<Review>()
              .toList();
          isLoading = false;
        });
      } else {
        print('Aucune critique n\'a été trouvée.');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching reviews: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addReview(String comment, int rating) async {
    try {
      final userInfo = await _authService.getUserInfo();

      // Ajouter la critique
      Map<String, dynamic> review = await _apiService.addReview(
        comment,
        rating,
        userInfo['user_id'] ?? 1,
        widget.restaurant.id,
        userInfo['workspace_id'] ?? 1,
      );

      // Mettre à jour la liste des critiques
      final newReview = Review(
        id: review['id'],
        comment: comment,
        rating: rating.toDouble(),
        user: User(
          firstName: userInfo['first_name'],
          lastName: userInfo['name'],
          photoUrl: userInfo['photo_url'],
          workspace: '',
          roleInWorkspace: '',
          numComments: 1,
        ),
      );

      setState(() {
        reviews.add(newReview);
      });

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Critique ajoutée avec succès.'),
        ),
      );
    } catch (e) {
      // Afficher un message d'erreur
      print('Error adding review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'ajout de la critique.'),
        ),
      );
    }
  }

  Future<void> _deleteReview(int reviewId) async {
    try {
      await _apiService.deleteReview(reviewId);
      setState(() {
        reviews.removeWhere((review) => review.id == reviewId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Critique supprimée avec succès.'),
        ),
      );
    } catch (e) {
      print('Error deleting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suppression de la critique.'),
        ),
      );
    }
  }

  Future<void> _removeRestaurant() async {
    try {
      final userInfo = await _authService.getUserInfo();
      await _apiService.removeRestaurantFromWorkspace(
        workspaceId: userInfo['workspace_id'] ?? 1,
        restaurantPlaceId: widget.restaurant.place_id,
        userId: userInfo['user_id'] ?? 1,
      );

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restaurant supprimé avec succès.'),
        ),
      );

      // Revenir à la page précédente avec un résultat
      Navigator.of(context).pop(true);
    } catch (e) {
      // Afficher un message d'erreur
      print('Error removing restaurant: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suppression du restaurant.'),
        ),
      );
    }
  }

  double _calculateAverageRating() {
    if (reviews.isEmpty) return 0.0;
    double sum = reviews.fold(0, (sum, review) => sum + review.rating);
    return sum / reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    double averageRating = _calculateAverageRating();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.restaurant.name,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            label: const Text(
              'Retirer le restaurant',
              style: TextStyle(color: Colors.redAccent),
            ),
            onPressed: _removeRestaurant,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.network(
                            widget.restaurant.imageUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Adresse:'),
                        Text(
                          widget.restaurant.address,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Note:'),
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.accent),
                            const SizedBox(width: 4),
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Ajouter une critique:'),
                        const SizedBox(height: 8),
                        AddReviewForm(
                          restaurantId: widget.restaurant.id,
                          onAddReview: _addReview,
                        ),
                        const SizedBox(height: 26),
                        _buildSectionTitle('Commentaires:'),
                        const SizedBox(height: 8),
                        // Affichage des commentaires
                        ...reviews.map(
                          (review) => ReviewItem(
                            review: review,
                            onDelete: () => _deleteReview(review.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.black,
      ),
    );
  }
}

class ReviewItem extends StatelessWidget {
  final Review review;
  final VoidCallback onDelete;

  const ReviewItem({super.key, required this.review, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(review.user.photoUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${review.user.firstName} ${review.user.lastName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(review.rating.toString()),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(review.comment),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class AddReviewForm extends StatefulWidget {
  final int restaurantId;
  final Function(String comment, int rating) onAddReview;

  const AddReviewForm(
      {super.key, required this.restaurantId, required this.onAddReview});

  @override
  _AddReviewFormState createState() => _AddReviewFormState();
}

class _AddReviewFormState extends State<AddReviewForm> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Note:'),
            const SizedBox(width: 8),
            Expanded(
              child: Slider(
                value: _rating,
                min: 0,
                max: 5,
                divisions: 5,
                onChanged: (value) {
                  setState(() {
                    _rating = value;
                  });
                },
                label: _rating.toString(),
                activeColor: AppColors.accent, // Couleur de la partie active
                inactiveColor: Colors.grey, // Couleur de la partie inactive
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _commentController,
          decoration: InputDecoration(
            labelText: 'Commentaire',
            hintText: 'Entrez votre commentaire',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 300,
          child: CustomWidgets.primaryButton(
            text: "Ajouter la critique",
            onPressed: () async {
              final String comment = _commentController.text.trim();
              if (comment.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez entrer un commentaire.'),
                  ),
                );
                return;
              }

              widget.onAddReview(comment, _rating.round());
              _commentController.clear();
              setState(() {
                _rating = 0.0;
              });
            },
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
