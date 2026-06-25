import 'package:flutter/material.dart';

class WantedScreen extends StatelessWidget {
  const WantedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wanted')),
      body: const Center(child: Text('Wanted画面')),
    );
  }
}
