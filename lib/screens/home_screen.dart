import 'package:flutter/material.dart';
import 'package:yumpro/screens/invitations_screen.dart';
import 'package:yumpro/screens/qr_code_screen.dart';
import 'package:yumpro/screens/restaurants_screen.dart';
import 'package:yumpro/screens/settings_screen.dart';
import 'package:yumpro/screens/workspace_screen.dart';
import 'package:yumpro/utils/appcolors.dart';
import 'package:yumpro/widgets/navigation_menu.dart';
import 'package:yumpro/models/user.dart';
import 'package:yumpro/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late User currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final authService = AuthService();
    final userInfo = await authService.getUserInfo();
    String wId = userInfo['workspace_place_id'];
    int uId = userInfo['user_id'];

    setState(() {
      currentUser = User(
        firstName: userInfo['first_name'] ?? 'First Name',
        lastName: userInfo['name'] ?? 'Last Name',
        workspace: userInfo['workspace_id']?.toString() ?? 'Workspace',
        roleInWorkspace: "employé",
        numComments: 15,
        photoUrl:
            'https://yummaptest2.s3.eu-north-1.amazonaws.com/$wId/$uId/profile.jpg',
      );
      isLoading = false;
    });
  }

  void _selectScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
      ));
    }

    Widget currentScreen;
    switch (_selectedIndex) {
      case 0:
        currentScreen = const RestaurantScreen();
        break;
      case 1:
        currentScreen = const InvitationsScreen();
        break;
      case 2:
        currentScreen = const WorkspaceScreen();
        break;
      case 3:
        currentScreen = const QRCodeScreen();
        break;
      case 4:
        currentScreen = const SettingsScreen();
        break;
      default:
        currentScreen = const RestaurantScreen();
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationMenu(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              if (index < 5) {
                _selectScreen(index);
              }
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: currentScreen,
          ),
        ],
      ),
    );
  }
}
