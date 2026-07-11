import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'area_detail_screen.dart';

class AreaSearchScreen extends StatefulWidget {
  const AreaSearchScreen({super.key});

  @override
  State<AreaSearchScreen> createState() => _AreaSearchScreenState();
}

class _AreaSearchScreenState extends State<AreaSearchScreen> {
  List<Map<String, dynamic>> _allAreas = [];
  List<String> _regions = [];
  String? _selectedRegion;
  String? _selectedAreaId;
  String? _selectedAreaName;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAreas();
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
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredAreas {
    if (_selectedRegion == null) return [];
    return _allAreas.where((a) => a['region'] == _selectedRegion).toList();
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
          style: TextStyle(color: Color(0xFF0D1B2A), fontWeight: FontWeight.w500),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0D1B2A)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'エリアを選択してください',
                    style: TextStyle(color: Color(0xFF5A7A9A), fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // 地域選択
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF26C6A6), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text(
                          '地域を選択',
                          style: TextStyle(color: Color(0xFF888888)),
                        ),
                        value: _selectedRegion,
                        style: const TextStyle(
                          color: Color(0xFF0D1B2A),
                          fontSize: 16,
                        ),
                        dropdownColor: Colors.white,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0D1B2A)),
                        items: _regions.map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(
                            r,
                            style: const TextStyle(color: Color(0xFF0D1B2A)),
                          ),
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedRegion = val;
                            _selectedAreaId = null;
                            _selectedAreaName = null;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // エリア選択
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF26C6A6), width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: _selectedRegion == null
                          ? const Color(0xFFF5F5F5)
                          : Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text(
                          _selectedRegion == null ? '先に地域を選択してください' : 'エリアを選択',
                          style: TextStyle(
                            color: _selectedRegion == null
                                ? const Color(0xFFBBBBBB)
                                : const Color(0xFF888888),
                          ),
                        ),
                        value: _selectedAreaId,
                        style: const TextStyle(
                          color: Color(0xFF0D1B2A),
                          fontSize: 16,
                        ),
                        dropdownColor: Colors.white,
                        items: _filteredAreas.map((a) => DropdownMenuItem(
                          value: a['id'] as String,
                          child: Text(
                            a['nameJa'] as String,
                            style: const TextStyle(color: Color(0xFF0D1B2A)),
                          ),
                        )).toList(),
                        onChanged: _selectedRegion == null ? null : (val) {
                          final area = _filteredAreas.firstWhere((a) => a['id'] == val);
                          setState(() {
                            _selectedAreaId = val;
                            _selectedAreaName = area['nameJa'] as String;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 検索ボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedAreaId == null ? null : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AreaDetailScreen(
                              areaId: _selectedAreaId!,
                              areaName: _selectedAreaName!,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF26C6A6),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFE0E0E0),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'このエリアの目撃情報を見る',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
