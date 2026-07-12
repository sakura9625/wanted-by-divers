import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import 'thanks_screen.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  // Areas
  List<Map<String, dynamic>> _allAreas = [];
  List<String> _regions = [];
  String? _selectedRegion;
  Map<String, dynamic>? _selectedArea;

  // Creatures
  final TextEditingController _creatureSearchController =
      TextEditingController();
  List<Map<String, dynamic>> _allCreatures = [];
  List<String> _allCreatureNames = [];
  List<String> _suggestions = [];
  String _creatureQuery = '';
  String? _selectedCreatureId;
  String? _selectedCreatureName;

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

  // Date
  DateTime _selectedDate = DateTime.now();

  // Optional fields
  final TextEditingController _pointNameController = TextEditingController();
  final TextEditingController _waterTempController = TextEditingController();
  final TextEditingController _visibilityController = TextEditingController();

  // State
  bool _isLoadingData = true;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _loadAreas();
    _loadCreatures();
    _loadAllCreatureNames();
  }

  @override
  void dispose() {
    _pointNameController.dispose();
    _waterTempController.dispose();
    _visibilityController.dispose();
    _creatureSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadAreas() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('areas')
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .get();

      final areas =
          snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

      final seenRegions = <String>{};
      final regions = <String>[];
      for (final area in areas) {
        final region = area['region'] as String;
        if (seenRegions.add(region)) regions.add(region);
      }

      setState(() {
        _allAreas = areas;
        _regions = regions;
        _isLoadingData = false;
      });
    } catch (e) {
      print('[PostScreen] loadAreas error: $e');
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _loadCreatures() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('creatures')
        .where('isActive', isEqualTo: true)
        .get();
    setState(() {
      _allCreatures = snapshot.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList()
        ..sort((a, b) =>
            (a['nameJa'] as String).compareTo(b['nameJa'] as String));
    });
  }

  String _toKatakana(String text) {
    return text.replaceAllMapped(
      RegExp(r'[ぁ-ゖ]'),
      (m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) + 0x60),
    );
  }

  Future<void> _loadAllCreatureNames() async {
    final sightingsSnap =
        await FirebaseFirestore.instance.collection('sightings').get();
    final sightingNames = sightingsSnap.docs
        .map((d) => d.data()['creatureName'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .toSet();

    final masterNames =
        _allCreatures.map((c) => c['nameJa'] as String).toSet();

    final all = {...masterNames, ...sightingNames}.toList()..sort();
    setState(() => _allCreatureNames = all);
  }

  void _onCreatureQueryChanged(String val) {
    final katakana = _toKatakana(val);
    setState(() {
      _creatureQuery = val;
      _selectedCreatureName = val.isEmpty ? null : val;
      if (val.isEmpty) {
        _suggestions = [];
      } else {
        _suggestions = _allCreatureNames
            .where((n) => n.contains(val) || n.contains(katakana))
            .take(8)
            .toList();
      }
    });
  }

  void _selectCreature(String name) {
    final creature = _allCreatures.firstWhere(
      (c) => c['nameJa'] == name,
      orElse: () => {},
    );
    _creatureSearchController.text = name;
    setState(() {
      _selectedCreatureId =
          creature.isNotEmpty ? creature['id'] as String : null;
      _selectedCreatureName = name;
      _creatureQuery = name;
      _suggestions = [];
    });
    FocusScope.of(context).unfocus();
  }

  void _showCategoryModal(String categoryValue, String categoryLabel) {
    final creatures = _allCreatures
        .where((c) => c['category'] == categoryValue)
        .toList();

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
                      color: Color(0xFF29B6F6),
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

  List<Map<String, dynamic>> get _filteredAreas {
    if (_selectedRegion == null) return [];
    return _allAreas.where((a) => a['region'] == _selectedRegion).toList();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _post() async {
    if (_selectedCreatureName == null || _selectedCreatureName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('生物を選択または入力してください')),
      );
      return;
    }
    if (_selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('エリアを選択してください')),
      );
      return;
    }

    setState(() => _isPosting = true);
    try {
      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        await auth.signInAnonymously();
      }
      final uid = auth.currentUser!.uid;

      await FirebaseFirestore.instance.collection('sightings').add({
        'uid': uid,
        'creatureId': _selectedCreatureId,
        'creatureName': _selectedCreatureName,
        'areaId': _selectedArea!['id'],
        'areaName': _selectedArea!['nameJa'],
        'date': Timestamp.fromDate(_selectedDate),
        'createdAt': FieldValue.serverTimestamp(),
        'isAnonymous': true,
        'pointName': _pointNameController.text.trim().isEmpty
            ? null
            : _pointNameController.text.trim(),
        'waterTemp': _waterTempController.text.trim().isEmpty
            ? null
            : _waterTempController.text.trim(),
        'visibility': _visibilityController.text.trim().isEmpty
            ? null
            : _visibilityController.text.trim(),
      });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ThanksScreen(
              creatureName: _selectedCreatureName ?? '',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('投稿に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String hint,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      hint: Text(hint,
          style: const TextStyle(color: AppColors.textSecondary)),
      style: const TextStyle(color: Color(0xFF0D1B2A), fontSize: 16),
      dropdownColor: Colors.white,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.textSecondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.textSecondary),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      iconEnabledColor: AppColors.textSecondary,
      iconDisabledColor:
          AppColors.textSecondary.withOpacity(0.3),
    );
  }

  Widget _buildCreatureSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF29B6F6), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '生物を選択 *',
            style: TextStyle(
              color: Color(0xFF0D1B2A),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Text(
            '生物名を入力、またはタグから選択してください',
            style: TextStyle(color: Color(0xFF8899AA), fontSize: 12),
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 12),

          // 検索バー
          TextField(
            controller: _creatureSearchController,
            style: const TextStyle(color: Color(0xFF0D1B2A), fontSize: 15),
            decoration: InputDecoration(
              hintText: '例：まんた、アオリイカ',
              hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF8899AA)),
              suffixIcon: _creatureQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Color(0xFF8899AA)),
                      onPressed: () {
                        _creatureSearchController.clear();
                        setState(() {
                          _creatureQuery = '';
                          _selectedCreatureId = null;
                          _selectedCreatureName = null;
                          _suggestions = [];
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF29B6F6)),
              ),
            ),
            onChanged: _onCreatureQueryChanged,
          ),

          // サジェスト
          if (_suggestions.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE0E0E0)),
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
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                itemBuilder: (context, i) {
                  final name = _suggestions[i];
                  return InkWell(
                    onTap: () => _selectCreature(name),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Color(0xFF0D1B2A),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 12),

          // タグ
          const Text(
            'Wantedされやすい人気賞金首',
            style: TextStyle(
              color: Color(0xFF29B6F6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _categories.map((cat) {
              return GestureDetector(
                onTap: () =>
                    _showCategoryModal(cat['value']!, cat['label']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF29B6F6), width: 1.5),
                  ),
                  child: Text(
                    '#${cat['label']}',
                    style: const TextStyle(
                      color: Color(0xFF29B6F6),
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaSection() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF29B6F6), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'エリアを選択 *',
              style: TextStyle(
                  color: Color(0xFF0D1B2A),
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            const SizedBox(height: 12),
            _buildDropdown<String>(
              value: _selectedRegion,
              hint: '地域を選択',
              items: _regions
                  .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(
                          r,
                          style: const TextStyle(color: Color(0xFF0D1B2A)),
                        ),
                      ))
                  .toList(),
              onChanged: (val) => setState(() {
                _selectedRegion = val;
                _selectedArea = null;
              }),
            ),
            const SizedBox(height: 12),
            _buildDropdown<Map<String, dynamic>>(
              value: _selectedArea,
              hint: 'エリアを選択',
              enabled: _selectedRegion != null,
              items: _filteredAreas
                  .map((a) => DropdownMenuItem(
                        value: a,
                        child: Text(
                          a['nameJa'] as String,
                          style: const TextStyle(color: Color(0xFF0D1B2A)),
                        ),
                      ))
                  .toList(),
              onChanged: (val) =>
                  setState(() => _selectedArea = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    final y = _selectedDate.year;
    final m = _selectedDate.month.toString().padLeft(2, '0');
    final d = _selectedDate.day.toString().padLeft(2, '0');
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF29B6F6), width: 2),
      ),
      child: ListTile(
        onTap: _selectDate,
        title: const Text(
          '日付 *',
          style: TextStyle(
              color: Color(0xFF0D1B2A),
              fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$y年${m}月${d}日',
          style: const TextStyle(color: Color(0xFF29B6F6)),
        ),
        trailing: const Icon(Icons.calendar_today,
            color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildOptionalSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '任意情報',
            style: TextStyle(
              color: Color(0xFF0D1B2A),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // ポイント名
          TextField(
            controller: _pointNameController,
            style: const TextStyle(color: Color(0xFF0D1B2A)),
            decoration: const InputDecoration(
              labelText: 'ポイント名',
              labelStyle: TextStyle(color: Color(0xFF8899AA)),
              hintText: '例：富戸 ヨコバマ',
              hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF29B6F6)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 水温・透明度（横並び）
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _waterTempController,
                  style: const TextStyle(color: Color(0xFF0D1B2A)),
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: '水温',
                    labelStyle: TextStyle(color: Color(0xFF8899AA)),
                    hintText: '例：22℃',
                    hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF29B6F6)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _visibilityController,
                  style: const TextStyle(color: Color(0xFF0D1B2A)),
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: '透明度',
                    labelStyle: TextStyle(color: Color(0xFF8899AA)),
                    hintText: '例：15m',
                    hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF29B6F6)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0D1B2A),
        title: const Text('目撃情報を投稿'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCreatureSection(),
                  const SizedBox(height: 16),
                  _buildAreaSection(),
                  const SizedBox(height: 16),
                  _buildDateSection(),
                  const SizedBox(height: 16),
                  _buildOptionalSection(),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  offset: const Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isPosting ? null : _post,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF29B6F6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isPosting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('投稿する',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
