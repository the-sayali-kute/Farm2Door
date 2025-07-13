import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forms/farmer_home_page/orders/order_details_page.dart';
import 'package:forms/reusables/final_vars.dart';
import 'package:forms/reusables/functions.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:forms/widgets/appbar.dart';
import 'package:forms/customer_home_page/orders/no_orders.dart';

class FarmerOrderPage extends StatefulWidget {
  const FarmerOrderPage({super.key});

  @override
  State<FarmerOrderPage> createState() => _FarmerOrderPageState();
}

class _FarmerOrderPageState extends State<FarmerOrderPage> {
  String _sortCriteria = 'Time'; // or 'Distance'
  bool _ascending = false;
  List<QueryDocumentSnapshot> _sortedOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAndSortOrders();
  }

  Future<void> _fetchAndSortOrders() async {
    setState(() => _isLoading = true);

    final currentFarmerId = FirebaseAuth.instance.currentUser!.uid;

    // 🔹 Step 1: Get current farmer's deliveryRadius and location
    final farmerDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentFarmerId)
        .get();
    if (!farmerDoc.exists) return;

    final farmerData = farmerDoc.data()!;
    final double deliveryRadius = (farmerData['deliveryRadius'] ?? 50)
        .toDouble(); // Default to 50km if not set
    final double farmerLat = farmerData['latitude'];
    final double farmerLng = farmerData['longitude'];

    // 🔹 Step 2: Fetch all orders
    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .get();
    final allOrders = snapshot.docs;

    final List<QueryDocumentSnapshot> relevantOrders = [];

    for (final order in allOrders) {
      final items = List<Map<String, dynamic>>.from(order['items']);

      // Only check if farmer is part of this order
      final isFarmerInOrder = items.any(
        (item) => item['farmerId'] == currentFarmerId,
      );
      if (!isFarmerInOrder) continue;

      final userId = order['userId'];
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (!userDoc.exists) continue;

      final customerLat = userDoc['latitude'];
      final customerLng = userDoc['longitude'];

      final double distance =
          Geolocator.distanceBetween(
            farmerLat,
            farmerLng,
            customerLat,
            customerLng,
          ) /
          1000; // Convert to kilometers

      if (distance <= deliveryRadius) {
        relevantOrders.add(order);
      }
    }

    // 🔹 Step 3: Sort based on selected criteria
    if (_sortCriteria == 'Time') {
      relevantOrders.sort((a, b) {
        final ta = a['items'][0]['timestamp'] as Timestamp;
        final tb = b['items'][0]['timestamp'] as Timestamp;
        return _ascending ? ta.compareTo(tb) : tb.compareTo(ta);
      });
      _sortedOrders = relevantOrders;
    } else if (_sortCriteria == 'Distance') {
      final Position currentPosition = Position(
        latitude: farmerLat,
        longitude: farmerLng,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
        isMocked: false,
      );

      final List<Map<String, dynamic>> orderWithDistance = [];

      for (final order in relevantOrders) {
        final userId = order['userId'];
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        final lat = userDoc['latitude'];
        final lng = userDoc['longitude'];
        final distance = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          lat,
          lng,
        );

        orderWithDistance.add({'order': order, 'distance': distance});
      }

      orderWithDistance.sort((a, b) {
        final d1 = a['distance'] as double;
        final d2 = b['distance'] as double;
        return _ascending ? d1.compareTo(d2) : d2.compareTo(d1);
      });

      _sortedOrders = orderWithDistance
          .map((e) => e['order'] as QueryDocumentSnapshot)
          .toList();
    }

    setState(() => _isLoading = false);
  }

  String formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  Color statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.lightBlueAccent;
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.grey;
      case 'rejected':
        return Colors.red;
      default:
        return const Color.fromARGB(255, 52, 23, 180);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "My Orders"),
      body: Column(
        children: [
          _buildSortControls(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_sortedOrders.isEmpty)
            const Expanded(
              child: NoOrders(
                msg: "No orders yet!",
                showOption: false,
                showAppbar: false,
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _sortedOrders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final order = _sortedOrders[index];
                  final allItems = List<Map<String, dynamic>>.from(
                    order['items'],
                  );
                  final farmerId = FirebaseAuth.instance.currentUser!.uid;
                  final farmerItems = allItems
                      .where((item) => item['farmerId'] == farmerId)
                      .toList();
                  final timestamp = order['items'][0]['timestamp'] as Timestamp;

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Order #${order.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Placed on: ${formatTimestamp(timestamp)}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FutureBuilder<String?>(
                            future: getUserNameFromOrder(order.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text("Loading...");
                              } else if (snapshot.hasError) {
                                return const Text("Error loading user");
                              } else {
                                return Row(
                                  children: [
                                    Text(
                                      'Placed by: ',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      snapshot.data ?? "Unknown",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: gradient,
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetailsPage(
                                        item: farmerItems,
                                        orderId: order.id,
                                      ),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(150, 50),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: const Text(
                                  "View Details",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSortControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<String>(
            value: _sortCriteria,
            items: const [
              DropdownMenuItem(
                value: 'Time',
                child: Text('Sort by Time', style: TextStyle(fontSize: 16)),
              ),
              DropdownMenuItem(
                value: 'Distance',
                child: Text('Sort by Distance', style: TextStyle(fontSize: 16)),
              ),
            ],
            onChanged: (value) {
              setState(() => _sortCriteria = value!);
              _fetchAndSortOrders();
            },
          ),
          IconButton(
            icon: Icon(
              _ascending ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.black87,
            ),
            onPressed: () {
              setState(() => _ascending = !_ascending);
              _fetchAndSortOrders();
            },
          ),
        ],
      ),
    );
  }
}



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:forms/farmer_home_page/orders/order_details_page.dart';
// import 'package:forms/final_vars.dart';
// import 'package:forms/functions.dart';
// import 'package:intl/intl.dart';
// import 'package:forms/customer_home_page/appbar.dart';
// import 'package:forms/customer_home_page/orders/no_orders.dart';
// import 'dart:math';

// class FarmerOrderPage extends StatefulWidget {
//   const FarmerOrderPage({super.key});

//   @override
//   State<FarmerOrderPage> createState() => _FarmerOrderPageState();
// }

// class _FarmerOrderPageState extends State<FarmerOrderPage> {
//   String _sortCriteria = 'Time';
//   bool _ascending = false;

//   String formatTimestamp(Timestamp timestamp) {
//     final date = timestamp.toDate();
//     return DateFormat('dd MMM yyyy, hh:mm a').format(date);
//   }

//   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     const earthRadius = 6371; // in km
//     final dLat = _deg2rad(lat2 - lat1);
//     final dLon = _deg2rad(lon2 - lon1);

//     final a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
//             sin(dLon / 2) * sin(dLon / 2);
//     final c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     return earthRadius * c;
//   }

//   double _deg2rad(double deg) => deg * pi / 180.0;

//   Future<List<QueryDocumentSnapshot>> getSortedOrders(
//       List<QueryDocumentSnapshot> allOrders,
//       String currentFarmerId,
//       Map<String, dynamic> farmerLocation) async {
//     final relevantOrders = allOrders.where((order) {
//       final items = List<Map<String, dynamic>>.from(order['items']);
//       return items.any((item) => item['farmerId'] == currentFarmerId);
//     }).toList();

//     if (_sortCriteria == 'Time') {
//       relevantOrders.sort((a, b) {
//         final aTime = a['items'][0]['timestamp'] as Timestamp;
//         final bTime = b['items'][0]['timestamp'] as Timestamp;
//         return _ascending ? aTime.compareTo(bTime) : bTime.compareTo(aTime);
//       });
//     } else if (_sortCriteria == 'Distance') {
//       relevantOrders.sort((a, b) {
//         final aLat = a['address']['latitude'];
//         final aLng = a['address']['longitude'];
//         final bLat = b['address']['latitude'];
//         final bLng = b['address']['longitude'];

//         final aDist = calculateDistance(
//             farmerLocation['latitude'], farmerLocation['longitude'], aLat, aLng);
//         final bDist = calculateDistance(
//             farmerLocation['latitude'], farmerLocation['longitude'], bLat, bLng);

//         return _ascending ? aDist.compareTo(bDist) : bDist.compareTo(aDist);
//       });
//     }

//     return relevantOrders;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentFarmerId = FirebaseAuth.instance.currentUser!.uid;

//     return Scaffold(
//       appBar: appBar(context, title: "My Orders"),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 DropdownButton<String>(
//                   value: _sortCriteria,
//                   items: const [
//                     DropdownMenuItem(value: 'Time', child: Text('Sort by Time',style: TextStyle(fontSize: 16),)),
//                     DropdownMenuItem(
//                         value: 'Distance', child: Text('Sort by Distance',style: TextStyle(fontSize: 16),)),
//                   ],
//                   onChanged: (value) {
//                     setState(() {
//                       _sortCriteria = value!;
//                     });
//                   },
//                 ),
//                 IconButton(
//                   icon: Icon(
//                     _ascending ? Icons.arrow_upward : Icons.arrow_downward,
//                     color: Colors.black87,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _ascending = !_ascending;
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream:
//                   FirebaseFirestore.instance.collection('orders').snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return NoOrders(msg: "No orders yet!", showOption: false);
//                 }

//                 return FutureBuilder<DocumentSnapshot>(
//                   future: FirebaseFirestore.instance
//                       .collection('users')
//                       .doc(currentFarmerId)
//                       .get(),
//                   builder: (context, farmerSnapshot) {
//                     if (!farmerSnapshot.hasData ||
//                         !farmerSnapshot.data!.exists) {
//                       return const Center(child: Text('Unable to fetch location'));
//                     }

//                     final farmerData = farmerSnapshot.data!.data() as Map<String, dynamic>;
//                     final farmerLocation = {
//                       'latitude': farmerData['latitude'],
//                       'longitude': farmerData['longitude']
//                     };

//                     return FutureBuilder<List<QueryDocumentSnapshot>>(
//                       future: getSortedOrders(
//                           snapshot.data!.docs, currentFarmerId, farmerLocation),
//                       builder: (context, sortedSnapshot) {
//                         if (!sortedSnapshot.hasData ||
//                             sortedSnapshot.data!.isEmpty) {
//                           return NoOrders(msg: "No orders yet!", showOption: false);
//                         }

//                         final sortedOrders = sortedSnapshot.data!;
//                         return ListView.separated(
//                           padding: const EdgeInsets.all(16),
//                           itemCount: sortedOrders.length,
//                           separatorBuilder: (_, __) => const SizedBox(height: 16),
//                           itemBuilder: (context, index) {
//                             final order = sortedOrders[index];
//                             final allItems =
//                                 List<Map<String, dynamic>>.from(order['items']);
//                             final farmerItems = allItems
//                                 .where((item) =>
//                                     item['farmerId'] == currentFarmerId)
//                                 .toList();
//                             final timestamp =
//                                 order['items'][0]['timestamp'] as Timestamp;

//                             return Card(
//                               elevation: 3,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(16),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Text(
//                                           'Order #${order.id}',
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 16,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       'Placed on: ${formatTimestamp(timestamp)}',
//                                       style: TextStyle(
//                                           color: Colors.grey[700], fontSize: 13),
//                                     ),
//                                     const SizedBox(height: 10),
//                                     FutureBuilder<String?>(
//                                       future: getUserNameFromOrder(order.id),
//                                       builder: (context, snapshot) {
//                                         if (snapshot.connectionState ==
//                                             ConnectionState.waiting) {
//                                           return const Text("Loading...");
//                                         } else if (snapshot.hasError) {
//                                           return const Text("Error loading user");
//                                         } else if (!snapshot.hasData ||
//                                             snapshot.data == null) {
//                                           return const Text("Unknown user");
//                                         } else {
//                                           return Row(
//                                             children: [
//                                               Text(
//                                                 'Placed by: ',
//                                                 style: TextStyle(
//                                                   color: Colors.grey[700],
//                                                   fontSize: 13,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 '${snapshot.data}',
//                                                 style: const TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 13,
//                                                 ),
//                                               ),
//                                             ],
//                                           );
//                                         }
//                                       },
//                                     ),
//                                     const SizedBox(height: 10),
//                                     Center(
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(18),
//                                           gradient: gradient,
//                                         ),
//                                         child: TextButton(
//                                           onPressed: () async {
//                                             Navigator.of(context).push(
//                                               MaterialPageRoute(
//                                                 builder: (context) {
//                                                   return OrderDetailsPage(
//                                                     item: farmerItems,
//                                                     orderId: order.id,
//                                                   );
//                                                 },
//                                               ),
//                                             );
//                                           },
//                                           style: TextButton.styleFrom(
//                                             minimumSize: const Size(150, 50),
//                                             backgroundColor: Colors.transparent,
//                                             shadowColor: Colors.transparent,
//                                           ),
//                                           child: const Text(
//                                             "View Details",
//                                             style: TextStyle(
//                                               fontSize: 15,
//                                               fontWeight: FontWeight.bold,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:forms/farmer_home_page/orders/order_details_page.dart';
// import 'package:forms/final_vars.dart';
// import 'package:forms/functions.dart';
// import 'package:intl/intl.dart';
// import 'package:forms/customer_home_page/appbar.dart';
// import 'package:forms/customer_home_page/orders/no_orders.dart';

// class FarmerOrderPage extends StatelessWidget {
//   const FarmerOrderPage({super.key});
//   Color statusColor(String status) {
//     switch (status) {
//       case 'completed':
//         return Colors.lightBlueAccent;
//       case 'accepted':
//         return Colors.green;
//       case 'pending':
//         return Colors.grey;
//       case 'rejected':
//         return Colors.red;
//       default:
//         return const Color.fromARGB(255, 52, 23, 180);
//     }
//   }

//   String formatTimestamp(Timestamp timestamp) {
//     final date = timestamp.toDate();
//     return DateFormat('dd MMM yyyy, hh:mm a').format(date);
//   }



//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('orders').snapshots(),

//       builder: (context, snapshot) {
//         final currentFarmerId = FirebaseAuth.instance.currentUser!.uid;

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return NoOrders(msg: "No orders yet!",showOption: false,);
//         }

//         final allOrders = snapshot.data!.docs;

//         final relevantOrders = allOrders.where((order) {
//           final items = List<Map<String, dynamic>>.from(order['items']);
//           return items.any((item) => item['farmerId'] == currentFarmerId);
//         }).toList();

//         if (relevantOrders.isEmpty) {
//           return NoOrders(msg: "No orders yet!",showOption:false);
//         }

//         return Scaffold(
//           appBar: appBar(context, title: "My Orders"),
//           body: ListView.separated(
//             padding: const EdgeInsets.all(16),
//             itemCount: relevantOrders.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 16),
//             itemBuilder: (context, index) {
//               final order = relevantOrders[index];
//               final allItems = List<Map<String, dynamic>>.from(order['items']);
//               final currentFarmerId = FirebaseAuth.instance.currentUser!.uid;
//               final farmerItems = allItems
//                   .where((item) => item['farmerId'] == currentFarmerId)
//                   .toList();
//               final timestamp = order['items'][0]['timestamp'] as Timestamp;
//               // debugPrint(order.data().toString());

//               return Card(
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Order ID
//                       Row(
//                         children: [
//                           Text(
//                             'Order #${order.id}',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       // Timestamp of order
//                       Text(
//                         'Placed on: ${formatTimestamp(timestamp)}',
//                         style: TextStyle(color: Colors.grey[700], fontSize: 13),
//                       ),
//                       SizedBox(height: 10),
//                       FutureBuilder<String?>(
//                         future: getUserNameFromOrder(
//                           order.id,
//                         ), // <-- Call your async function here
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return const Text("Loading...");
//                           } else if (snapshot.hasError) {
//                             return const Text("Error loading user");
//                           } else if (!snapshot.hasData ||
//                               snapshot.data == null) {
//                             return const Text("Unknown user");
//                           } else {
//                             return Row(
//                               children: [
//                                 Text(
//                                   'Placed by: ',
//                                   style: TextStyle(
//                                     color: Colors.grey[700],
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                                 Text(
//                                   '${snapshot.data}',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                               ],
//                             );
//                           }
//                         },
//                       ),
//                       SizedBox(height: 10),
//                       Center(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(18),
//                             gradient: gradient,
//                           ),
//                           child: TextButton(
//                             onPressed: () async {
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                   builder: (context) {
//                                     return OrderDetailsPage(item: farmerItems,orderId:order.id);
//                                   },
//                                 ),
//                               );
//                             },
//                             style: TextButton.styleFrom(
//                               minimumSize: Size(150, 50),
//                               backgroundColor: Colors.transparent,
//                               shadowColor: Colors.transparent,
//                             ),
//                             child: Text(
//                               "View Details",
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }


// // Row(
//                       //   children: [
//                       //     const Text(
//                       //       'Total:',
//                       //       style: TextStyle(
//                       //         fontWeight: FontWeight.bold,
//                       //         fontSize: 15,
//                       //       ),
//                       //     ),
//                       //     const Spacer(),
//                       //     Text(
//                       //       '₹ ${(order['totalAmount'] as num).toStringAsFixed(2)}',
//                       //       style: const TextStyle(
//                       //         fontWeight: FontWeight.bold,
//                       //         fontSize: 16,
//                       //         color: Colors.green,
//                       //       ),
//                       //     ),
//                       //   ],
//                       // ),
// //farmer_order_page.dart
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:forms/farmer_home_page/orders/order_details_page.dart';
// // import 'package:forms/final_vars.dart';
// // import 'package:forms/functions.dart';
// // import 'package:intl/intl.dart';
// // import 'package:forms/customer_home_page/appbar.dart';
// // import 'package:forms/customer_home_page/orders/no_orders.dart';

// // class FarmerOrderPage extends StatelessWidget {
// //   const FarmerOrderPage({super.key});
// //   Color statusColor(String status) {
// //     switch (status) {
// //       case 'completed':
// //         return Colors.lightBlueAccent;
// //       case 'accepted':
// //         return Colors.green;
// //       case 'pending':
// //         return Colors.grey;
// //       case 'rejected':
// //         return Colors.red;
// //       default:
// //         return const Color.fromARGB(255, 52, 23, 180);
// //     }
// //   }

// //   String formatTimestamp(Timestamp timestamp) {
// //     final date = timestamp.toDate();
// //     return DateFormat('dd MMM yyyy, hh:mm a').format(date);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return FutureBuilder<QuerySnapshot>(
// //       future: FirebaseFirestore.instance.collection('orders').get(),

// //       builder: (context, snapshot) {
// //         final currentFarmerId = FirebaseAuth.instance.currentUser!.uid;
// //         final allOrders = snapshot.data!.docs;

// //         final relevantOrders = allOrders.where((order) {
// //           final items = List<Map<String, dynamic>>.from(order['items']);
// //           return items.any((item) => item['farmerId'] == currentFarmerId);
// //         }).toList();

// //         if (relevantOrders.isEmpty) {
// //           return NoOrders(msg: "No orders yet!",showOption:false);
// //         }

// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Center(child: CircularProgressIndicator());
// //         }

// //         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //           return NoOrders(msg: "No orders yet!",showOption: false,);
// //         }

// //         return Scaffold(
// //           appBar: appBar(context, title: "My Orders"),
// //           body: ListView.separated(
// //             padding: const EdgeInsets.all(16),
// //             itemCount: relevantOrders.length,
// //             separatorBuilder: (_, __) => const SizedBox(height: 16),
// //             itemBuilder: (context, index) {
// //               final order = relevantOrders[index];
// //               final allItems = List<Map<String, dynamic>>.from(order['items']);
// //               final currentFarmerId = FirebaseAuth.instance.currentUser!.uid;
// //               final farmerItems = allItems
// //                   .where((item) => item['farmerId'] == currentFarmerId)
// //                   .toList();
// //               final timestamp = order['items'][0]['timestamp'] as Timestamp;
// //               // debugPrint(order.data().toString());

// //               return Card(
// //                 elevation: 3,
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(16),
// //                 ),
// //                 child: Padding(
// //                   padding: const EdgeInsets.all(16),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       // Order ID
// //                       Row(
// //                         children: [
// //                           Text(
// //                             'Order #${order.id}',
// //                             style: const TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: 16,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 8),
// //                       // Timestamp of order
// //                       Text(
// //                         'Placed on: ${formatTimestamp(timestamp)}',
// //                         style: TextStyle(color: Colors.grey[700], fontSize: 13),
// //                       ),
// //                       SizedBox(height: 10),
// //                       FutureBuilder<String?>(
// //                         future: getUserNameFromOrder(
// //                           order.id,
// //                         ), // <-- Call your async function here
// //                         builder: (context, snapshot) {
// //                           if (snapshot.connectionState ==
// //                               ConnectionState.waiting) {
// //                             return const Text("Loading...");
// //                           } else if (snapshot.hasError) {
// //                             return const Text("Error loading user");
// //                           } else if (!snapshot.hasData ||
// //                               snapshot.data == null) {
// //                             return const Text("Unknown user");
// //                           } else {
// //                             return Row(
// //                               children: [
// //                                 Text(
// //                                   'Placed by: ',
// //                                   style: TextStyle(
// //                                     color: Colors.grey[700],
// //                                     fontSize: 13,
// //                                   ),
// //                                 ),
// //                                 Text(
// //                                   '${snapshot.data}',
// //                                   style: TextStyle(
// //                                     fontWeight: FontWeight.bold,
// //                                     fontSize: 13,
// //                                   ),
// //                                 ),
// //                               ],
// //                             );
// //                           }
// //                         },
// //                       ),
// //                       SizedBox(height: 10),
// //                       Center(
// //                         child: Container(
// //                           decoration: BoxDecoration(
// //                             borderRadius: BorderRadius.circular(18),
// //                             gradient: gradient,
// //                           ),
// //                           child: TextButton(
// //                             onPressed: () async {
// //                               Navigator.of(context).push(
// //                                 MaterialPageRoute(
// //                                   builder: (context) {
// //                                     return OrderDetailsPage(item: farmerItems,orderId:order.id);
// //                                   },
// //                                 ),
// //                               );
// //                             },
// //                             style: TextButton.styleFrom(
// //                               minimumSize: Size(150, 50),
// //                               backgroundColor: Colors.transparent,
// //                               shadowColor: Colors.transparent,
// //                             ),
// //                             child: Text(
// //                               "View Details",
// //                               style: TextStyle(
// //                                 fontSize: 15,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.white,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               );
// //             },
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }


// // Row(
//                       //   children: [
//                       //     const Text(
//                       //       'Total:',
//                       //       style: TextStyle(
//                       //         fontWeight: FontWeight.bold,
//                       //         fontSize: 15,
//                       //       ),
//                       //     ),
//                       //     const Spacer(),
//                       //     Text(
//                       //       '₹ ${(order['totalAmount'] as num).toStringAsFixed(2)}',
//                       //       style: const TextStyle(
//                       //         fontWeight: FontWeight.bold,
//                       //         fontSize: 16,
//                       //         color: Colors.green,
//                       //       ),
//                       //     ),
//                       //   ],
//                       // ),