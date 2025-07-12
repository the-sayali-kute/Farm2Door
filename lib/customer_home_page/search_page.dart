/*import 'package:flutter/material.dart';
import 'package:forms/authentication/db_functions.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> products = [];
  final SearchController searchController = SearchController();

  @override
  void initState() {
    super.initState();
    getProductNames()!.then((value){
      setState(() {
        products = value.map((e)=>e["name"]).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextSelectionTheme(
        data: const TextSelectionThemeData(cursorColor: Colors.black),
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                SearchAnchor.bar(
                  searchController: searchController,
                  barHintText: 'Search fruits...',
                  barLeading: const Icon(Icons.search),
                  barElevation: const WidgetStatePropertyAll(0),
                  barShape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onTap: () {
                    // Intentionally left empty to avoid opening full screen
                  },
                  suggestionsBuilder: (context, controller) {
                    final query = controller.text.toLowerCase();
                    final filtered = products
                        .where((product) =>
                            product.toLowerCase().contains(query))
                        .toList();

                    if (query.isEmpty) return const [];

                    return List.generate(filtered.length, (index) {
                      return ListTile(
                        title: Text(filtered[index]),
                        onTap: () {
                          controller.closeView(filtered[index]);
                          controller.text = filtered[index];
                          setState(() {});
                        },
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}*/

//revised code with integrated search filters

// import 'package:flutter/material.dart';
// import 'package:forms/authentication/db_functions.dart';
// import 'package:forms/customer_home_page/product_filters.dart';
// import 'package:geolocator/geolocator.dart';
// import 'dart:math';

// class SearchPage extends StatefulWidget {
//   const SearchPage({super.key});

//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {
//   List<Map<String, dynamic>> products = [];
//   List<Map<String, dynamic>> filteredProducts = [];
//   final SearchController searchController = SearchController();

//   ProductFilterType? _activeFilter;
//   SortOrder _activeSortOrder = SortOrder.lowToHigh;

//   @override
//   void initState() {
//     super.initState();
//     _loadProducts();
//   }

//   Future<void> _loadProducts() async {
//     final fetched =
//         await getProductNames(); // Expects List<Map<String, dynamic>>
//     if (fetched == null) return;

//     List<Map<String, dynamic>> loaded = List<Map<String, dynamic>>.from(
//       fetched,
//     );

//     // Optional: Add distance if needed
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );

//     for (var product in loaded) {
//       double lat = product['latitude'] ?? 0.0;
//       double lng = product['longitude'] ?? 0.0;
//       product['distance'] = _calculateDistance(
//         position.latitude,
//         position.longitude,
//         lat,
//         lng,
//       );
//     }

//     setState(() {
//       products = loaded;
//       filteredProducts = List.from(products); // Initially no filters
//     });
//   }

//   void _onFilterChanged({ProductFilterType? filterType, SortOrder? sortOrder}) {
//     setState(() {
//       _activeFilter = filterType;
//       _activeSortOrder = sortOrder ?? SortOrder.lowToHigh;

//       filteredProducts = filterAndSortProducts<Map<String, dynamic>>(
//         products: products,
//         filterType: _activeFilter,
//         sortOrder: _activeSortOrder,
//         getPrice: (p) => p['sellingPrice'] ?? 0,
//         getRating: (p) => p['rating'] ?? 0,
//         getDistance: (p) => p['distance'] ?? 0,
//         getDiscount: (p) => p['discountPercent'] ?? 0,
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: TextSelectionTheme(
//         data: const TextSelectionThemeData(cursorColor: Colors.black),
//         child: SafeArea(
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 20),
//             child: Column(
//               children: [
//                 /// 🔍 Search Bar
//                 SearchAnchor.bar(
//                   searchController: searchController,
//                   barHintText: 'Search fruits...',
//                   barLeading: const Icon(Icons.search),
//                   barElevation: const WidgetStatePropertyAll(0),
//                   barShape: WidgetStatePropertyAll(
//                     RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   onTap: () {},
//                   suggestionsBuilder: (context, controller) {
//                     final query = controller.text.toLowerCase().trim();

//                     if (query.isEmpty) return const [];

//                     final results = filteredProducts.where((product) {
//                       final name = (product['productName'] ?? '')
//                           .toString()
//                           .toLowerCase();
//                       return name.contains(query);
//                     }).toList();

//                     if (results.isEmpty) {
//                       return [
//                         const ListTile(title: Text('No matching products')),
//                       ];
//                     }

//                     return results.map((product) {
//                       return ListTile(
//                         title: Text(product['productName'] ?? 'Unnamed'),
//                         subtitle: Text(
//                           "Price: ₹${product['sellingPrice'] ?? 'N/A'}",
//                         ),
//                         onTap: () {
//                           controller.closeView(product['productName']);
//                           controller.text = product['productName'];
//                           // Optional: Trigger filter or detail page
//                           setState(() {});
//                         },
//                       );
//                     }).toList();
//                   },
//                 ),
//                 const SizedBox(height: 20),

