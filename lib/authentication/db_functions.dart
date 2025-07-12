import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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