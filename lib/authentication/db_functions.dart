import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendNotificationToFarmer({
  required String title,
  required String body,
}) async {
  // Your Firebase Server key (get it from Firebase Console > Project Settings > Cloud Messaging)
  const serverKey = "YOUR_SERVER_KEY_HERE"; // 🔒 keep it secret!

  final uid = FirebaseAuth.instance.currentUser!.uid;
  final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  final token = userDoc['fcmToken'];

  if (token == null) return;

  final data = {
    "to": token,
    "notification": {
      "title": title,
      "body": body,
    },
    "android": {
      "priority": "high",
    },
    "data": {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "screen": "farmer_dashboard",
    }
  };

  await http.post(
    Uri.parse("https://fcm.googleapis.com/fcm/send"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "key=$serverKey",
    },
    body: jsonEncode(data),
  );
}



Future<void> saveFCMToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  if (token != null) {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fcmToken': token,
    });
  }
}

Future<void>? storeUserDetails({required String name,required String role,required String password,required String email,required String address,required int phone})async{
  try{
    // docRef is reference to document we just created
    final docReference = await FirebaseFirestore.instance.collection("users").add({
    "name":name,
    "role":role,
    "password" : password,
    "email" : email,
    "address" : address,
    "phone" : phone
    });
    debugPrint(docReference.id);
  }catch(e){
    debugPrint(e.toString()
  );
  }
}

Future<void>? storeProductDetails({required String productName,required String mrp,required String price,required String rating,required String qty,required String img})async{
  try{
    final docReference = await FirebaseFirestore.instance.collection("products").add({
      "name":productName,
      "mrp":mrp,
      "price":price,
      "rating":rating,
      "qty":qty,
      "img":img
    });
    debugPrint(docReference.id);
  }catch(e){
    debugPrint(e.toString());
  }
}

Future<List<Map<String,dynamic>>>? getProductNames() async{
  try{
    final snapshot = await FirebaseFirestore.instance.collection("products").get();
    return snapshot.docs.map((e)=>e.data()).toList();
  }catch(e){
    debugPrint(e.toString());
    return [];
  }
}

Future<String?> getProductIdByFarmerAndName({
  required String farmerId,
  required String productName,
}) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('farmerId', isEqualTo: farmerId)
        .where('productName', isEqualTo: productName)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id; // ✅ Return the product document ID
    } else {
      return null; // No match found
    }
  } catch (e) {
    debugPrint('Error getting product ID: $e');
    return null;
  }
}

Future<String> addToCart({required String path,required int totalCartItems})async{
  if(path == ""){
    return path;
  }  
  try{
    await FirebaseFirestore.instance.collection("cart").add({
      "path":path
    });
    debugPrint("Added to cart");
    return "";
  }catch (e){
    debugPrint(e.toString());
    return "";
  }
}