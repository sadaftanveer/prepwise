import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_enums.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/questions/screens/categories_screen.dart';
import '../../features/questions/screens/home_screen.dart';
import '../../features/resources/screens/resources_screen.dart';
import '../../features/stats/screens/stats_screen.dart';
import '../providers/app_navigation_provider.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final AppNavigationProvider nav = context.watch<AppNavigationProvider>();

    final List<Widget> pages = <Widget>[
      const HomeScreen(),
      const CategoriesScreen(),
      const ResourcesScreen(),
      const StatsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[nav.currentTab.index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: nav.currentTab.index,
        onDestinationSelected: (int index) {
          context.read<AppNavigationProvider>().setTab(AppTab.values[index]);
        },
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'Categories'),
          NavigationDestination(icon: Icon(Icons.bookmarks_outlined), label: 'Resources'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
