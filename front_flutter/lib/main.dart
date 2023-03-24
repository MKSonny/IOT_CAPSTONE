import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:front_flutter/page/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
 

  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Map<String, String> data;

  if (Platform.isAndroid) {
    data = {'who': 'android'};
  } else if (Platform.isIOS) {
    data = {'who': 'ios'};
  } else {
    data = {'who': 'error'};
  }

  final database = FirebaseFirestore.instance.collection('version').doc('KS9DVXtJaKszqMcRK5eO').set(
    data
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  messaging.getToken().then((value) => print('FirebaseMessaging token is $value'));
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  }); 

  runApp(const MaterialApp(
    home: HomePage(),
    // debugShowCheckedModeBanner: false,
  ));
}

