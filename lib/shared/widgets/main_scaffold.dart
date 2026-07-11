import 'package:flutter/material.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/latest/screens/latest_screen.dart';
import '../../features/wanted/screens/wanted_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../core/constants/app_colors.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    LatestScreen(),
    WantedScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: '最新情報'),
          BottomNavigationBarItem(icon: Icon(Icons.star_border), label: '見たいリスト'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'マイページ'),
        ],
      ),
    );
  }
}
