class Restaurant {
  final int id;
  final String name;
  final String address;
  final double rating;
  final int numReviews;
  final String imageUrl;
  final String place_id;
  final List<String> videoLinks;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    this.rating = 5,
    this.numReviews = 0,
    required this.place_id,
    required this.videoLinks,
  });

  // Méthode factory pour créer une instance de Restaurant à partir d'un objet JSON
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      place_id: json['placeId'],
      address: json['address_str'],
      imageUrl: json['picture_profile'] ?? 'https://via.placeholder.com/150',
      rating: json['ratings'] != null
          ? double.parse(json['ratings'].toString())
          : 5,
      numReviews: json['number_of_reviews'] != null
          ? int.parse(json['number_of_reviews'].toString())
          : 0,
      videoLinks: json['video_links'] != null
          ? List<String>.from(json['video_links'])
          : [],
    );
  }
}
