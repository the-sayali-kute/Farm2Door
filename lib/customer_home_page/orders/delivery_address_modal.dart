import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:forms/customer_home_page/orders/order_success_page.dart';
import 'package:forms/customer_home_page/orders/pick_location_map.dart';
import 'package:forms/reusables/functions.dart';
import 'package:geolocator/geolocator.dart';

class DeliveryAddressModal extends StatefulWidget {
  const DeliveryAddressModal({super.key});

  @override
  State<DeliveryAddressModal> createState() => _DeliveryAddressModalState();
}

class _DeliveryAddressModalState extends State<DeliveryAddressModal> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserAddress();
  }

  Future<void> fetchUserAddress() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists) {
      setState(() {
        userData = doc.data();
        isLoading = false;
      });
    }
  }

  Future<void> useCurrentLocation() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    Position? position = await fetchLocation();
    if (position != null) {
      FirebaseFirestore.instance.collection("users").doc(uid).set(
        {"latitude": position.latitude, "longitude": position.longitude},
        SetOptions(
          merge: true,
        ), // Only update the provided fields in the document without deleting the existing ones.
      );
      // ignore: use_build_context_synchronously
      Navigator.maybePop(context);

      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(successBar("Location updated successfully"));
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) {
            return OrderSuccessPage();
          },
        ),
      );
    }else{
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(errorBar("Failed to update location"));
    }
  }

  Future<void> pickLocationOnMap() async {
    final pickedLatLng = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PickLocationMap()),
    );
    if (pickedLatLng != null) {
      Navigator.pop(context, pickedLatLng); // Return picked lat/lng
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Delivery Address',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_pin, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${userData?['name'] ?? ''}, ${userData?['phone'] ?? ''}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(userData?['address'] ?? ''),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text("HOME", style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const Divider(height: 32),
                ElevatedButton.icon(
                  onPressed: useCurrentLocation,
                  icon: const Icon(Icons.gps_fixed),
                  label: const Text("Use my current location"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    elevation: 0,
                    side: const BorderSide(color: Colors.blue),
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: pickLocationOnMap,
                  icon: const Icon(Icons.map),
                  label: const Text("Pick location on map"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            ),
    );
  }
}
