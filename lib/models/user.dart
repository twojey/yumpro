class User {
  String firstName;
  String lastName;
  final String workspace;
  final String roleInWorkspace;
  final int numComments;
  String photoUrl;

  User({
    required this.firstName,
    required this.lastName,
    required this.workspace,
    required this.roleInWorkspace,
    required this.numComments,
    required this.photoUrl,
  });

  User copyWith({
    String? firstName,
    String? lastName,
    String? workspace,
    String? roleInWorkspace,
    int? numComments,
    String? photoUrl,
  }) {
    return User(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      workspace: workspace ?? this.workspace,
      roleInWorkspace: roleInWorkspace ?? this.roleInWorkspace,
      numComments: numComments ?? this.numComments,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  // Setter pour le prénom (firstName)
  void setFirstName(String value) {
    firstName = value;
  }

  // Setter pour le nom de famille (lastName)
  void setLastName(String value) {
    lastName = value;
  }

  // Setter pour l'URL de la photo (photoUrl)
  void setPhotoUrl(String value) {
    photoUrl = value;
  }

  // Méthode factory pour créer une instance de User à partir d'un objet JSON
  factory User.fromJson(Map<String, dynamic> json) {
    String photoUrl = json['photo_url'];
    if (photoUrl.isEmpty) {
      photoUrl = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330';
    }
    return User(
      firstName: json['first_name'],
      lastName: json['name'],
      workspace: 'Workspace',
      roleInWorkspace: 'Role',
      numComments: 0,
      photoUrl: photoUrl,
    );
  }
}
