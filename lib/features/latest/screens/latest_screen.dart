import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../explore/screens/sighting_detail_screen.dart';

class LatestScreen extends StatefulWidget {
  const LatestScreen({super.key});

  static String? _pendingCreatureFilter;

  static void setCreatureFilter(String? filter) {
    _pendingCreatureFilter = filter;
  }

  @override
  State<LatestScreen> createState() => _LatestScreenState();
}

class _LatestScreenState extends State<LatestScreen> {
  // フィルター
  int _selectedDays = 7;
  String? _selectedRegion;
  String? _selectedAreaId;
  String? _selectedAreaName;
  String _creatureQuery = '';

  // データ
  List<Map<String, dynamic>> _sightings = [];
  List<Map<String, dynamic>> _allAreas = [];
  List<String> _regions = [];
  bool _loading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (LatestScreen._pendingCreatureFilter != null) {
      _creatureQuery = LatestScreen._pendingCreatureFilter!;
      _searchController.text = LatestScreen._pendingCreatureFilter!;
      LatestScreen._pendingCreatureFilter = null;
    }
    _loadAreas();
    _loadSightings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAreas() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('areas')
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    final areas = snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    final regions = areas.map((a) => a['region'] as String).toSet().toList();
    setState(() {
      _allAreas = areas;
      _regions = regions;
    });
  }

  Future<void> _loadSightings() async {
    setState(() => _loading = true);

    final snapshot = await FirebaseFirestore.instance
        .collection('sightings')
        .orderBy('createdAt', descending: true)
        .get();

    List<Map<String, dynamic>> sightings = snapshot.docs
        .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
        .toList();

    // 期間フィルター
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

  List<Map<String, dynamic>> get _filtered {
    return _sightings.where((s) {
      // エリアフィルター
      if (_selectedAreaId != null) {
        if (s['areaId'] != _selectedAreaId) return false;
      } else if (_selectedRegion != null) {
        final area = _allAreas.firstWhere(
          (a) => a['id'] == s['areaId'],
          orElse: () => {},
        );
        if (area.isEmpty || area['region'] != _selectedRegion) return false;
      }

      // 生物名フィルター
      if (_creatureQuery.isNotEmpty) {
        final name = (s['creatureName'] ?? '') as String;
        if (!name.contains(_creatureQuery)) return false;
      }

      return true;
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredAreas {
    if (_selectedRegion == null) return [];
    return _allAreas.where((a) => a['region'] == _selectedRegion).toList();
  }

  String _formatDate(dynamic val) {
    if (val == null) return '';
    DateTime? date;
    if (val is String && val.isNotEmpty) {
      date = DateTime.tryParse(val);
    } else if (val is Timestamp) {
      date = val.toDate();
    }
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '最新情報',
          style: TextStyle(color: Color(0xFF0D1B2A), fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        children: [
          // フィルターエリア
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: Column(
              children: [
                // 期間・地域・エリア（横並び）
                Row(
                  children: [
                    // 期間
                    Expanded(
                      flex: 2,
                      child: _CompactDropdown(
                        hint: '期間',
                        value: _selectedDays.toString(),
                        items: const [
                          {'label': '今日', 'value': '0'},
                          {'label': '7日以内', 'value': '7'},
                          {'label': '30日以内', 'value': '30'},
                        ],
                        onChanged: (val) {
                          setState(() => _selectedDays = int.parse(val!));
                          _loadSightings();
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    // 地域
                    Expanded(
                      flex: 3,
                      child: _CompactDropdown(
                        hint: '地域',
                        value: _selectedRegion,
                        items: _regions
                            .map((r) => {'label': r, 'value': r})
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedRegion = val;
                            _selectedAreaId = null;
                            _selectedAreaName = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    // エリア
                    Expanded(
                      flex: 3,
                      child: _CompactDropdown(
                        hint: 'エリア',
                        value: _selectedAreaId,
                        items: _filteredAreas
                            .map((a) => {
                                  'label': a['nameJa'] as String,
                                  'value': a['id'] as String,
                                })
                            .toList(),
                        onChanged: _selectedRegion == null
                            ? null
                            : (val) {
                                final area = _filteredAreas
                                    .firstWhere((a) => a['id'] == val);
                                setState(() {
                                  _selectedAreaId = val;
                                  _selectedAreaName = area['nameJa'] as String;
                                });
                              },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 生物名検索
                SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                        color: Color(0xFF0D1B2A), fontSize: 13),
                    decoration: InputDecoration(
                      hintText: '生物名で絞り込む',
                      hintStyle: const TextStyle(
                          color: Color(0xFFBBBBBB), fontSize: 13),
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFF8899AA), size: 18),
                      suffixIcon: _creatureQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: Color(0xFF8899AA), size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _creatureQuery = '');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF0077B6)),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() => _creatureQuery = val);
                    },
                  ),
                ),
              ],
            ),
          ),

          // 件数表示
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Text(
                  '${_filtered.length}件',
                  style: const TextStyle(
                    color: Color(0xFF8899AA),
                    fontSize: 12,
                  ),
                ),
                if (_selectedAreaName != null) ...[
                  const Text(' · ',
                      style: TextStyle(
                          color: Color(0xFF8899AA), fontSize: 12)),
                  Text(
                    _selectedAreaName!,
                    style: const TextStyle(
                        color: Color(0xFF8899AA), fontSize: 12),
                  ),
                ],
              ],
            ),
          ),

          // リスト
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(
                        child: Text(
                          '該当する目撃情報がありません',
                          style: TextStyle(
                              color: Color(0xFF8899AA), fontSize: 15),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        itemBuilder: (context, i) {
                          final s = _filtered[i];
                          final isCrawler = s['sourceType'] == 'crawler';
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SightingDetailScreen(sighting: s),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  // バッジ
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isCrawler
                                          ? const Color(0xFFE8F4FD)
                                          : const Color(0xFFE8F8F5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isCrawler ? '🏪' : '🤿',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // 生物名・エリア
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s['creatureName'] as String? ?? '不明',
                                          style: const TextStyle(
                                            color: Color(0xFF0D1B2A),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          s['areaName'] as String? ?? '',
                                          style: const TextStyle(
                                            color: Color(0xFF8899AA),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 日付
                                  Text(
                                    _formatDate(s['createdAt']),
                                    style: const TextStyle(
                                      color: Color(0xFF8899AA),
                                      fontSize: 12,
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

class _CompactDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<Map<String, String>> items;
  final ValueChanged<String?>? onChanged;

  const _CompactDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
        color: onChanged == null ? const Color(0xFFF5F5F5) : Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 12),
          ),
          style: const TextStyle(color: Color(0xFF0D1B2A), fontSize: 12),
          dropdownColor: Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Color(0xFF8899AA), size: 16),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item['value'],
                    child: Text(
                      item['label']!,
                      style: const TextStyle(
                          color: Color(0xFF0D1B2A), fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
