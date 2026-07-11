import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('[main] kIsWeb: $kIsWeb');
  print('[main] platform: $defaultTargetPlatform');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('[main] Firebase initialized');
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
