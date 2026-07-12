import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class SightingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> sighting;

  const SightingDetailScreen({super.key, required this.sighting});

  @override
  State<SightingDetailScreen> createState() => _SightingDetailScreenState();
}

class _SightingDetailScreenState extends State<SightingDetailScreen> {
  @override
  void initState() {
    super.initState();
    _incrementViewCount();
  }

  Future<void> _incrementViewCount() async {
    // sightingのドキュメントIDが必要なので、
    // sightingにidフィールドを追加して渡す形にする
    final docId = widget.sighting['id'] as String?;
    if (docId == null || docId.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('sightings')
        .doc(docId)
        .update({
      'viewCount': FieldValue.increment(1),
    });
  }

  String _formatDate(dynamic val) {
    if (val == null) return '不明';
    if (val is String) return val;
    if (val is Timestamp) {
      final d = val.toDate();
      return '${d.year}年${d.month}月${d.day}日';
    }
    return '不明';
  }

  @override
  Widget build(BuildContext context) {
    final sighting = widget.sighting;
    final isCrawler = sighting['sourceType'] == 'crawler';
    final shopName = sighting['shopName'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sighting['creatureName'] as String? ?? '不明',
              style: const TextStyle(
                color: Color(0xFF0D1B2A),
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            if (sighting['areaName'] != null)
              Text(
                sighting['areaName'] as String,
                style: const TextStyle(
                  color: Color(0xFF8899AA),
                  fontSize: 13,
                ),
              ),
          ],
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0D1B2A)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // バッジ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isCrawler
                    ? const Color(0xFFE8F4FD)
                    : const Color(0xFFE8F8F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isCrawler
                    ? '🏪 ${shopName ?? "ショップ情報"}'
                    : '🤿 ダイバー投稿',
                style: TextStyle(
                  color: isCrawler
                      ? const Color(0xFF0077B6)
                      : const Color(0xFF26C6A6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 情報リスト
            _InfoRow(
              label: '日付',
              value: _formatDate(sighting['date'] ?? sighting['createdAt']),
            ),
            if (sighting['areaName'] != null)
              _InfoRow(
                label: 'エリア',
                value: sighting['areaName'] as String,
              ),
            if (sighting['pointName'] != null)
              _InfoRow(
                label: 'ポイント',
                value: sighting['pointName'] as String,
              ),
            if (sighting['waterTemp'] != null)
              _InfoRow(
                label: '水温',
                value: sighting['waterTemp'] as String,
              ),
            if (sighting['visibility'] != null)
              _InfoRow(
                label: '透明度',
                value: sighting['visibility'] as String,
              ),
            if (isCrawler && sighting['shopName'] != null)
              _InfoRow(
                label: '出典',
                value: sighting['shopName'] as String,
              ),

            // 記事リンク
            if (isCrawler && sighting['articleUrl'] != null) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () async {
                  final url = Uri.parse(sighting['articleUrl'] as String);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.open_in_new,
                          color: Color(0xFF0077B6), size: 18),
                      SizedBox(width: 8),
                      Text(
                        '記事を見る',
                        style: TextStyle(
                          color: Color(0xFF0077B6),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8899AA),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0D1B2A),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
