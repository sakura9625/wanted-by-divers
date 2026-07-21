import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'creature_sightings_screen.dart';

class CreatureDetailScreen extends StatefulWidget {
  final String creatureId;
  final String creatureName;
  final List<String>? groupMembers;

  const CreatureDetailScreen({
    super.key,
    required this.creatureId,
    required this.creatureName,
    this.groupMembers,
  });

  @override
  State<CreatureDetailScreen> createState() => _CreatureDetailScreenState();
}

class _CreatureDetailScreenState extends State<CreatureDetailScreen> {
  int _selectedDays = 7;
  List<Map<String, dynamic>> _sightings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSightings();
  }

  Future<void> _loadSightings() async {
    setState(() => _loading = true);

    // 検索対象の生物名リスト（グループメンバーがあればそれも含める）
    final searchNames = widget.groupMembers ?? [widget.creatureName];

    List<Map<String, dynamic>> sightings = [];
    for (final name in searchNames) {
      final snapshot = await FirebaseFirestore.instance
          .collection('sightings')
          .where('creatureName', isEqualTo: name)
          .get();
      sightings.addAll(snapshot.docs.map((d) => d.data()));
    }

    // クライアント側で期間フィルター
    if (_selectedDays > 0) {
      final cutoff = DateTime.now().subtract(Duration(days: _selectedDays));
      sightings = sightings.where((s) {
        final date = (s['createdAt'] as Timestamp?)?.toDate();
        return date != null && date.isAfter(cutoff);
      }).toList();
    }

    setState(() {
      _sightings = sightings;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _aggregated {
    final Map<String, Map<String, dynamic>> map = {};

    for (final s in _sightings) {
      final areaName = (s['areaName'] ?? '') as String;
      if (areaName.isEmpty) continue;

      DateTime date;
      if (s['date'] is String && (s['date'] as String).isNotEmpty) {
        date = DateTime.tryParse(s['date'] as String) ?? DateTime.now();
      } else if (s['date'] is Timestamp) {
        date = (s['date'] as Timestamp).toDate();
      } else {
        date = (s['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      }

      if (map.containsKey(areaName)) {
        map[areaName]!['count'] = (map[areaName]!['count'] as int) + 1;
        final existing = map[areaName]!['lastSeen'] as DateTime;
        if (date.isAfter(existing)) map[areaName]!['lastSeen'] = date;
        final areaId = s['areaId'];
        if (areaId != null) map[areaName]!['areaId'] = areaId;
      } else {
        map[areaName] = {
          'areaName': areaName,
          'areaId': s['areaId'] ?? '',
          'count': 1,
          'lastSeen': date,
        };
      }
    }

    final list = map.values.toList();
    list.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    return list;
  }

  String _formatLastSeen(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.creatureName,
          style: const TextStyle(
              color: Color(0xFF0D1B2A), fontWeight: FontWeight.w500),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0D1B2A)),
      ),
      body: Column(
        children: [
          // 期間フィルター
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: Row(
              children: [
                _PeriodChip(
                    label: '7日以内',
                    selected: _selectedDays == 7,
                    onTap: () {
                      setState(() => _selectedDays = 7);
                      _loadSightings();
                    }),
                const SizedBox(width: 8),
                _PeriodChip(
                    label: '30日以内',
                    selected: _selectedDays == 30,
                    onTap: () {
                      setState(() => _selectedDays = 30);
                      _loadSightings();
                    }),
                const SizedBox(width: 8),
                _PeriodChip(
                    label: '全期間',
                    selected: _selectedDays == 0,
                    onTap: () {
                      setState(() => _selectedDays = 0);
                      _loadSightings();
                    }),
              ],
            ),
          ),

          // エリア一覧
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _aggregated.isEmpty
                    ? const Center(
                        child: Text(
                          'この期間の目撃情報はありません',
                          style: TextStyle(
                              color: Color(0xFF8899AA), fontSize: 15),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _aggregated.length,
                        itemBuilder: (context, i) {
                          final item = _aggregated[i];
                          final isEven = i % 2 == 0;
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CreatureSightingsScreen(
                                    creatureName: widget.creatureName,
                                    areaName: item['areaName'] as String,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              color: isEven
                                  ? Colors.white
                                  : const Color(0xFFE8F8F5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['areaName'] as String,
                                      style: const TextStyle(
                                        color: Color(0xFF0D1B2A),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '最新: ${_formatLastSeen(item['lastSeen'] as DateTime)}',
                                    style: const TextStyle(
                                      color: Color(0xFF0D1B2A),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${item['count']}件',
                                    style: const TextStyle(
                                      color: Color(0xFF8899AA),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF26C6A6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF26C6A6)
                : const Color(0xFFD0E0E0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF5A7A9A),
            fontSize: 13,
            fontWeight:
                selected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
