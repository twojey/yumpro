import 'package:flutter/material.dart';
import 'package:yumpro/models/user.dart';
import 'package:yumpro/models/workspace.dart';
import 'package:yumpro/widgets/modal_invite_user.dart'; // Import correct

class WorkspaceScreen extends StatelessWidget {
  final Workspace workspace = Workspace(
    users: [
      User(
        firstName: 'John',
        lastName: 'Doe',
        workspace: "workspace",
        roleInWorkspace: "Admin",
        numComments: 15,
        photoUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
      ),
      User(
        firstName: 'Jane',
        lastName: 'Smith',
        workspace: "workspace",
        roleInWorkspace: "Employé",
        numComments: 25,
        photoUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
      ),
      User(
        firstName: 'Alice',
        lastName: 'Johnson',
        workspace: "workspace",
        roleInWorkspace: "Employé",
        numComments: 30,
        photoUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
      ),
    ],
  );

  WorkspaceScreen({super.key});

  void _inviteUser(String email) {
    // Ajoutez votre logique pour traiter l'invitation par email ici
    print('Invitation envoyée à $email');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return InviteUserModal(onInvite: _inviteUser);
                  },
                );
              },
              child: const Text("Inviter dans l'équipe"),
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
        itemCount: workspace.users.length,
        itemBuilder: (context, index) {
          final user = workspace.users[index];
          return SizedBox(
            width: MediaQuery.of(context).size.width / 2.2,
            child: Card(
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(user.photoUrl),
                          fit: BoxFit.cover,
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
                          '${user.firstName} ${user.lastName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (user.roleInWorkspace == "Admin")
                          const Text(
                            'Admin',
                            style: TextStyle(
                              color:
                                  Colors.red, // Style spécial pour les admins
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          Text(
                            user.roleInWorkspace,
                          ),
                        Row(
                          children: [
                            const Icon(Icons.comment, color: Colors.blue),
                            const SizedBox(width: 10),
                            Text(user.numComments.toString()),
                            const SizedBox(width: 5),
                            const Text(
                              'comments',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
