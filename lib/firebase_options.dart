// GENERATED CODE - DO NOT MODIFY BY HAND
// FlutterFire CLI によって自動生成

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAwHq2zH…',                                // จาก google-services.json
    appId: '1:576948336548:android:27570c8ee6d4d3893d7331', // Android App ID 
    messagingSenderId: '576948336548',
    projectId: 'android-dcbef',
    storageBucket: 'android-dcbef.firebasestorage.app',
    databaseURL: 'https://android-dcbef-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDEds_3tBG5jdPMRLZyBl1EJFo196mjNgs',       // จาก GoogleService-Info.plist
    appId: '1:576948336548:ios:5805d98003cd621d3d7331',     // iOS App ID
    messagingSenderId: '576948336548',
    projectId: 'android-dcbef',
    storageBucket: 'android-dcbef.firebasestorage.app',
    databaseURL: 'https://android-dcbef-default-rtdb.firebaseio.com',
    iosBundleId: 'com.mplus.myfluttermapwash',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: '<Web-API-KEY-จากคอนโซล>',
    authDomain: 'android-dcbef.firebaseapp.com',
    projectId: 'android-dcbef',
    storageBucket: 'android-dcbef.firebasestorage.app',
    messagingSenderId: '576948336548',
    appId: '1:576948336548:web:xxxxxxxxxxxxxxxxxxxxxx',
    measurementId: 'G-XXXXXXXXXX',
  );
}
