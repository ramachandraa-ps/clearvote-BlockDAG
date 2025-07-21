import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Firebase options for web platform
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBvuFSCGUWpKZaYnlvYmDLXHKZWxCXDWE0',
    appId: '1:698774116849:web:2ba585ca085e2e505c8c50',
    messagingSenderId: '698774116849',
    projectId: 'clearvote2025',
    authDomain: 'clearvote2025.firebaseapp.com',
    storageBucket: 'clearvote2025.firebasestorage.app',
    measurementId: 'G-XYZBCDEFGH',
  );

  /// Firebase options for android platform
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCuXY8jRvILQMaswvi31TE0t1FyK_6kHpg',
    appId: '1:698774116849:android:2ba585ca085e2e505c8c50',
    messagingSenderId: '698774116849',
    projectId: 'clearvote2025',
    storageBucket: 'clearvote2025.firebasestorage.app',
    databaseURL: 'https://clearvote2025-default-rtdb.firebaseio.com',
  );

  /// Firebase options for iOS platform
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBvuFSCGUWpKZaYnlvYmDLXHKZWxCXDWE0',
    appId: '1:698774116849:ios:2ba585ca085e2e505c8c50',
    messagingSenderId: '698774116849',
    projectId: 'clearvote2025',
    storageBucket: 'clearvote2025.firebasestorage.app',
    iosClientId: '698774116849-abc123def456.apps.googleusercontent.com',
    iosBundleId: 'com.example.clearvote',
  );

  /// Firebase options for macOS platform
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBvuFSCGUWpKZaYnlvYmDLXHKZWxCXDWE0',
    appId: '1:698774116849:ios:2ba585ca085e2e505c8c50',
    messagingSenderId: '698774116849',
    projectId: 'clearvote2025',
    storageBucket: 'clearvote2025.firebasestorage.app',
    iosClientId: '698774116849-abc123def456.apps.googleusercontent.com',
    iosBundleId: 'com.example.clearvote',
  );

  /// Firebase options for Windows platform
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBvuFSCGUWpKZaYnlvYmDLXHKZWxCXDWE0',
    appId: '1:698774116849:windows:2ba585ca085e2e505c8c50',
    messagingSenderId: '698774116849',
    projectId: 'clearvote2025',
    storageBucket: 'clearvote2025.firebasestorage.app',
  );
} 