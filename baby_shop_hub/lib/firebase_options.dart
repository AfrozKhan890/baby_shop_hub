// lib/firebase_options.dart

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
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCsUh8MFpL2XE_OOCYc4TrquaWL4BKNhlQ",
    authDomain: "babyshophub-6123b.firebaseapp.com",
    projectId: "babyshophub-6123b",
    storageBucket: "babyshophub-6123b.firebasestorage.app",
    messagingSenderId: "889317806404",
    appId: "1:889317806404:web:8fc30e0b7650bd8a54c711",
    measurementId: "G-4MVT3M53N3",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCsUh8MFpL2XE_OOCYc4TrquaWL4BKNhlQ",
    appId: "1:889317806404:android:8fc30e0b7650bd8a54c711",
    messagingSenderId: "889317806404",
    projectId: "babyshophub-6123b",
    storageBucket: "babyshophub-6123b.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyCsUh8MFpL2XE_OOCYc4TrquaWL4BKNhlQ",
    appId: "1:889317806404:ios:8fc30e0b7650bd8a54c711",
    messagingSenderId: "889317806404",
    projectId: "babyshophub-6123b",
    storageBucket: "babyshophub-6123b.firebasestorage.app",
    iosBundleId: "com.example.babyshophub",
  );
}