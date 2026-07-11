import 'package:flutter/material.dart';
import '../../post/screens/post_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              const SizedBox(height: 16),
              const Center(
                child: Column(
                  children: [
                    Text(
                      '目撃情報アプリ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Wanted by Divers',
                      style: TextStyle(
                        color: Color(0xFF8899AA),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ここで見た！カード
              _HomeCard(
                color: const Color(0xFF29B6F6),
                icon: Icons.camera_alt,
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
              const SizedBox(height: 16),

              // どこで見た？カード
              _HomeCard(
                color: const Color(0xFF26C6A6),
                icon: Icons.location_on,
                title: 'どこで見た？',
                subtitle: '見たい生物や場所の目撃情報を探そう',
                buttonIcon: Icons.search,
                buttonLabel: '目撃場所を検索する',
                footerText: 'エリアやポイントから探せます',
                onTap: () {
                  // TODO: エリア検索画面へ
                },
              ),
              const SizedBox(height: 16),

              // 何を見た？カード
              _HomeCard(
                color: const Color(0xFFFFB300),
                icon: Icons.set_meal,
                title: '何を見た？',
                subtitle: '生物の目撃情報を詳しく調べよう',
                buttonIcon: Icons.set_meal,
                buttonLabel: '目撃生物を検索する',
                footerText: '生物の分布や季節情報も確認できます',
                onTap: () {
                  // TODO: 生物検索画面へ
                },
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
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(buttonIcon, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white70),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              footerText,
              style: TextStyle(
                color: color,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
