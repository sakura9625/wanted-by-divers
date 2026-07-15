import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'creature_detail_screen.dart';

class CreatureSearchScreen extends StatefulWidget {
  const CreatureSearchScreen({super.key});

  @override
  State<CreatureSearchScreen> createState() => _CreatureSearchScreenState();
}

class _CreatureSearchScreenState extends State<CreatureSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _allCreatureNames = [];
  List<Map<String, dynamic>> _allCreatures = [];
  List<String> _suggestions = [];
  String _query = '';
  bool _loading = true;
  Map<String, String> _synonymMap = {};

  final List<Map<String, String>> _categories = [
    {'label': 'サメ・エイ', 'value': 'shark_ray'},
    {'label': '大物・回遊魚', 'value': 'big_fish'},
    {'label': '根魚・地形魚', 'value': 'reef_fish'},
    {'label': 'マクロ・レア', 'value': 'macro'},
    {'label': 'ハゼ系', 'value': 'goby'},
    {'label': 'ハナダイ系', 'value': 'anthias'},
    {'label': 'その他の魚', 'value': 'other_fish'},
    {'label': '頭足類', 'value': 'cephalopod'},
    {'label': '海洋哺乳類', 'value': 'mammal'},
    {'label': '甲殻類', 'value': 'crustacean'},
    {'label': 'ウミウシ', 'value': 'nudibranch'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _toKatakana(String text) {
    return text.replaceAllMapped(
      RegExp(r'[ぁ-ゖ]'),
      (m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) + 0x60),
    );
  }

  Future<void> _loadData() async {
    final masterSnap = await FirebaseFirestore.instance
        .collection('creatures')
        .where('isActive', isEqualTo: true)
        .get();
    final masterNames = masterSnap.docs
        .map((d) => d.data()['nameJa'] as String)
        .toList();
    final allCreatures = masterSnap.docs
        .map((d) => {'id': d.id, ...d.data()})
        .toList();

    final sightingsSnap = await FirebaseFirestore.instance
        .collection('sightings')
        .get();
    final sightingNames = sightingsSnap.docs
        .map((d) => d.data()['creatureName'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .toList();

    final all = {...masterNames, ...sightingNames}.toList()..sort();

    // creature_dictionaryから同義語を取得
    final dictSnap = await FirebaseFirestore.instance
        .collection('creature_dictionary')
        .where('type', isEqualTo: 'synonym')
        .get();

    // 同義語マップを作成（rawName → canonicalName の双方向）
    final synonymMap = <String, String>{};
    for (final doc in dictSnap.docs) {
      final data = doc.data();
      final raw = data['rawName'] as String? ?? '';
      final canonical = data['canonicalName'] as String? ?? '';
      if (raw.isNotEmpty && canonical.isNotEmpty) {
        synonymMap[raw] = canonical;
        synonymMap[canonical] = raw;
      }
    }

    setState(() {
      _allCreatureNames = all;
      _allCreatures = allCreatures;
      _synonymMap = synonymMap;
      _loading = false;
    });
  }

  void _onQueryChanged(String val) {
    final katakana = _toKatakana(val);
    // 同義語を取得
    final synonyms = _synonymMap.entries
        .where((e) => e.key.contains(val) || e.key.contains(katakana))
        .map((e) => e.value)
        .toList();

    setState(() {
      _query = val;
      if (val.isEmpty) {
        _suggestions = [];
      } else {
        final direct = _allCreatureNames
            .where((n) => n.contains(val) || n.contains(katakana))
            .toList();
        // 同義語も候補に追加
        final withSynonyms = {...direct, ...synonyms}.toList()..sort();
        _suggestions = withSynonyms.take(8).toList();
      }
    });
  }

  void _selectCreature(String name) {
    _searchController.text = name;
    setState(() {
      _query = name;
      _suggestions = [];
    });
    FocusScope.of(context).unfocus();
  }

  void _search() {
    if (_query.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreatureDetailScreen(
          creatureId: '',
          creatureName: _query,
        ),
      ),
    );
  }

  void _showCategoryModal(String categoryValue, String categoryLabel) {
    final creatures = _allCreatures
        .where((c) => c['category'] == categoryValue)
        .toList()
      ..sort((a, b) =>
          (a['nameJa'] as String).compareTo(b['nameJa'] as String));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    '#$categoryLabel',
                    style: const TextStyle(
                      color: Color(0xFF26C6A6),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF8899AA)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: creatures.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                itemBuilder: (context, i) {
                  final name = creatures[i]['nameJa'] as String;
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _selectCreature(name);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'どこで見た？',
          style: TextStyle(
              color: Color(0xFF0D1B2A), fontWeight: FontWeight.w500),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0D1B2A)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '生物名を入力してください',
                    style:
                        TextStyle(color: Color(0xFF5A7A9A), fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // 検索バー
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(
                        color: Color(0xFF0D1B2A), fontSize: 16),
                    decoration: InputDecoration(
                      hintText: '例：まんた、アオリイカ',
                      hintStyle: const TextStyle(
                          color: Color(0xFFBBBBBB), fontSize: 16),
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFF8899AA)),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: Color(0xFF8899AA)),
                              onPressed: () {
                                _searchController.clear();
                                _onQueryChanged('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF26C6A6), width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF26C6A6), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF26C6A6), width: 2),
                      ),
                    ),
                    onChanged: _onQueryChanged,
                    onSubmitted: (_) => _search(),
                  ),

                  // サジェスト
                  if (_suggestions.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: const Color(0xFFE0E0E0)),
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
                        itemCount: _suggestions.length,
                        separatorBuilder: (_, __) => const Divider(
                            height: 1, color: Color(0xFFEEEEEE)),
                        itemBuilder: (context, i) {
                          final name = _suggestions[i];
                          return InkWell(
                            onTap: () => _selectCreature(name),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.search,
                                      color: Color(0xFF8899AA), size: 16),
                                  const SizedBox(width: 10),
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: Color(0xFF0D1B2A),
                                      fontSize: 15,
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

                  const SizedBox(height: 24),

                  // タグセクション
                  const Text(
                    'Wantedされやすい人気賞金首',
                    style: TextStyle(
                      color: Color(0xFF26C6A6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      return GestureDetector(
                        onTap: () => _showCategoryModal(
                            cat['value']!, cat['label']!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFF26C6A6), width: 1.5),
                          ),
                          child: Text(
                            '#${cat['label']}',
                            style: const TextStyle(
                              color: Color(0xFF26C6A6),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // 検索ボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _query.isEmpty ? null : _search,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF26C6A6),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFE0E0E0),
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'この生物の目撃情報を見る',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
