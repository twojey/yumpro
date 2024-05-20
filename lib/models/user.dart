class User {
  final String firstName;
  final String lastName;
  final String workspace;
  final String roleInWorkspace;
  final int numComments;
  final String photoUrl;

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
}
