import 'package:flutter/material.dart';
import 'package:yumpro/models/restaurant.dart';
import 'package:yumpro/screens/restaurant_detail_screen.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  @override
  _RestaurantScreenState createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final List<Restaurant> restaurants = [
    Restaurant(
      name: 'Restaurant A',
      address: '123 Rue de la Paix',
      imageUrl:
          'https://yummaptest2.s3.eu-north-1.amazonaws.com/afrodisiac_paris_2ChIJF-O8i4Vv5kcRfqJBCNs3Awk/Afrodisiac+Paris+2.jpg',
    ),
    Restaurant(
      name: 'Restaurant B',
      address: '456 Avenue des Champs-Élysées',
      imageUrl:
          'https://yummaptest2.s3.eu-north-1.amazonaws.com/quai_nedyChIJ041eX3Fx5kcR0Kh5i1aJ4PI/Quai+Nedy.jpg',
    ),
    Restaurant(
      name: 'Restaurant C',
      address: '789 Boulevard Saint-Michel',
      imageUrl:
          'https://yummaptest2.s3.eu-north-1.amazonaws.com/ravioli_folieChIJIb6bdI9v5kcR6l5WUgZvcjM/Ravioli+Folie.jpg',
    ),
  ];
  final Map<int, String> _cuisines = {
    1: 'Cuisine française',
    2: 'Cuisine coréenne',
    3: 'Cuisine japonaise',
    4: 'Cuisine libanaise',
    5: 'Cuisine asiatique',
    6: 'Cuisine africaine',
    7: 'Boulangerie',
    8: 'Pizzeria',
    9: 'Cuisine US',
    10: 'Cuisine fusion',
    11: 'Café',
    12: 'Cuisine orientale',
    13: 'Cuisine mexicaine',
    14: 'Cuisine chinoise',
    15: 'Fast Food',
    16: 'Cuisine italienne',
    19: 'Cuisine d\'Asie Centrale',
  };

  void _showAddRestaurantDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    int selectedCuisine = 1; // Default cuisine selected

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter un restaurant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du restaurant',
                ),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                ),
              ),
              const SizedBox(height: 8),
              DropdownButton<int>(
                value: selectedCuisine,
                onChanged: (newValue) {
                  setState(() {
                    selectedCuisine = newValue!;
                  });
                },
                items: _cuisines.entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final String name = nameController.text.trim();
                final String address = addressController.text.trim();
                if (name.isNotEmpty && address.isNotEmpty) {
                  setState(() {
                    restaurants.add(
                      Restaurant(
                        name: name,
                        address: address,
                        imageUrl:
                            'https://via.placeholder.com/150', // Placeholder image URL
                      ),
                    );
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Ajouter à la liste'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Votre liste de recommandation'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _showAddRestaurantDialog,
              child: const Text('Ajouter'),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Nombre de cartes par ligne
          crossAxisSpacing: 8, // Espacement horizontal entre les cartes
          mainAxisSpacing: 8, // Espacement vertical entre les cartes
        ),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RestaurantDetailScreen(
                          restaurant: restaurants[index]),
                    ),
                  );
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width /
                      2.2, // Largeur de la carte
                  child: Card(
                    elevation: 4, // Élévation de la carte
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image:
                                    NetworkImage(restaurants[index].imageUrl),
                                fit: BoxFit.cover, // Remplissage de l'image
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurants[index].name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(restaurants[index].address),
                              // Commented out for simplicity
                              // Row(
                              //   children: [
                              //     const Icon(Icons.star, color: Colors.amber),
                              //     Text(restaurants[index].rating.toString()),
                              //     const SizedBox(width: 5),
                              //     Text(
                              //       '(${restaurants[index].numReviews} reviews)',
                              //       style: const TextStyle(
                              //         fontStyle: FontStyle.italic,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        restaurants.removeAt(index);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: const Icon(
                        Icons.remove_circle_rounded,
                        color: Colors.red,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
