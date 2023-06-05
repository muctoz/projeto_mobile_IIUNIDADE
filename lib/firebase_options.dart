// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyBQe7sMYeET-5sXJ6lXnAS1LnIxX2HsMKg',
    appId: '1:450681701864:web:6579535afcf93d11e1505d',
    messagingSenderId: '450681701864',
    projectId: 'notes-6e04c',
    authDomain: 'notes-6e04c.firebaseapp.com',
    storageBucket: 'notes-6e04c.appspot.com',
    measurementId: 'G-FH4CZV9K79',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBSjXdzAK6e63mcN5zrBqiQtqu3_aBt2Q8',
    appId: '1:450681701864:android:4816cb2b0f65e454e1505d',
    messagingSenderId: '450681701864',
    projectId: 'notes-6e04c',
    storageBucket: 'notes-6e04c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDfIaoK5UKXqsZYNTfGh3nXighjr9YwhaQ',
    appId: '1:450681701864:ios:470d33421e6b7557e1505d',
    messagingSenderId: '450681701864',
    projectId: 'notes-6e04c',
    storageBucket: 'notes-6e04c.appspot.com',
    iosBundleId: 'com.example.projetoMobile',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDfIaoK5UKXqsZYNTfGh3nXighjr9YwhaQ',
    appId: '1:450681701864:ios:008a59447a3fead8e1505d',
    messagingSenderId: '450681701864',
    projectId: 'notes-6e04c',
    storageBucket: 'notes-6e04c.appspot.com',
    iosBundleId: 'com.example.projetoMobile.RunnerTests',
  );
}
