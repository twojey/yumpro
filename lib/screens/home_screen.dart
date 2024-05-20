import 'package:flutter/material.dart';
import 'package:yumpro/screens/restaurants_screen.dart';
import 'package:yumpro/screens/qr_code_screen.dart';
import 'package:yumpro/screens/workspace_screen.dart';
import 'package:yumpro/screens/settings_screen.dart';
import 'package:yumpro/screens/invitations_screen.dart';
import 'package:yumpro/screens/test_screen.dart'; // Import du test_screen.dart
import 'package:yumpro/models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Indice de l'écran sélectionné

  late User currentUser; // Utilisation de late pour une initialisation tardive

  // Liste des écrans
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialisation de currentUser
    currentUser = User(
      firstName: 'John',
      lastName: 'Doe',
      workspace: 'Workspace A',
      roleInWorkspace: "employé",
      numComments: 15,
      photoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
    );
    // Initialisation de la liste des écrans
    _screens = [
      const RestaurantScreen(),
      const InvitationsScreen(),
      WorkspaceScreen(),
      const QRCodeScreen(),
      SettingsScreen(
          user: currentUser), // Ajoutez d'autres écrans ici si nécessaire
    ];
  }

  // Méthode pour changer l'écran sélectionné
  void _selectScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.restaurant),
                label: Text('Restaurants'),
              ),
              // Nouvelle destination avec l'icône de message
              NavigationRailDestination(
                icon: Icon(Icons.mail_rounded),
                label: Text('Messages'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_add),
                label: Text('Invitations'),
              ),

              NavigationRailDestination(
                icon: Icon(Icons.qr_code),
                label: Text('QR Code'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Paramètres'),
              ),
              // Ajout du bouton TestScreen après le bouton Paramètres
              NavigationRailDestination(
                icon: Icon(Icons.send),
                label: Text('Test'),
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              if (index < _screens.length) {
                _selectScreen(index);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TestScreen()), // Redirection vers TestScreen
                );
              }
            },
            selectedIconTheme: const IconThemeData(
                color: Colors.blue), // Couleur de l'icône sélectionnée
            selectedLabelTextStyle: const TextStyle(
                color: Colors.blue), // Couleur de l'étiquette sélectionnée
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _screens[_selectedIndex], // Affiche l'écran sélectionné
          ),
        ],
      ),
    );
  }
}
