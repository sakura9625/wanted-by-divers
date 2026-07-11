import 'package:flutter/material.dart';
import '../../post/screens/post_screen.dart';
import '../../explore/screens/area_search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Stack(
                children: [
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'WANTED',
                          style: TextStyle(
                            color: Color(0xFF0D1B2A),
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 6,
                          ),
                        ),
                        SizedBox(height: 4),
                        Divider(color: Color(0xFF0D1B2A), thickness: 2, height: 2),
                        SizedBox(height: 3),
                        Text(
                          'by Divers',
                          style: TextStyle(
                            color: Color(0xFF0D1B2A),
                            fontSize: 13,
                            letterSpacing: 3,
                          ),
                        ),
                        SizedBox(height: 3),
                        Divider(color: Color(0xFF0D1B2A), thickness: 2, height: 2),
                        SizedBox(height: 8),
                        Text(
                          'ダイビング生物目撃情報アプリ',
                          style: TextStyle(
                            color: Color(0xFF8899AA),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF8899AA),
                      size: 26,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              _HomeCard(
                color: const Color(0xFF29B6F6),
                icon: Icons.camera_alt_outlined,
                title: 'ここで見た！',
                subtitle: '見た生物を記録してみんなと共有しよう',
                buttonIcon: Icons.edit_note,
                buttonLabel: '目撃情報を報告する',
                footerText: '生物・エリア・日付を記録できます',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PostScreen()),
                  );
                },
              ),
              const SizedBox(height: 14),

              _HomeCard(
                color: const Color(0xFF26C6A6),
                icon: Icons.location_on_outlined,
                title: 'どこで見た？',
                subtitle: '見たい生物や場所の目撃情報を探そう',
                buttonIcon: Icons.search,
                buttonLabel: '目撃場所を検索する',
                footerText: 'エリアやポイントから探せます',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AreaSearchScreen()),
                  );
                },
              ),
              const SizedBox(height: 14),

              _HomeCard(
                color: const Color(0xFFFFB300),
                icon: Icons.set_meal_outlined,
                title: '何を見た？',
                subtitle: '生物の目撃情報を詳しく調べよう',
                buttonIcon: Icons.set_meal,
                buttonLabel: '目撃生物を検索する',
                footerText: '生物の分布や季節情報も確認できます',
                onTap: () {},
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final IconData buttonIcon;
  final String buttonLabel;
  final String footerText;
  final VoidCallback onTap;

  const _HomeCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonIcon,
    required this.buttonLabel,
    required this.footerText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    offset: const Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(buttonIcon, color: color, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(
                        color: Color(0xFF0D1B2A),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF8899AA), size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              footerText,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
