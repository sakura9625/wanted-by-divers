import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../explore/screens/sighting_detail_screen.dart';
import 'edit_sighting_screen.dart';
import 'special_thanks_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _uid;
  List<Map<String, dynamic>> _mySightings = [];
  List<Map<String, dynamic>> _wantedList = [];
  bool _loading = true;

  // 実績
  int _totalPosts = 0;
  int _totalSpecies = 0;
  int _totalAreas = 0;
  int _totalViews = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      final result = await FirebaseAuth.instance.signInAnonymously();
      user = result.user;
    }
    _uid = user?.uid;
    await Future.wait([_loadMySightings(), _loadWanted()]);
    setState(() => _loading = false);
  }

  Future<void> _loadMySightings() async {
    if (_uid == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('sightings')
        .where('uid', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .get();

    final sightings = snapshot.docs
        .map((d) => {'id': d.id, ...d.data()})
        .toList();

    // 実績集計
    final species = sightings
        .map((s) => s['creatureName'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .toSet();
    final areas = sightings
        .map((s) => s['areaName'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .toSet();
    final views = sightings.fold<int>(
      0,
      (sum, s) => sum + ((s['viewCount'] as int?) ?? 0),
    );

    setState(() {
      _mySightings = sightings;
      _totalPosts = sightings.length;
      _totalSpecies = species.length;
      _totalAreas = areas.length;
      _totalViews = views;
    });
  }

  Future<void> _loadWanted() async {
    if (_uid == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('wanted')
        .where('uid', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .get();
    setState(() {
      _wantedList = snapshot.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList();
    });
  }

  Future<void> _toggleNotification(String docId, bool current) async {
    await FirebaseFirestore.instance.collection('wanted').doc(docId).update({
      'notificationEnabled': !current,
    });
    await _loadWanted();
  }

  Future<void> _deleteSighting(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('投稿を削除'),
        content: const Text('この目撃情報を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('sightings')
          .doc(docId)
          .delete();
      await _loadMySightings();
    }
  }

  String _formatDate(dynamic val) {
    if (val == null) return '';
    if (val is String) return val;
    if (val is Timestamp) {
      final d = val.toDate();
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'マイページ',
          style: TextStyle(
            color: Color(0xFF0D1B2A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 投稿実績
                _SectionTitle(title: '投稿実績'),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.5,
                  children: [
                    _StatCard(label: '投稿数', value: '$_totalPosts件'),
                    _StatCard(label: '生物種数', value: '$_totalSpecies種'),
                    _StatCard(label: 'エリア数', value: '$_totalAreas ヶ所'),
                    _StatCard(label: '閲覧数', value: '$_totalViews回'),
                  ],
                ),
                const SizedBox(height: 24),

                // 自分の投稿一覧
                _SectionTitle(title: '自分の投稿'),
                const SizedBox(height: 8),
                if (_mySightings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'まだ投稿がありません',
                      style: TextStyle(color: Color(0xFF8899AA)),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < _mySightings.length; i++) ...[
                          _SightingRow(
                            sighting: _mySightings[i],
                            formatDate: _formatDate,
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SightingDetailScreen(
                                    sighting: _mySightings[i],
                                  ),
                                ),
                              );
                            },
                            onEdit: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EditSightingScreen(
                                    sighting: _mySightings[i],
                                  ),
                                ),
                              );
                              await _loadMySightings();
                            },
                            onDelete: () => _deleteSighting(
                              _mySightings[i]['id'] as String,
                            ),
                          ),
                          if (i != _mySightings.length - 1)
                            const Divider(height: 1, color: Color(0xFFE8EEF4)),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // 見たい生物一覧
                _SectionTitle(title: '見たい生物'),
                const SizedBox(height: 8),
                if (_wantedList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      '見たい生物が登録されていません',
                      style: TextStyle(color: Color(0xFF8899AA)),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < _wantedList.length; i++) ...[
                          Builder(
                            builder: (_) {
                              final w = _wantedList[i];
                              final notifEnabled =
                                  w['notificationEnabled'] as bool? ?? false;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    const Text(
                                      '🎯',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        w['creatureName'] as String? ?? '',
                                        style: const TextStyle(
                                          color: Color(0xFF0D1B2A),
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          '通知',
                                          style: TextStyle(
                                            color: Color(0xFF8899AA),
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Switch(
                                          value: notifEnabled,
                                          onChanged: (_) => _toggleNotification(
                                            w['id'] as String,
                                            notifEnabled,
                                          ),
                                          activeColor: const Color(0xFFE91E8C),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          if (i != _wantedList.length - 1)
                            const Divider(height: 1, color: Color(0xFFE8EEF4)),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 32),

                // スペシャルサンクス
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SpecialThanksScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Special Thanks',
                      style: TextStyle(
                        color: Color(0xFF8899AA),
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF0D1B2A),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8899AA), fontSize: 11),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0D1B2A),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SightingRow extends StatelessWidget {
  final Map<String, dynamic> sighting;
  final String Function(dynamic) formatDate;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SightingRow({
    required this.sighting,
    required this.formatDate,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sighting['creatureName'] as String? ?? '不明',
                    style: const TextStyle(
                      color: Color(0xFF0D1B2A),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${sighting['areaName'] ?? ''}　${formatDate(sighting['date'] ?? sighting['createdAt'])}',
                    style: const TextStyle(
                      color: Color(0xFF8899AA),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF8899AA),
                size: 20,
              ),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Color(0xFFCCCCCC),
                size: 20,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
