import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';

class ThanksScreen extends StatelessWidget {
  final String creatureName;
  const ThanksScreen({super.key, required this.creatureName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),

            // 吹き出し
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0077B6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'ダイバーさん！\n貴重な目撃情報をありがとう！',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                  ),
                ),
              ),
            ),

            // 吹き出しの三角
            Align(
              alignment: Alignment.center,
              child: CustomPaint(
                painter: _TrianglePainter(),
                size: const Size(24, 12),
              ),
            ),

            // イルカ画像
            Expanded(
              child: Image.asset(
                'assets/images/dolphin.png',
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),

            // ボタン群
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                children: [
                  // ホームに戻る
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil(
                            (route) => route.isFirst);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0D1B2A),
                        side: const BorderSide(
                            color: Color(0xFFE0E0E0), width: 1.5),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'ホームに戻る',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 他の人の投稿を見にいく
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil(
                            (route) => route.isFirst);
                        MainScaffold.switchToLatest(creatureFilter: creatureName);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0077B6),
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '他の人の投稿を見にいく',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 過去の投稿を確認する
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil(
                            (route) => route.isFirst);
                        MainScaffold.switchToProfile();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D1B2A),
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '過去の投稿を確認する',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0077B6);
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
