// File generated based on GoogleService-Info.plist
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBAF5wCbnF5rEfeWDxiBbA0ORTGN09XXF0',
    appId: '1:970002681551:ios:e9b5d518c08dc18ee6b1ba',
    messagingSenderId: '970002681551',
    projectId: 'wanted-by-divers',
    storageBucket: 'wanted-by-divers.firebasestorage.app',
    iosBundleId: 'com.wantedbydivers',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBAF5wCbnF5rEfeWDxiBbA0ORTGN09XXF0',
    appId: '1:970002681551:web:9e85605a1ed065f3e6b1ba',
    messagingSenderId: '970002681551',
    projectId: 'wanted-by-divers',
    storageBucket: 'wanted-by-divers.firebasestorage.app',
  );
}
