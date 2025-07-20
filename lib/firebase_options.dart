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
    appId: '1:1082745525428:web:a4e6b0f4d2e3b5c9d8e7f6',
    messagingSenderId: '1082745525428',
    projectId: 'clearvote2025',
    authDomain: 'clearvote2025.firebaseapp.com',
    storageBucket: 'clearvote2025.appspot.com',
    measurementId: 'G-XYZBCDEFGH',
  );

  /// Firebase options for android platform
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBvuFSCGUWpKZaYnlvYmDLXHKZWxCXDWE0',
    appId: '1:1082745525428:android:a4e6b0f4d2e3b5c9d8e7f6',
    messagingSenderId: '1082745525428',
    projectId: 'clearvote2025',
    storageBucket: 'clearvote2025.appspot.com',
  );

  /// Firebase options for iOS platform
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBvuFSCGUWpKZaYnlvYmDLXHKZWxCXDWE0',
    appId: '1:1082745525428:ios:a4e6b0f4d2e3b5c9d8e7f6',
    messagingSenderId: '1082745525428',
    projectId: 'clearvote2025',
    storageBucket: 'clearvote2025.appspot.com',
    iosClientId: '1082745525428-abc123def456.apps.googleusercontent.com',
    iosBundleId: 'com.example.clearvote',
  );

  /// Firebase options for macOS platform
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBvuFSCGUWpKZaYnlvYmDLXHKZWxCXDWE0',
    appId: '1:1082745525428:ios:a4e6b0f4d2e3b5c9d8e7f6',
    messagingSenderId: '1082745525428',
    projectId: 'clearvote2025',
    storageBucket: 'clearvote2025.appspot.com',
    iosClientId: '1082745525428-abc123def456.apps.googleusercontent.com',
    iosBundleId: 'com.example.clearvote',
  );

  /// Firebase options for Windows platform
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBvuFSCGUWpKZaYnlvYmDLXHKZWxCXDWE0',
    appId: '1:1082745525428:windows:a4e6b0f4d2e3b5c9d8e7f6',
    messagingSenderId: '1082745525428',
    projectId: 'clearvote2025',
    storageBucket: 'clearvote2025.appspot.com',
  );
} 