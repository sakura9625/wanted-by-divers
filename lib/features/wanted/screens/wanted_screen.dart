import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../explore/screens/creature_detail_screen.dart';
import '../../explore/screens/sighting_detail_screen.dart';
import '../../latest/screens/latest_screen.dart';
import '../../../shared/widgets/main_scaffold.dart';

class WantedScreen extends StatefulWidget {
  const WantedScreen({super.key});

  @override
  State<WantedScreen> createState() => _WantedScreenState();
}

class _WantedScreenState extends State<WantedScreen> {
  List<String> _wantedCreatures = [];
  Map<String, List<Map<String, dynamic>>> _sightingsMap = {};
  bool _loading = true;
  String? _uid;

  // フィルター
  int _selectedDays = 7;
  String? _selectedRegion;
  String? _selectedAreaId;
  String? _selectedAreaName;
  List<Map<String, dynamic>> _allAreas = [];
  List<String> _regions = [];

  // 生物追加用
  List<String> _allCreatureNames = [];
  final TextEditingController _addSearchController = TextEditingController();
  List<String> _addSuggestions = [];
  String _addQuery = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _addSearchController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    print('[Wanted] _init start');
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('[Wanted] signing in anonymously');
      final result = await FirebaseAuth.instance.signInAnonymously();
      user = result.user;
    }
    _uid = user?.uid;
    print('[Wanted] uid: $_uid');

    await Future.wait([_loadAreas(), _loadCreatureNames(), _loadWanted()]);
    print('[Wanted] _init complete');
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

  Future<void> _loadCreatureNames() async {
    final masterSnap = await FirebaseFirestore.instance
        .collection('creatures')
        .where('isActive', isEqualTo: true)
        .get();
    final masterNames = masterSnap.docs
        .map((d) => d.data()['nameJa'] as String)
        .toSet();

    final sightingsSnap =
        await FirebaseFirestore.instance.collection('sightings').get();
    final sightingNames = sightingsSnap.docs
        .map((d) => d.data()['creatureName'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .toSet();

    final all = {...masterNames, ...sightingNames}.toList()..sort();
    setState(() => _allCreatureNames = all);
  }

  Future<void> _loadWanted() async {
    print('[Wanted] _loadWanted start, uid: $_uid');
    if (_uid == null) {
      print('[Wanted] uid is null, skip');
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);

    final snapshot = await FirebaseFirestore.instance
        .collection('wanted')
        .where('uid', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .get();

    final creatures = snapshot.docs
        .map((d) => d.data()['creatureName'] as String)
        .toList();

    // 各生物の最新目撃情報を取得
    final sightingsMap = <String, List<Map<String, dynamic>>>{};
    for (final name in creatures) {
      final q = await _buildSightingsQuery(name).limit(3).get();
      sightingsMap[name] = q.docs
          .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
          .toList();
    }

    setState(() {
      _wantedCreatures = creatures;
      _sightingsMap = sightingsMap;
      _loading = false;
    });
    print('[Wanted] _loadWanted complete, creatures: ${creatures.length}');
  }

  Query _buildSightingsQuery(String creatureName) {
    Query query = FirebaseFirestore.instance
        .collection('sightings')
        .where('creatureName', isEqualTo: creatureName)
        .orderBy('createdAt', descending: true);

    if (_selectedAreaId != null) {
      query = FirebaseFirestore.instance
          .collection('sightings')
          .where('creatureName', isEqualTo: creatureName)
          .where('areaId', isEqualTo: _selectedAreaId)
          .orderBy('createdAt', descending: true);
    }

    return query;
  }

  Future<void> _addWanted(String name) async {
    if (_uid == null || name.isEmpty) return;

    // 重複チェック
    if (_wantedCreatures.contains(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name はすでに登録されています')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('wanted').add({
      'uid': _uid,
      'creatureName': name,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _loadWanted();
  }

  Future<void> _removeWanted(String name) async {
    if (_uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('wanted')
        .where('uid', isEqualTo: _uid)
        .where('creatureName', isEqualTo: name)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    await _loadWanted();
  }

  String _toKatakana(String text) {
    return text.replaceAllMapped(
      RegExp(r'[ぁ-ゖ]'),
      (m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) + 0x60),
    );
  }

  void _onAddQueryChanged(String val) {
    final katakana = _toKatakana(val);
    setState(() {
      _addQuery = val;
      if (val.isEmpty) {
        _addSuggestions = [];
      } else {
        _addSuggestions = _allCreatureNames
            .where((n) => n.contains(val) || n.contains(katakana))
            .take(8)
            .toList();
      }
    });
  }

  void _showAddModal() {
    _addSearchController.clear();
    setState(() {
      _addQuery = '';
      _addSuggestions = [];
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '見たい生物を追加',
                      style: TextStyle(
                        color: Color(0xFF0D1B2A),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _addSearchController,
                      autofocus: true,
                      style: const TextStyle(color: Color(0xFF0D1B2A)),
                      decoration: InputDecoration(
                        hintText: '例：まんた、ホムラハゼ',
                        hintStyle:
                            const TextStyle(color: Color(0xFFBBBBBB)),
                        prefixIcon: const Icon(Icons.search,
                            color: Color(0xFF8899AA)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFE91E8C), width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFE91E8C), width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFE91E8C), width: 2),
                        ),
                      ),
                      onChanged: (val) {
                        final katakana = _toKatakana(val);
                        setModalState(() {
                          _addQuery = val;
                          _addSuggestions = val.isEmpty
                              ? []
                              : _allCreatureNames
                                  .where((n) =>
                                      n.contains(val) ||
                                      n.contains(katakana))
                                  .take(8)
                                  .toList();
                        });
                      },
                    ),
                    if (_addSuggestions.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFE0E0E0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _addSuggestions.length,
                          separatorBuilder: (_, __) => const Divider(
                              height: 1, color: Color(0xFFEEEEEE)),
                          itemBuilder: (context, i) {
                            final name = _addSuggestions[i];
                            return InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                _addWanted(name);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    color: Color(0xFF0D1B2A),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addQuery.isEmpty
                            ? null
                            : () {
                                Navigator.pop(context);
                                _addWanted(_addQuery);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E8C),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              const Color(0xFFE0E0E0),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '追加する',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
          '見たい生物',
          style: TextStyle(
              color: Color(0xFF0D1B2A), fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFE91E8C), size: 28),
            onPressed: _showAddModal,
          ),
        ],
      ),
      body: Column(
        children: [
          // フィルター
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: Row(
              children: [
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
                      _loadWanted();
                    },
                  ),
                ),
                const SizedBox(width: 6),
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
                      _loadWanted();
                    },
                  ),
                ),
                const SizedBox(width: 6),
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
                              _selectedAreaName =
                                  area['nameJa'] as String;
                            });
                            _loadWanted();
                          },
                  ),
                ),
              ],
            ),
          ),

          // リスト
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _wantedCreatures.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '見たい生物を追加しましょう',
                              style: TextStyle(
                                  color: Color(0xFF8899AA), fontSize: 15),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _showAddModal,
                              icon: const Icon(Icons.add),
                              label: const Text('見たい生物を追加'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE91E8C),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _wantedCreatures.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, i) {
                          final name = _wantedCreatures[i];
                          final sightings = _sightingsMap[name] ?? [];
                          return _WantedCard(
                            creatureName: name,
                            sightings: sightings,
                            onDelete: () => _removeWanted(name),
                            onCreatureTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CreatureDetailScreen(
                                    creatureId: '',
                                    creatureName: name,
                                  ),
                                ),
                              );
                            },
                            onMoreTap: () {
                              MainScaffold.switchToLatest(creatureFilter: name);
                            },
                            formatDate: _formatDate,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _WantedCard extends StatelessWidget {
  final String creatureName;
  final List<Map<String, dynamic>> sightings;
  final VoidCallback onDelete;
  final VoidCallback onCreatureTap;
  final VoidCallback onMoreTap;
  final String Function(dynamic) formatDate;

  const _WantedCard({
    required this.creatureName,
    required this.sightings,
    required this.onDelete,
    required this.onCreatureTap,
    required this.onMoreTap,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE91E8C), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: onCreatureTap,
                    child: Text(
                      creatureName,
                      style: const TextStyle(
                        color: Color(0xFF0D1B2A),
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFFFFB300),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: Color(0xFF8899AA), size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),

          // 目撃情報
          if (sightings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'この期間の目撃情報はありません',
                style:
                    TextStyle(color: Color(0xFF8899AA), fontSize: 13),
              ),
            )
          else
            ...sightings.map((s) => InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SightingDetailScreen(sighting: s),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          s['sourceType'] == 'crawler' ? '🏪' : '🤿',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s['areaName'] as String? ?? '',
                            style: const TextStyle(
                              color: Color(0xFF0D1B2A),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          formatDate(s['date'] ?? s['createdAt']),
                          style: const TextStyle(
                            color: Color(0xFF8899AA),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

          // もっと見る
          if (sightings.isNotEmpty)
            InkWell(
              onTap: onMoreTap,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Text(
                  'もっと見る →',
                  style: TextStyle(
                    color: Color(0xFFE91E8C),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
        color: onChanged == null
            ? const Color(0xFFF5F5F5)
            : Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(
                color: Color(0xFFBBBBBB), fontSize: 12),
          ),
          style: const TextStyle(
              color: Color(0xFF0D1B2A), fontSize: 12),
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
