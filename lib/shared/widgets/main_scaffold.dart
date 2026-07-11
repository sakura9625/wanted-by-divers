import 'package:flutter/material.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/latest/screens/latest_screen.dart';
import '../../features/wanted/screens/wanted_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

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
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF0D1B2A), width: 2),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0077B6),
          unselectedItemColor: const Color(0xFF8899AA),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
            BottomNavigationBarItem(icon: Icon(Icons.access_time), label: '最新情報'),
            BottomNavigationBarItem(icon: Icon(Icons.star_border), label: '見たいリスト'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'マイページ'),
          ],
        ),
      ),
    );
  }
}
