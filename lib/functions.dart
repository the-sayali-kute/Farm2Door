import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<Map<String, dynamic>?> getCurrentUserDetails() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("No user logged in.");
      return null;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      return userDoc.data(); // ✅ returns Map<String, dynamic>
    } else {
      debugPrint("User document not found.");
      return null;
    }
  } catch (e) {
    debugPrint("Error fetching current user details: $e");
    return null;
  }
}


Future<String?> getUserIdFromOrder(String orderId) async {
  try {
    final orderDoc = await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .get();

    final data = orderDoc.data();
    if (data == null || !data.containsKey('userId')) {
      return null; // Order not found or missing userId
    }
    return data['userId'] as String; // ✅ Return userId
  } catch (e) {
    debugPrint('Error fetching userId from order: $e');
    return null;
  }
}


 Future<String?> getUserNameFromOrder(String orderId) async {
    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get();

      final data = orderDoc.data();
      if (data == null || !data.containsKey('userId')) {
        return null; // Order not found or missing userId
      }

      final buyer = await FirebaseFirestore.instance.collection('users').doc(data['userId']).get();
      return buyer['name'] as String;
    } catch (e) {
      debugPrint('Error fetching userId from order: $e');
      return null;
    }
  }

String displayStock(int stock, String unit) {
  unit = unit.trim().toLowerCase();

  if (unit.contains("gm")) {
    final match = RegExp(r'(\d+)').firstMatch(unit);
    if (match != null) {
      final quantityPerUnit = int.parse(match.group(1)!);
      final totalGm = stock * quantityPerUnit;

      if (totalGm >= 1000) {
        final totalKg = totalGm / 1000;
        return "${totalKg.toStringAsFixed(totalKg % 1 == 0 ? 0 : 1)} kg";
      } else {
        return "$totalGm gm";
      }
    } else {
      return "$stock x gm";
    }
  } else {
    return "$stock $unit";
  }
}

Future<void> updateProductQuantityAfterOrder({
  required String farmerId,
  required String productName,
  required int orderedQuantity,
}) async {
  try {
    // Query the product uploaded by the specific farmer with the given product name
    debugPrint('Function called');

    final query = await FirebaseFirestore.instance
        .collection('products')
        .where('farmerId', isEqualTo: farmerId)
        .where('productName', isEqualTo: productName)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      debugPrint('❌ Product not found.');
      return;
    }

    final productDoc = query.docs.first;
    final data = productDoc.data();
    debugPrint('Fetched product: $data');

    // Get current stock safely
    final stockRaw = data['stock'];
    int updatedStock;

    if (stockRaw is int) {
      updatedStock = stockRaw - orderedQuantity;
    } else if (stockRaw is String) {
      updatedStock = int.tryParse(stockRaw) ?? -1;
    } else {
      debugPrint('❌ Stock is of unsupported type: ${stockRaw.runtimeType}');
      return;
    }

    if (updatedStock < 0) {
      debugPrint(
        '⚠️ Not enough stock. Current: $stockRaw, Ordered: $orderedQuantity',
      );
      return;
    }

    // ✅ Update Firestore
    await productDoc.reference.update({'stock': updatedStock});
    debugPrint('✅ Product stock updated to $updatedStock');
  } catch (e) {
    debugPrint('Error updating product quantity: $e');
  }
}

void addToCart(
  BuildContext context, {
  required String farmerId,
  required String productId,
  required String productName,
  required String path,
  required String mrp,
  required String sellingPrice,
  required String unit,
}) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('cart').add({
      'buyerId': user!.uid,
      'farmerId': farmerId,
      'productName': productName,
      'productId': productId, // Pass product ID to widget
      'img': path,
      'sellingPrice': sellingPrice,
      'mrp': mrp,
      'unit': unit,
      'quantity': "1", // default, you can allow updates
      'addedAt': Timestamp.now(),
    });

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(successBar("$productName added to cart!", duration: 1));
  } catch (e) {
    debugPrint("Error adding to cart: $e");
    ScaffoldMessenger.of(
      // ignore: use_build_context_synchronously
      context,
    ).showSnackBar(errorBar("Something went wrong."));
  }
}

Future<Position?> getCurrentLocation() async {
  // Step 1: Request location permission from the user
  var status = await Permission.location.request();

  // Step 2: If permission is granted
  if (status.isGranted) {
    // Step 3: Check if location services (GPS) are enabled on the device
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    // If location services are not enabled, open device settings to enable them
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return null;
    }

    // Step 4: Get the current location with best possible accuracy (non-deprecated way)
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );
  } else if (status.isPermanentlyDenied) {
    // If permission is permanently denied, open app settings for user to enable it manually
    openAppSettings();
    return null;
  }

  // Step 5: If permission is denied or not handled, return null
  return null;
}

String getDisplayUnit(String unit, final quantity) {
  if (unit.toLowerCase().contains('gm')) {
    final number = int.tryParse(unit.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return '${quantity * number}gm';
  } else {
    return '$quantity $unit';
  }
}

Future<Position?> fetchLocation() async {
  Position? position = await getCurrentLocation();
  if (position != null) {
    debugPrint(
      "Latitude: ${position.latitude}, Longitude: ${position.longitude}",
    );
    return position;
  } else {
    debugPrint("Location permission denied or error occurred.");
    return null;
  }
}

showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );
}

SnackBar errorBar(String message) {
  return SnackBar(
    content: Row(
      children: [
        Icon(Icons.error_outline, color: Colors.white),
        SizedBox(width: 10),
        Text(message),
      ],
    ),
    backgroundColor: Colors.red.shade600, // Strong red color
    behavior: SnackBarBehavior.floating, // Makes it float above content
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: Duration(seconds: 3),
    elevation: 8,
  );
}

SnackBar warningBar(String message) {
  return SnackBar(
    content: Row(
      children: [
        Icon(Icons.error_outline, color: Colors.white),
        SizedBox(width: 10),
        Text(message),
      ],
    ),
    backgroundColor: Colors.yellow.shade600, // Strong red color
    behavior: SnackBarBehavior.floating, // Makes it float above content
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: Duration(seconds: 3),
    elevation: 8,
  );
}

SnackBar successBar(String message, {int duration = 3}) {
  return SnackBar(
    content: Row(
      children: [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 10),
        Expanded(child: Text(message)),
      ],
    ),
    backgroundColor: Colors.green.shade600, // Strong red color
    behavior: SnackBarBehavior.floating, // Makes it float above content
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: Duration(seconds: duration),
    elevation: 8,
  );
}

Stack stack({
  required String path,
  required BuildContext context,
  required VoidCallback onCartPressed,
}) {
  return Stack(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: Image.network(
          path,
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(child: Icon(Icons.error));
          },
        ),
      ),
      // positioned allows widgets to be placed at specific positions inside the stack
      Positioned(
        bottom: 8,
        right: 8,
        child: GestureDetector(
          onTap: onCartPressed,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: const Color.fromARGB(255, 240, 255, 218),
            child: Icon(Icons.shopping_cart, color: Colors.green, size: 18),
          ),
        ),
      ),
    ],
  );
}
