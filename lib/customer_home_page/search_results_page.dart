import 'package:flutter/material.dart';
import 'package:forms/authentication/db_functions.dart';
import 'package:forms/customer_home_page/appbar.dart';
import 'package:forms/customer_home_page/product_card.dart';
import 'product_filters.dart'; // your existing filter widget file

class SearchResultsPage extends StatefulWidget {
  final List<Map<String, dynamic>> allProducts;
  final String searchQuery;

  const SearchResultsPage({
    super.key,
    required this.allProducts,
    required this.searchQuery,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  List<Map<String, dynamic>> results = [];

  ProductFilterType? _activeFilter;
  SortOrder _activeSortOrder = SortOrder.lowToHigh;

  @override
  void initState() {
    super.initState();
    _filterResults();
  }

  void _filterResults() {
    final filtered = widget.allProducts.where((product) {
      final name = (product['productName'] ?? '').toString().toLowerCase();
      return name.contains(widget.searchQuery.toLowerCase());
    }).toList();

    results = filterAndSortProducts<Map<String, dynamic>>(
      products: filtered,
      filterType: _activeFilter,
      sortOrder: _activeSortOrder,
      getPrice: (p) => p['sellingPrice'] ?? 0,
      getRating: (p) => p['rating'] ?? 0,
      getDistance: (p) => p['distance'] ?? 0,
      getDiscount: (p) => p['discountPercent'] ?? 0,
    );

    setState(() {});
  }

  void _onFilterChanged({ProductFilterType? filterType, SortOrder? sortOrder}) {
    _activeFilter = filterType;
    _activeSortOrder = sortOrder ?? SortOrder.lowToHigh;
    _filterResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Results for ${widget.searchQuery}"),
      body: SafeArea(
        child: Column(
          children: [
            // ProductFilterWidget(
            //   onFilterChanged: _onFilterChanged,
            //   initialFilter: _activeFilter,
            //   initialSortOrder: _activeSortOrder,
            // ),
            ProductFilterWidget(
              onFilterChanged: _onFilterChanged,
              initialFilter: _activeFilter,
              initialSortOrder: _activeSortOrder,
            ),

            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 cards in one row
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.65, // Adjust based on ProductCard height
                ),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final product = results[index];

                  return FutureBuilder<String?>(
                    future: getProductIdByFarmerAndName(
                      farmerId: product["farmerId"] ?? "defaultFarmerId",
                      productName: product["productName"]?.toString() ?? "",
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();

                      return ProductCard(
                        path: product["img"]?.toString() ?? "",
                        productId: snapshot.data ?? "",
                        productName: product["productName"]?.toString() ?? "",
                        harvestedDate:
                            product["harvestedDate"]?.toString() ?? "",
                        farmerId: product["farmerId"]?.toString() ?? "",
                        stock: product["stock"]?.toString() ?? "0",
                        sellingPrice:
                            product["sellingPrice"]?.toString() ?? "0",
                        discountPercent:
                            product["discountPercent"]?.toString() ?? "0",
                        unit: product["unit"]?.toString() ?? "",
                        mrp: product["mrp"]?.toString() ?? "0",
                      );
                    },
                  );
                },
              ),
            ),

            // Expanded(
            //   child: results.isEmpty
            //       ? const Center(child: Text('No products found'))
            //       : ListView.builder(
            //           itemCount: results.length,
            //           itemBuilder: (context, index) {
            //             final product = results[index];
            //             debugPrint(
            //               "farmerId: ${product["farmerId"]}, type: ${product["farmerId"]?.runtimeType}",
            //             );
            //             debugPrint(
            //               "productName: ${product["productName"]}, type: ${product["productName"]?.runtimeType}",
            //             );

            //             return FutureBuilder<String?>(
            //               future: getProductIdByFarmerAndName(
            //                 farmerId:
            //                     product["farmerId"] ??
            //                     "8qoycpzhz4hCwQ1LBikoGw8861t2",
            //                 productName: product["productName"].toString(),
            //               ),
            //               builder: (context, snapshot) {
            //                 if (!snapshot.hasData) {
            //                   return const CircularProgressIndicator(); // or SizedBox.shrink()
            //                 }

            //                 return ProductCard(
            //                   path: product["img"]?.toString() ?? "", // ✅
            //                   productId: snapshot.data ?? "", // ✅
            //                   productName:
            //                       product["productName"]?.toString() ?? "", // ✅
            //                   harvestedDate:
            //                       product["harvestedDate"]?.toString() ?? "", // ✅
            //                   farmerId:
            //                       product["farmerId"]?.toString() ?? "", // ✅
            //                   stock: product["stock"]?.toString() ?? "0", // ✅
            //                   sellingPrice:
            //                       product["sellingPrice"]?.toString() ?? "0", // ✅
            //                   discountPercent:
            //                       product["discountPercent"]?.toString() ??
            //                       "0", // ✅
            //                   unit: product["unit"]?.toString() ?? "", // ✅
            //                   mrp: product["mrp"]?.toString() ?? "0", // ✅
            //                 );
            //               },
            //             );
            //           },
            //         ),
            // ),
          ],
        ),
      ),
    );
  }
}
// ProductCard(
//                         path: product["img"],
//                         productId:
//                             getProductIdByFarmerAndName(
//                               farmerId: product["farmerId"],
//                               productName: product["productname"],
//                             ).toString(),
//                         productName: product["name"],
//                         harvestedDate: product["harvestedDate"],
//                         farmerId: product["farmerId"],
//                         stock: product["stock"],
//                         sellingPrice: product["sellingPrice"],
//                         discountPercent: product["discountPercent"],
//                         unit: product["unit"],
//                         mrp: product["mrp"],
//                       );