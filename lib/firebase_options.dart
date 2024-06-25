// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBJf1K0O4rNYUTaQanV8HRE3fQvhsqGOiI',
    appId: '1:824880938537:web:a7486ff410da261e46a638',
    messagingSenderId: '824880938537',
    projectId: 'sharecare-18534',
    authDomain: 'sharecare-18534.firebaseapp.com',
    databaseURL: 'https://sharecare-18534-default-rtdb.firebaseio.com',
    storageBucket: 'sharecare-18534.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAcIIuNApDUtpyoxaE3oNSTfJp1dv4erxs',
    appId: '1:824880938537:android:d8c795759710b96746a638',
    messagingSenderId: '824880938537',
    projectId: 'sharecare-18534',
    databaseURL: 'https://sharecare-18534-default-rtdb.firebaseio.com',
    storageBucket: 'sharecare-18534.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyARieVyjYQV84jzmOuSwNITUozyA7MOELA',
    appId: '1:824880938537:ios:066719d608e9168546a638',
    messagingSenderId: '824880938537',
    projectId: 'sharecare-18534',
    databaseURL: 'https://sharecare-18534-default-rtdb.firebaseio.com',
    storageBucket: 'sharecare-18534.appspot.com',
    iosBundleId: 'com.example.shareCare',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyARieVyjYQV84jzmOuSwNITUozyA7MOELA',
    appId: '1:824880938537:ios:066719d608e9168546a638',
    messagingSenderId: '824880938537',
    projectId: 'sharecare-18534',
    databaseURL: 'https://sharecare-18534-default-rtdb.firebaseio.com',
    storageBucket: 'sharecare-18534.appspot.com',
    iosBundleId: 'com.example.shareCare',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBJf1K0O4rNYUTaQanV8HRE3fQvhsqGOiI',
    appId: '1:824880938537:web:956fed0e8d50415046a638',
    messagingSenderId: '824880938537',
    projectId: 'sharecare-18534',
    authDomain: 'sharecare-18534.firebaseapp.com',
    databaseURL: 'https://sharecare-18534-default-rtdb.firebaseio.com',
    storageBucket: 'sharecare-18534.appspot.com',
  );
}
