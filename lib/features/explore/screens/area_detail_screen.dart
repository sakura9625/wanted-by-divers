import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'creature_sightings_screen.dart';

class AreaDetailScreen extends StatefulWidget {
  final String areaId;
  final String areaName;

  const AreaDetailScreen({
    super.key,
    required this.areaId,
    required this.areaName,
  });

  @override
  State<AreaDetailScreen> createState() => _AreaDetailScreenState();
}

class _AreaDetailScreenState extends State<AreaDetailScreen> {
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

    final snapshot = await FirebaseFirestore.instance
        .collection('sightings')
        .where('areaName', isEqualTo: widget.areaName)
        .get();

    var docs = snapshot.docs.map((d) => d.data() as Map<String, dynamic>).toList();

    if (_selectedDays > 0) {
      final cutoff = DateTime.now().subtract(Duration(days: _selectedDays));
      docs = docs.where((s) {
        final date = (s['createdAt'] as Timestamp?)?.toDate();
        return date != null && date.isAfter(cutoff);
      }).toList();
    }

    setState(() {
      _sightings = docs;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _aggregated {
    final Map<String, Map<String, dynamic>> map = {};

    for (final s in _sightings) {
      final name = (s['creatureName'] ?? '') as String;
      if (name.isEmpty) continue;

      final date = (s['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

      if (map.containsKey(name)) {
        map[name]!['count'] = (map[name]!['count'] as int) + 1;
        final existing = map[name]!['lastSeen'] as DateTime;
        if (date.isAfter(existing)) map[name]!['lastSeen'] = date;
      } else {
        map[name] = {'name': name, 'count': 1, 'lastSeen': date};
      }
    }

    final list = map.values.toList();
    list.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    return list;
  }

  String _daysAgo(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return '今日';
    if (diff == 1) return '1日前';
    return '$diff日前';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.areaName,
          style: const TextStyle(
            color: Color(0xFF0D1B2A),
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0D1B2A)),
      ),
      body: Column(
        children: [
          // 期間フィルター
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: Row(
              children: [
                _PeriodChip(label: '7日以内', selected: _selectedDays == 7, onTap: () {
                  setState(() => _selectedDays = 7);
                  _loadSightings();
                }),
                const SizedBox(width: 8),
                _PeriodChip(label: '30日以内', selected: _selectedDays == 30, onTap: () {
                  setState(() => _selectedDays = 30);
                  _loadSightings();
                }),
                const SizedBox(width: 8),
                _PeriodChip(label: '全期間', selected: _selectedDays == 0, onTap: () {
                  setState(() => _selectedDays = 0);
                  _loadSightings();
                }),
              ],
            ),
          ),

          // 目撃生物一覧
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _aggregated.isEmpty
                    ? const Center(
                        child: Text(
                          'この期間の目撃情報はありません',
                          style: TextStyle(color: Color(0xFF8899AA), fontSize: 15),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: _aggregated.length,
                        separatorBuilder: (_, __) => const SizedBox.shrink(),
                        itemBuilder: (context, i) {
                          final item = _aggregated[i];
                          final isEven = i % 2 == 0;
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CreatureSightingsScreen(
                                    creatureName: item['name'] as String,
                                    areaName: widget.areaName,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              color: isEven ? Colors.white : const Color(0xFFE8F8F5),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['name'] as String,
                                      style: const TextStyle(
                                        color: Color(0xFF0D1B2A),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '最終: ${_daysAgo(item['lastSeen'] as DateTime)}',
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

  const _PeriodChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF26C6A6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF26C6A6) : const Color(0xFFD0E0E0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF5A7A9A),
            fontSize: 13,
            fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
