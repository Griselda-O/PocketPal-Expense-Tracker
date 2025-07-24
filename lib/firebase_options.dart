import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBeORbClez20ugFCOI5d3OzWXmZthafB8w',
    appId: '1:699815209313:android:04ff9e0578c02b98637d20',
    messagingSenderId: '699815209313',
    projectId: 'pocketpal-1dbf4',
    storageBucket: 'pocketpal-1dbf4.firebasestorage.app',
  );
}