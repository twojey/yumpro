import 'package:flutter/material.dart';
import 'package:yumpro/models/user.dart';
import 'package:yumpro/widgets/modal_invite_user.dart';
import 'package:yumpro/services/auth_service.dart';
import 'package:yumpro/services/api_service.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  _WorkspaceScreenState createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  late List<User> users = [];

  @override
  void initState() {
    super.initState();
    _fetchWorkspaceTeam();
  }

  Future<void> _fetchWorkspaceTeam() async {
    try {
      final userInfo = await _authService.getUserInfo();
      final workspaceId = userInfo['workspace_id'] ?? 1;
      final List<dynamic> team = await _apiService
          .getWorkspaceTeam(workspaceId); // Utilisez List<dynamic>
      setState(() {
        users = team.map((userData) => User.fromJson(userData)).toList();
      });
    } catch (e) {
      print('Error fetching workspace team: $e');
      // Gérer l'erreur si nécessaire
    }
  }

  void _inviteUser(String email) {
    // Add your logic to handle email invitation here
    print('Invitation sent to $email');
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
              child: const Text("Invite to Team"),
            ),
          ),
        ],
      ),
      body: users.isNotEmpty
          ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
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
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else
                                Text(user.roleInWorkspace),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
