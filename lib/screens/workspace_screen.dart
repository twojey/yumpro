import 'package:flutter/material.dart';
import 'package:yumpro/models/user.dart';
import 'package:yumpro/utils/appcolors.dart';
import 'package:yumpro/utils/custom_widgets.dart';
import 'package:yumpro/widgets/modal_invite_user.dart';
import 'package:yumpro/services/auth_service.dart';
import 'package:yumpro/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  void _inviteUser(String email) async {
    try {
      final userInfo = await _authService.getUserInfo();
      await _apiService.sendInvitationEmail(
          userInfo['workspace_id'], userInfo['user_id'], email);
      print('Invitation envoyée à $email');
      Fluttertoast.showToast(
        msg: 'Invitation sent to $email',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      print('Error sending invitation: $e');
      Fluttertoast.showToast(
        msg: 'Error sending invitation: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      // Gérer l'erreur si nécessaire
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomWidgets.primaryButton(
                text: "Inviter dans l'équipe",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return InviteUserModal(onInvite: _inviteUser);
                    },
                  );
                },
              )
              // ElevatedButton(
              //   onPressed: () {
              //     showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return InviteUserModal(onInvite: _inviteUser);
              //       },
              //     );
              //   },
              //   child: const Text("Inviter dans l'équiper"),
              // ),
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
                                const Text("Membre"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            )),
    );
  }
}
