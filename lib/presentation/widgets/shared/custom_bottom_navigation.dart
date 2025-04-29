import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constants/constants.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({super.key});

  int getCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;

    switch (location) {
      case '/home':
        return 0;
      case '/projects':
        return 1;
      case '/articles':
        return 2;
      case '/perfil':
        return 3;
      default:
        return 0;
    }
  }

  void onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/projects');
        break;
      case 2:
        context.go('/articles');
        break;
      case 3:
        context.go('/perfil');
        break;
    }
  }

  BottomNavigationBarItem buildBottomNavigationBarItem(
      {required IconData icon, required String label, required bool isSelected}) {
    return BottomNavigationBarItem(
      backgroundColor: AppColors.white,
      icon: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: isSelected ? AppColors.yellowMetraShop : Colors.black,
          size: isSelected ? 30 : 26,
        ),
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = getCurrentIndex(context);

    return BottomNavigationBar(
        elevation: 1,
        backgroundColor: AppColors.white,
        currentIndex: currentIndex,
      selectedLabelStyle: const TextStyle(
        color: AppColors.blueMetraShop,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(
        color: AppColors.primaryMetraShop,
        fontWeight: FontWeight.bold,
      ),
      showUnselectedLabels: true,
        selectedItemColor: AppColors.blueMetraShop,
        unselectedItemColor: AppColors.primaryMetraShop,
        selectedIconTheme: const IconThemeData(size: 30),
        unselectedIconTheme: const IconThemeData(size: 26),
        onTap: (value) => onItemTapped(context, value),

        items: [
          buildBottomNavigationBarItem(
            icon: Icons.home_rounded,
            label: 'Inicio',
            isSelected: currentIndex == 0,
          ),
          buildBottomNavigationBarItem(
            icon: Icons.archive_rounded,
            label: 'Proyectos',
            isSelected: currentIndex == 1,
          ),
          buildBottomNavigationBarItem(
            icon: Icons.article_rounded,
            label: 'Articulos',
            isSelected: currentIndex == 2,
          ),
          buildBottomNavigationBarItem(
            icon: Icons.person_rounded,
            label: 'Mi perfil',
            isSelected: currentIndex == 3,
          ),
        ],
    );
  }
}
