import 'package:flutter/material.dart';
import 'package:yumpro/models/restaurant.dart';
import 'package:yumpro/models/review.dart';
import 'package:yumpro/models/user.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    List<Review> reviews = [
      Review(
        user: User(
          firstName: 'Alice',
          lastName: 'Smith',
          workspace: 'Workspace A',
          numComments: 15,
          photoUrl:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
          roleInWorkspace: 'Admin',
        ),
        comment: 'Excellent service!',
        rating: 4.5,
      ),
      Review(
        user: User(
          firstName: 'Bob',
          lastName: 'Johnson',
          workspace: 'Workspace B',
          numComments: 20,
          photoUrl:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
          roleInWorkspace: 'Employee',
        ),
        comment: 'Très bon repas!',
        rating: 5.0,
      ),
      // Ajoutez d'autres critiques ici
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          restaurant.name,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.redAccent),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.network(
                  restaurant.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Adresse:'),
              Text(
                restaurant.address,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Note:'),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    restaurant.rating.toString(),
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Nombre de critiques:'),
              Text(
                restaurant.numReviews.toString(),
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Ajouter une critique:'),
              const SizedBox(height: 8),
              const AddReviewForm(),
              const SizedBox(height: 16),
              _buildSectionTitle('Commentaires:'),
              const SizedBox(height: 8),
              // Affichage des commentaires
              ...reviews.map((review) => ReviewItem(review: review)),
            ],
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

  const ReviewItem({super.key, required this.review});

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
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(review.rating.toString()),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(review.comment),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddReviewForm extends StatefulWidget {
  const AddReviewForm({super.key});

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
        const SizedBox(height: 8),
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
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            // primary: Colors.blue,
            // onPrimary: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          onPressed: () {
            // Soumettre la critique
            final String comment = _commentController.text.trim();
            final Review newReview = Review(
              user: User(
                firstName: 'John',
                lastName: 'Doe',
                workspace: 'Workspace',
                numComments: 0,
                photoUrl: 'https://example.com/avatar.jpg',
                roleInWorkspace: 'Role',
              ),
              comment: comment,
              rating: _rating,
            );
            // Ajouter la critique à la liste des critiques (vous devrez probablement passer la liste des critiques en tant qu'argument au constructeur de AddReviewForm)
            // Ajoutez votre logique pour traiter la nouvelle critique ici
            // Vous pouvez également réinitialiser les champs du formulaire ici
          },
          child: const Text('Ajouter critique'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
