import 'package:flutter/material.dart';
import 'package:yumpro/models/invitation.dart';
import 'package:yumpro/models/restaurant.dart';

//onsulter la liste des invitations
class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({super.key});

  @override
  _InvitationsScreenState createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  // Liste des invitations
  List<Invitation> invitations = [
    Invitation(
        restaurant: Restaurant(
            name: 'Restaurant A',
            address: '123 Rue de la Paix',
            imageUrl: 'url_de_l_image'),
        isRead: true),
    Invitation(
        restaurant: Restaurant(
            name: 'Restaurant B',
            address: '456 Avenue des Champs-Élysées',
            imageUrl: 'url_de_l_image'),
        isRead: false),
    Invitation(
        restaurant: Restaurant(
            name: 'Restaurant C',
            address: '789 Boulevard Saint-Michel',
            imageUrl: 'url_de_l_image'),
        isRead: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitations'),
      ),
      body: ListView.builder(
        itemCount: invitations.length,
        itemBuilder: (context, index) {
          final invitation = invitations[index];
          return ListTile(
            title: Text(
              invitation.isRead
                  ? invitation.restaurant.name
                  : '${invitation.restaurant.name} vous invite à manger',
              style: TextStyle(
                fontWeight:
                    invitation.isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            onTap: () {
              setState(() {
                // Mettre à jour le statut de l'invitation
                invitations[index].isRead = true;
              });
            },
          );
        },
      ),
    );
  }
}
