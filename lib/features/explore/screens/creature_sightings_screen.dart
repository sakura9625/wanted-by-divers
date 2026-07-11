import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class CreatureSightingsScreen extends StatefulWidget {
  final String creatureName;
  final String areaName;

  const CreatureSightingsScreen({
    super.key,
    required this.creatureName,
    required this.areaName,
  });

  @override
  State<CreatureSightingsScreen> createState() => _CreatureSightingsScreenState();
}

class _CreatureSightingsScreenState extends State<CreatureSightingsScreen> {
  List<Map<String, dynamic>> _sightings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 目撃情報を取得
    final snapshot = await FirebaseFirestore.instance
        .collection('sightings')
        .where('creatureName', isEqualTo: widget.creatureName)
        .where('areaName', isEqualTo: widget.areaName)
        .get();

    final sightings = snapshot.docs
        .map((d) => d.data())
        .toList();

    // 最新順に並び替え
    sightings.sort((a, b) {
      final aDate = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
      final bDate = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    setState(() {
      _sightings = sightings;
      _loading = false;
    });
  }

  String _formatDate(dynamic date) {
    if (date == null) return '不明';
    if (date is String) return date;
    if (date is Timestamp) {
      final d = date.toDate();
      return '${d.year}/${d.month.toString().padLeft(2,'0')}/${d.day.toString().padLeft(2,'0')}';
    }
    return '不明';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.creatureName,
              style: const TextStyle(
                color: Color(0xFF0D1B2A),
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            Text(
              widget.areaName,
              style: const TextStyle(
                color: Color(0xFF8899AA),
                fontSize: 13,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0D1B2A)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sightings.isEmpty
              ? const Center(
                  child: Text(
                    '目撃情報がありません',
                    style: TextStyle(color: Color(0xFF8899AA), fontSize: 15),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _sightings.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  itemBuilder: (context, i) {
                    final s = _sightings[i];
                    final isCrawler = s['sourceType'] == 'crawler';
                    final shopName = isCrawler
                        ? (s['shopName'] as String? ?? 'ショップ情報')
                        : null;

                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // バッジ
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCrawler
                                  ? const Color(0xFFE8F4FD)
                                  : const Color(0xFFE8F8F5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isCrawler ? '🏪 ${shopName ?? "ショップ情報"}' : '🤿 ダイバー投稿',
                              style: TextStyle(
                                color: isCrawler
                                    ? const Color(0xFF0077B6)
                                    : const Color(0xFF26C6A6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 日付・ポイント
                          Row(
                            children: [
                              Text(
                                _formatDate(s['date'] ?? s['createdAt']),
                                style: const TextStyle(
                                  color: Color(0xFF0D1B2A),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (s['pointName'] != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  s['pointName'] as String,
                                  style: const TextStyle(
                                    color: Color(0xFF5A7A9A),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          // 水温・透明度
                          if (isCrawler && (s['waterTemp'] != null || s['visibility'] != null)) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                if (s['waterTemp'] != null)
                                  Text(
                                    '水温 ${s['waterTemp']}',
                                    style: const TextStyle(
                                      color: Color(0xFF8899AA),
                                      fontSize: 13,
                                    ),
                                  ),
                                if (s['waterTemp'] != null && s['visibility'] != null)
                                  const Text('　', style: TextStyle(fontSize: 13)),
                                if (s['visibility'] != null)
                                  Text(
                                    '透明度 ${s['visibility']}',
                                    style: const TextStyle(
                                      color: Color(0xFF8899AA),
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            ),
                          ],

                          // 記事URL
                          if (isCrawler && s['articleUrl'] != null) ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final url = Uri.parse(s['articleUrl'] as String);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                }
                              },
                              child: const Text(
                                '記事を見る →',
                                style: TextStyle(
                                  color: Color(0xFF0077B6),
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
