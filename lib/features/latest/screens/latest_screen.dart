import 'package:flutter/material.dart';

class LatestScreen extends StatelessWidget {
  const LatestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('最新情報')),
      body: const Center(child: Text('最新情報画面')),
    );
  }
}
