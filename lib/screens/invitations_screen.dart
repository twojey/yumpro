import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yumpro/models/invitation.dart';
import 'package:yumpro/services/api_service.dart';
import 'package:yumpro/utils/appcolors.dart';

class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({super.key});

  @override
  _InvitationsScreenState createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  List<Invitation> invitations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInvitations();
  }

  Future<int> _getWorkspaceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? workspaceId = prefs.getInt('workspace_id');

    if (workspaceId == null) {
      throw Exception('Workspace ID not found');
    }

    return workspaceId;
  }

  Future<void> _fetchInvitations() async {
    setState(() {
      isLoading = true;
    });

    try {
      int workspaceId = await _getWorkspaceId();
      List<dynamic> data =
          await ApiService().getWorkspaceInvitations(workspaceId);

      setState(() {
        invitations = data.map((json) => Invitation.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Erreur lors du chargement des invitations: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitations'),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ))
          : invitations.isEmpty
              ? const Center(
                  child: Text(
                    'Aucune invitation disponible',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: invitations.length,
                  itemBuilder: (context, index) {
                    final invitation = invitations[index];
                    return ListTile(
                      title: Text(
                        invitation.isRead
                            ? invitation.restaurant.name
                            : '${invitation.restaurant.name} vous invite à manger',
                        style: TextStyle(
                          fontWeight: invitation.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          invitations[index].isRead = true;
                        });
                        Navigator.pushNamed(
                          context,
                          '/invitation-details',
                          arguments: invitation,
                        );
                      },
                    );
                  },
                ),
    );
  }
}
