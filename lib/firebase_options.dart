// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
    apiKey: 'AIzaSyBK98Kn6Sq3_uknlmrmFXGPT3HGFrGZ0hg',
    appId: '1:856214654821:web:9600638237f28b3a3a1b8c',
    messagingSenderId: '856214654821',
    projectId: 'safetouch-fe9bc',
    authDomain: 'safetouch-fe9bc.firebaseapp.com',
    storageBucket: 'safetouch-fe9bc.appspot.com',
    measurementId: 'G-22BTL5V91B',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyChTJH-XJwzD50RcbKrkYtYP52i6Sh5WHs',
    appId: '1:856214654821:android:0ce46a648ee564603a1b8c',
    messagingSenderId: '856214654821',
    projectId: 'safetouch-fe9bc',
    storageBucket: 'safetouch-fe9bc.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCpl-1Uh5v4h-uoo-V1qe-TDDX6dsQzeJs',
    appId: '1:856214654821:ios:ed760898f18a81e93a1b8c',
    messagingSenderId: '856214654821',
    projectId: 'safetouch-fe9bc',
    storageBucket: 'safetouch-fe9bc.appspot.com',
    iosClientId:
        '856214654821-o4ud9co3d3hg7qaoqdqm5np5ctoo5kub.apps.googleusercontent.com',
    iosBundleId: 'com.itgocorp.safetouch',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCpl-1Uh5v4h-uoo-V1qe-TDDX6dsQzeJs',
    appId: '1:856214654821:ios:ed760898f18a81e93a1b8c',
    messagingSenderId: '856214654821',
    projectId: 'safetouch-fe9bc',
    storageBucket: 'safetouch-fe9bc.appspot.com',
    iosClientId:
        '856214654821-o4ud9co3d3hg7qaoqdqm5np5ctoo5kub.apps.googleusercontent.com',
    iosBundleId: 'com.itgocorp.safetouch',
  );
}