import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/constants.dart';

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({super.key});

  int getCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;

    switch (location) {
      case '/home':
        return 0;
      case '/projects':
        return 1;
      case '/mapa':
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
        context.go('/mapa');
        break;
      case 3:
        context.go('/perfil');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        elevation: 0,
        currentIndex: getCurrentIndex(context),
        selectedItemColor: AppColors.orange,
        selectedIconTheme: const IconThemeData(size: 30),
        unselectedIconTheme: const IconThemeData(size: 26),
        onTap: (value) => onItemTapped(context, value),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded,),
              label: '',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.archive_rounded),
              label: ''
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.location_on_rounded),
              label: ''
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: ''
          )
        ]
    );
  }
}
