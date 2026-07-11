import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';

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
  final List<Map<String, String>> _categoryOptions = [
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
  String? _selectedCategory;
  List<Map<String, dynamic>> _creatures = [];
  Map<String, dynamic>? _selectedCreature;
  bool _isLoadingCreatures = false;

  // Date
  DateTime _selectedDate = DateTime.now();

  // State
  bool _isLoadingData = true;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _loadAreas();
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

  Future<void> _onCategoryChanged(String? value) async {
    setState(() {
      _selectedCategory = value;
      _selectedCreature = null;
      _creatures = [];
      _isLoadingCreatures = value != null;
    });
    if (value == null) return;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('creatures')
          .where('category', isEqualTo: value)
          .where('isActive', isEqualTo: true)
          .get();

      final list =
          snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      list.sort(
          (a, b) => (a['nameJa'] as String).compareTo(b['nameJa'] as String));

      setState(() {
        _creatures = list;
        _isLoadingCreatures = false;
      });
    } catch (e) {
      print('[PostScreen] loadCreatures error: $e');
      setState(() => _isLoadingCreatures = false);
    }
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
    if (_selectedCreature == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('生物を選択してください')),
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
        'creatureId': _selectedCreature!['id'],
        'creatureName': _selectedCreature!['nameJa'],
        'areaId': _selectedArea!['id'],
        'areaName': _selectedArea!['nameJa'],
        'date': Timestamp.fromDate(_selectedDate),
        'createdAt': FieldValue.serverTimestamp(),
        'isAnonymous': true,
      });

      if (mounted) Navigator.of(context).pop();
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
      style: const TextStyle(color: AppColors.textPrimary),
      dropdownColor: AppColors.surface,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.background,
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
    return Card(
      color: AppColors.surface,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '生物を選択 *',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            const SizedBox(height: 12),
            _buildDropdown<String>(
              value: _selectedCategory,
              hint: 'カテゴリを選択',
              items: _categoryOptions
                  .map((c) => DropdownMenuItem(
                        value: c['value'],
                        child: Text(c['label']!),
                      ))
                  .toList(),
              onChanged: _onCategoryChanged,
            ),
            const SizedBox(height: 12),
            if (_isLoadingCreatures)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2),
                ),
              )
            else
              _buildDropdown<Map<String, dynamic>>(
                value: _selectedCreature,
                hint: '生物を選択',
                enabled:
                    _selectedCategory != null && _creatures.isNotEmpty,
                items: _creatures
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c['nameJa'] as String),
                        ))
                    .toList(),
                onChanged: (val) =>
                    setState(() => _selectedCreature = val),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaSection() {
    return Card(
      color: AppColors.surface,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'エリアを選択 *',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            const SizedBox(height: 12),
            _buildDropdown<String>(
              value: _selectedRegion,
              hint: '地域を選択',
              items: _regions
                  .map((r) =>
                      DropdownMenuItem(value: r, child: Text(r)))
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
                        child: Text(a['nameJa'] as String),
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
      color: AppColors.surface,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: _selectDate,
        title: const Text(
          '日付 *',
          style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$y年${m}月${d}日',
          style: const TextStyle(color: AppColors.primary),
        ),
        trailing: const Icon(Icons.calendar_today,
            color: AppColors.textSecondary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isPosting ? null : _post,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
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
    );
  }
}
