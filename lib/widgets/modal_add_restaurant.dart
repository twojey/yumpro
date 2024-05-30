import 'package:flutter/material.dart';
import 'package:yumpro/models/restaurant.dart';

class AddRestaurantModal extends StatefulWidget {
  final Function(Restaurant) onAdd;

  const AddRestaurantModal({super.key, required this.onAdd});

  @override
  _AddRestaurantModalState createState() => _AddRestaurantModalState();
}

class _AddRestaurantModalState extends State<AddRestaurantModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  void _addRestaurant() {
    final String name = _nameController.text.trim();
    final String address = _addressController.text.trim();

    if (name.isNotEmpty && address.isNotEmpty) {
      final newRestaurant = Restaurant(
        id: 1,
        name: name,
        address: address,
        imageUrl: 'https://example.com/default_image.jpg',
        place_id: "",
        // rating: 0.0,
        // numReviews: 0,
      );
      widget.onAdd(newRestaurant);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajouter un restaurant',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du restaurant',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _addRestaurant,
                child: const Text('Ajouter à la liste'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
