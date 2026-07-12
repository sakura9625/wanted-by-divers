import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SpecialThanksScreen extends StatefulWidget {
  const SpecialThanksScreen({super.key});

  @override
  State<SpecialThanksScreen> createState() => _SpecialThanksScreenState();
}

class _SpecialThanksScreenState extends State<SpecialThanksScreen> {
  Map<String, List<String>> _groupedSources = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSources();
  }

  Future<void> _loadSources() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('sources')
          .get();

      // エリアごとにグルーピング
      final Map<String, List<String>> grouped = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final area = data['area'] as String? ?? 'その他';
        final shopName = data['shopName'] as String? ?? '';
        if (shopName.isEmpty) continue;
        grouped.putIfAbsent(area, () => []).add(shopName);
      }

      setState(() {
        _groupedSources = grouped;
        _loading = false;
      });
    } catch (e) {
      print('[SpecialThanks] error: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Special Thanks',
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : _groupedSources.isEmpty
              ? const Center(
                  child: Text(
                    'データがありません',
                    style: TextStyle(color: Color(0xFF888888)),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 32),
                  children: _groupedSources.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        children: [
                          // エリア名
                          Text(
                            entry.key,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 13,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 区切り線
                          const Divider(
                              color: Color(0xFF444444), thickness: 1),
                          const SizedBox(height: 12),
                          // ショップ名一覧
                          ...entry.value.map((shopName) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  shopName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    );
                  }).toList(),
                ),
    );
  }
}
