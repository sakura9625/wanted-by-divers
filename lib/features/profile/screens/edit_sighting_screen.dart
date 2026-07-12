import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditSightingScreen extends StatefulWidget {
  final Map<String, dynamic> sighting;
  const EditSightingScreen({super.key, required this.sighting});

  @override
  State<EditSightingScreen> createState() => _EditSightingScreenState();
}

class _EditSightingScreenState extends State<EditSightingScreen> {
  late TextEditingController _pointController;
  late TextEditingController _waterTempController;
  late TextEditingController _visibilityController;
  DateTime? _selectedDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _pointController = TextEditingController(
        text: widget.sighting['pointName'] as String? ?? '');
    _waterTempController = TextEditingController(
        text: widget.sighting['waterTemp'] as String? ?? '');
    _visibilityController = TextEditingController(
        text: widget.sighting['visibility'] as String? ?? '');
    final dateVal = widget.sighting['date'];
    if (dateVal is String && dateVal.isNotEmpty) {
      _selectedDate = DateTime.tryParse(dateVal);
    } else if (dateVal is Timestamp) {
      _selectedDate = dateVal.toDate();
    }
    _selectedDate ??= DateTime.now();
  }

  @override
  void dispose() {
    _pointController.dispose();
    _waterTempController.dispose();
    _visibilityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final docId = widget.sighting['id'] as String?;
    if (docId == null) return;

    final dateStr =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

    await FirebaseFirestore.instance
        .collection('sightings')
        .doc(docId)
        .update({
      'date': dateStr,
      'pointName': _pointController.text.trim().isEmpty
          ? null
          : _pointController.text.trim(),
      'waterTemp': _waterTempController.text.trim().isEmpty
          ? null
          : _waterTempController.text.trim(),
      'visibility': _visibilityController.text.trim().isEmpty
          ? null
          : _visibilityController.text.trim(),
    });

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '投稿を編集',
          style: TextStyle(
              color: Color(0xFF0D1B2A), fontWeight: FontWeight.w500),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0D1B2A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 変更不可の情報
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.sighting['creatureName'] as String? ?? '',
                    style: const TextStyle(
                      color: Color(0xFF0D1B2A),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.sighting['areaName'] as String? ?? '',
                    style: const TextStyle(
                        color: Color(0xFF8899AA), fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '※生物・エリアは変更できません',
                    style: TextStyle(
                        color: Color(0xFFBBBBBB), fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 日付
            const Text('日付',
                style: TextStyle(
                    color: Color(0xFF0D1B2A),
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate!,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color(0xFF29B6F6), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      '${_selectedDate!.year}年${_selectedDate!.month}月${_selectedDate!.day}日',
                      style: const TextStyle(
                          color: Color(0xFF29B6F6), fontSize: 15),
                    ),
                    const Spacer(),
                    const Icon(Icons.calendar_today,
                        color: Color(0xFF29B6F6), size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ポイント名
            const Text('ポイント名（任意）',
                style: TextStyle(
                    color: Color(0xFF0D1B2A),
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _pointController,
              style: const TextStyle(color: Color(0xFF0D1B2A)),
              decoration: const InputDecoration(
                hintText: '例：富戸 ヨコバマ',
                hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
                labelStyle: TextStyle(color: Color(0xFF8899AA)),
                border: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFFE0E0E0))),
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFFE0E0E0))),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFF29B6F6))),
              ),
            ),
            const SizedBox(height: 20),

            // 水温・透明度
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('水温（任意）',
                          style: TextStyle(
                              color: Color(0xFF0D1B2A),
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _waterTempController,
                        style: const TextStyle(color: Color(0xFF0D1B2A)),
                        decoration: const InputDecoration(
                          hintText: '例：22℃',
                          hintStyle:
                              TextStyle(color: Color(0xFFBBBBBB)),
                          labelStyle:
                              TextStyle(color: Color(0xFF8899AA)),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFE0E0E0))),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFE0E0E0))),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFF29B6F6))),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('透明度（任意）',
                          style: TextStyle(
                              color: Color(0xFF0D1B2A),
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _visibilityController,
                        style: const TextStyle(color: Color(0xFF0D1B2A)),
                        decoration: const InputDecoration(
                          hintText: '例：15m',
                          hintStyle:
                              TextStyle(color: Color(0xFFBBBBBB)),
                          labelStyle:
                              TextStyle(color: Color(0xFF8899AA)),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFE0E0E0))),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFE0E0E0))),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFF29B6F6))),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // 保存ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF29B6F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _saving
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : const Text(
                        '保存する',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
