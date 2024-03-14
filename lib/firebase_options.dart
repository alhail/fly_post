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
    apiKey: 'AIzaSyAFIbwu0KeK7nx5jTx-_w_3fSeS_z1IIds',
    appId: '1:16389177943:web:e15085902ab49961735912',
    messagingSenderId: '16389177943',
    projectId: 'fly-post',
    authDomain: 'fly-post.firebaseapp.com',
    databaseURL: 'https://fly-post-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'fly-post.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDWIsWaJNHcHFhPjwRNmRWArPSub0XM_34',
    appId: '1:16389177943:android:49c3c44e7b8edf80735912',
    messagingSenderId: '16389177943',
    projectId: 'fly-post',
    databaseURL: 'https://fly-post-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'fly-post.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA1S8KKGtR7RbV5XZ8kaMgKJkOlUObj1XU',
    appId: '1:16389177943:ios:54d463c72bdd9b2c735912',
    messagingSenderId: '16389177943',
    projectId: 'fly-post',
    databaseURL: 'https://fly-post-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'fly-post.appspot.com',
    iosBundleId: 'com.example.flyPost',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA1S8KKGtR7RbV5XZ8kaMgKJkOlUObj1XU',
    appId: '1:16389177943:ios:54aae9f182790b0a735912',
    messagingSenderId: '16389177943',
    projectId: 'fly-post',
    databaseURL: 'https://fly-post-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'fly-post.appspot.com',
    iosBundleId: 'com.example.flyPost.RunnerTests',
  );
}
