import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as AppSettings;

class NotificationServices {
  final _firebaseMessaging = FirebaseMessaging.instance;
  void requestNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true
    );
    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      debugPrint("User granted notification permission");
    }else if (settings.authorizationStatus == AuthorizationStatus.provisional){
      debugPrint("User provisional permission granted");
    }else{
      debugPrint("User hasn't given the notification permission");
      Future.delayed(Duration(seconds: 3),(){
        AppSettings.openAppSettings();
      });
    }
  }

  Future<String?> getDeviceToken()async{
    requestNotificationPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    debugPrint("---------------------FCM Token : $fcmToken");
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Message : ${message.notification?.title}");
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Message : ${message.notification?.title}");
    });
    return fcmToken;
  }
}
