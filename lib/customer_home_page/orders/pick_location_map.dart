import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:forms/widgets/appbar.dart';
import 'package:forms/customer_home_page/orders/order_success_page.dart';
import 'package:forms/reusables/functions.dart';
import 'package:latlong2/latlong.dart';

class PickLocationMap extends StatefulWidget {
  const PickLocationMap({super.key});

  @override
  _PickLocationMapState createState() => _PickLocationMapState();
}

class _PickLocationMapState extends State<PickLocationMap> {
  late MapController _mapController;
  LatLng selectedLocation = LatLng(20.0063398, 73.8011311); // Default location

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  Future<void> addCurrentLocation(LatLng location) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "latitude": location.latitude,
        "longitude": location.longitude,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(successBar("Location updated successfully"));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(errorBar("Failed to update location: $e"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Pick Location"),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: selectedLocation,
              initialZoom: 15,
              onPositionChanged: (MapCamera camera, bool hasGesture) {
                setState(() {
                  selectedLocation = camera.center;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=Q1XRWR3bhzhNsoP0PGls',
                tileSize: 512,
                zoomOffset: -1,
                userAgentPackageName:
                    'com.yourcompany.yourapp', // optional but recommended
              ),
            ],
          ),

          // 📍 Center fixed marker
          const Center(
            child: Icon(Icons.location_pin, color: Colors.red, size: 40),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await addCurrentLocation(selectedLocation);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => OrderSuccessPage()),
          );
        },
        label: const Text("Confirm Location"),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
