// GENERATED - but manually edited to match your Firebase project.
// ⚠️  Run `flutterfire configure` to auto-generate this file properly
//     and get real iOS/Android configs. See SETUP.md for instructions.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ✅ Your actual web config
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCnqe1SFIxVLTPE7ZQxv9edGGamuU2M2Po',
    authDomain: 'word-mark-e1006.firebaseapp.com',
    projectId: 'word-mark-e1006',
    storageBucket: 'word-mark-e1006.firebasestorage.app',
    messagingSenderId: '1060443363362',
    appId: '1:1060443363362:web:c3a515e95bc2b4798c927b',
  );

  // ⚠️  TODO: Replace with values from your google-services.json
  // Go to Firebase Console → Project Settings → Add Android app
  // Package name: com.wordmark.app
  // Download google-services.json → place in android/app/
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_ANDROID_API_KEY',
    appId: 'REPLACE_WITH_ANDROID_APP_ID',
    messagingSenderId: '1060443363362',
    projectId: 'word-mark-e1006',
    storageBucket: 'word-mark-e1006.firebasestorage.app',
  );

  // ⚠️  TODO: Replace with values from your GoogleService-Info.plist
  // Go to Firebase Console → Project Settings → Add iOS app
  // Bundle ID: com.wordmark.app
  // Download GoogleService-Info.plist → add to ios/Runner/ in Xcode
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: 'REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '1060443363362',
    projectId: 'word-mark-e1006',
    storageBucket: 'word-mark-e1006.firebasestorage.app',
    iosBundleId: 'com.wordmark.app',
  );
}
