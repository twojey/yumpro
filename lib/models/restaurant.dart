class Restaurant {
  final int id; // Ajout du champ id
  final String name;
  final String address;
  final double rating;
  final int numReviews;
  final String imageUrl;
  final String place_id;

  Restaurant({
    required this.id, // Ajout du champ id
    required this.name,
    required this.address,
    required this.imageUrl,
    this.rating = 5, // Valeur par défaut pour le rating
    this.numReviews = 0, // Valeur par défaut pour le nombre de reviews
    required this.place_id,
  });

  // Méthode factory pour créer une instance de Restaurant à partir d'un objet JSON
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'], // Extraction du champ id
      name: json['name'],
      place_id: json['placeId'],
      address: json[
          'address_str'], // Utilisation de la clé 'address_str' pour l'adresse
      imageUrl: json['picture_profile'] ?? 'https://via.placeholder.com/150',
      rating: json['ratings'] != null
          ? double.parse(json['ratings'].toString())
          : 5,
      numReviews: json['number_of_reviews'] != null
          ? int.parse(json['number_of_reviews'].toString())
          : 0,
    );
  }
}
