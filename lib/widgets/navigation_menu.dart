import 'package:flutter/material.dart';
import 'package:yumpro/utils/appcolors.dart';

class NavigationMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const NavigationMenu({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  Widget _buildIcon(IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Icon(
        icon,
        color: isSelected
            ? AppColors.primaryGold
            : AppColors.secondaryBlack, // Couleur des icônes
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      //backgroundColor: AppColors.textBlack,
      indicatorColor: AppColors.secondaryBlack,
      destinations: [
        NavigationRailDestination(
          icon: _buildIcon(Icons.restaurant, selectedIndex == 0),
          label: const Text('Restaurants'),
        ),
        NavigationRailDestination(
          icon: _buildIcon(Icons.mail_rounded, selectedIndex == 1),
          label: const Text('Messages'),
        ),
        NavigationRailDestination(
          icon: _buildIcon(Icons.person_add, selectedIndex == 2),
          label: const Text('Invitations'),
        ),
        NavigationRailDestination(
          icon: _buildIcon(Icons.qr_code, selectedIndex == 3),
          label: const Text('QR Code'),
        ),
        NavigationRailDestination(
          icon: _buildIcon(Icons.settings, selectedIndex == 4),
          label: const Text('Paramètres'),
        ),
      ],
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      selectedIconTheme: const IconThemeData(color: AppColors.darkAccent),
      selectedLabelTextStyle: const TextStyle(color: AppColors.accent),
    );
  }
}
