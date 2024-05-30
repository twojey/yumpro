import 'package:flutter/material.dart';
import 'package:yumpro/screens/restaurants_screen.dart';
import 'package:yumpro/screens/qr_code_screen.dart';
import 'package:yumpro/screens/workspace_screen.dart';
import 'package:yumpro/screens/settings_screen.dart';
import 'package:yumpro/screens/invitations_screen.dart';
import 'package:yumpro/models/user.dart';
import 'package:yumpro/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Indice de l'écran sélectionné

  late User currentUser; // Utilisation de late pour une initialisation tardive
  late List<Widget> _screens;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final authService = AuthService();
    final userInfo = await authService.getUserInfo();
    String w_id = userInfo['workspace_place_id'];
    int u_id = userInfo['user_id'];

    setState(() {
      currentUser = User(
        firstName: userInfo['first_name'] ?? 'First Name',
        lastName: userInfo['name'] ?? 'Last Name',
        workspace: userInfo['workspace_id']?.toString() ?? 'Workspace',
        roleInWorkspace:
            "employé", // Remplacez par la valeur correcte si nécessaire
        numComments: 15, // Remplacez par la valeur correcte si nécessaire
        photoUrl:
            'https://yummaptest2.s3.eu-north-1.amazonaws.com/$w_id/$u_id/profile.jpg',
      );
      _screens = [
        const RestaurantScreen(),
        const InvitationsScreen(),
        WorkspaceScreen(),
        const QRCodeScreen(),
        SettingsScreen(), // Passez currentUser à SettingsScreen
      ];
      isLoading = false;
    });
  }

  Future<void> _updateUserInfo() async {
    final authService = AuthService();
    final userInfo = await authService.getUserInfo();
    String w_id = userInfo['workspace_place_id'];
    int u_id = userInfo['user_id'];

    setState(() {
      currentUser = User(
        firstName: userInfo['first_name'] ?? 'First Name',
        lastName: userInfo['name'] ?? 'Last Name',
        workspace: userInfo['workspace_id']?.toString() ?? 'Workspace',
        roleInWorkspace:
            "employé", // Remplacez par la valeur correcte si nécessaire
        numComments: 15, // Remplacez par la valeur correcte si nécessaire
        photoUrl:
            'https://yummaptest2.s3.eu-north-1.amazonaws.com/$w_id/$u_id/profile.jpg',
      );
    });
  }

  // Méthode pour changer l'écran sélectionné
  void _selectScreen(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 4) {
        // Assurez-vous que l'index de SettingsScreen est 4
        _updateUserInfo();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.restaurant),
                label: Text('Restaurants'),
              ),
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
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              if (index < _screens.length) {
                _selectScreen(index);
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