//                 /// 🔍 Filter Widget
//                 ProductFilterWidget(
//                   onFilterChanged: _onFilterChanged,
//                   initialFilter: _activeFilter,
//                   initialSortOrder: _activeSortOrder,
//                 ),
//                 const SizedBox(height: 10),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   /// 📍 Utility to calculate distance
//   double _calculateDistance(
//     double lat1,
//     double lon1,
//     double lat2,
//     double lon2,
//   ) {
//     const double R = 6371; // Radius of the earth in km
//     double dLat = _deg2rad(lat2 - lat1);
//     double dLon = _deg2rad(lon2 - lon1);
//     double a =
//         (sin(dLat / 2) * sin(dLat / 2)) +
//         cos(_deg2rad(lat1)) *
//             cos(_deg2rad(lat2)) *
//             (sin(dLon / 2) * sin(dLon / 2));
//     double c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     return R * c;
//   }

//   double _deg2rad(double deg) {
//     return deg * (3.1415926535897932 / 180.0);
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forms/authentication/db_functions.dart';
import 'package:forms/customer_home_page/search_results_page.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math'; // ⬅️ Import this

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> products = [];
  final SearchController searchController = SearchController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final fetched = await getProductNames(); // List<Map<String, dynamic>>
    if (fetched == null) return;

    List<Map<String, dynamic>> loaded = List<Map<String, dynamic>>.from(
      fetched,
    );

    // Get current user location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Fetch farmer lat/lng for each product
    for (var product in loaded) {
      try {
        final farmerId = product['farmerId'];
        if (farmerId == null) {
          product['distance'] = double.infinity;
          continue;
        }

        final farmerSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(farmerId)
            .get();

        if (farmerSnapshot.exists) {
          final farmerData = farmerSnapshot.data();
          final lat = farmerData?['latitude'];
          final lng = farmerData?['longitude'];

          if (lat != null && lng != null) {
            product['distance'] = _calculateDistance(
              position.latitude,
              position.longitude,
              lat,
              lng,
            );
          } else {
            product['distance'] = double.infinity;
          }
        } else {
          product['distance'] = double.infinity;
        }
      } catch (e) {
        debugPrint("Error getting farmer location: $e");
        product['distance'] = double.infinity;
      }
    }

    setState(() {
      products = loaded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextSelectionTheme(
        data: const TextSelectionThemeData(cursorColor: Colors.black),
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                SearchAnchor.bar(
                  searchController: searchController,
                  barHintText: 'Search fruits...',
                  barLeading: const Icon(Icons.search),
                  barElevation: const WidgetStatePropertyAll(0),
                  barShape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  suggestionsBuilder: (context, controller) {
                    final query = controller.text.toLowerCase().trim();
                    if (query.isEmpty) return const [];

                    final results = products.where((product) {
                      final name = (product['productName'] ?? '')
                          .toString()
                          .toLowerCase();
                      return name.contains(query);
                    }).toList();

                    if (results.isEmpty) {
                      return [
                        const ListTile(title: Text('No matching products')),
                      ];
                    }

                    return results.map((product) {
                      return ListTile(
                        title: Text(product['productName'] ?? 'Unnamed'),
                        subtitle: Text("₹${product['sellingPrice'] ?? 'N/A'}"),
                        onTap: () {
                          controller.closeView(product['productName']);
                          controller.text = product['productName'];

                          // ⬇️ Navigate to results page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SearchResultsPage(
                                allProducts: products,
                                searchQuery: product['productName'],
                              ),
                            ),
                          );
                        },
                      );
                    }).toList();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double R = 6371; // km
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);
    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) {
    return deg * (pi / 180);
  }
}



// SearchAnchor(
                //   searchController: searchController,
                //   builder: (BuildContext context, SearchController controller) {
                //     return SearchBar(
                //       controller: controller,
                //       hintText: "Search fruits...",
                //       leading: Icon(Icons.search),
                //       elevation: WidgetStateProperty.all(0), // No shadow on tap
                //       constraints: BoxConstraints(
                //         minHeight: 70,
                //       ), // Fix height to avoid expansion
                //       shape: MaterialStatePropertyAll(
                //         RoundedRectangleBorder(
                //           // Consistent shape
                //           borderRadius: BorderRadius.circular(20),
                //         ),
                //       ),
                //       onTap: () {
                //         controller.openView();
                //       },
                //       // focusNode: FocusNode(),
                //     );
                //   },
                //   suggestionsBuilder:
                //       (BuildContext context, SearchController controller) {
                //         final query = controller.text.toLowerCase();
                //         final filtered = fruits
                //             .where((fruit) => fruit.toLowerCase().contains(query))
                //             .toList();
                //         if (query.isEmpty) {
                //           return const [];
                //         }
                //         return List<Widget>.generate(filtered.length, (index) {
                //           return ListTile(
                //             title: Text(filtered[index]),
                //             onTap: () {
                //               controller.closeView(filtered[index]);
                //               controller.text = filtered[index];
                //               setState(() {});
                //             },
                //           );
                //         });
                //       },
                // ),