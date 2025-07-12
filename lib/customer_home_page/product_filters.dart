import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

/// Enum for filter types
enum ProductFilterType { price, distance, rating, discount}

/// Enum for sort order
enum SortOrder { lowToHigh, highToLow }

/// Callback signature for filter/sort changes
typedef ProductFilterCallback = void Function({
  ProductFilterType? filterType,
  SortOrder? sortOrder,
});

/// Widget for filtering and sorting products
class ProductFilterWidget extends StatefulWidget {
  final ProductFilterCallback onFilterChanged;
  final ProductFilterType? initialFilter;
  final SortOrder initialSortOrder;

  const ProductFilterWidget({
    super.key,
    required this.onFilterChanged,
    this.initialFilter,
    this.initialSortOrder = SortOrder.lowToHigh,
  });

  @override
  State<ProductFilterWidget> createState() => _ProductFilterWidgetState();
}

class _ProductFilterWidgetState extends State<ProductFilterWidget> {
  ProductFilterType? _selectedFilter;
  SortOrder _selectedSortOrder = SortOrder.lowToHigh;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    _selectedSortOrder = widget.initialSortOrder;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Filter Dropdown
        DropdownButton<ProductFilterType>(
          value: _selectedFilter,
          hint: const Text('Filter by',style: TextStyle(fontSize: 16),),
          style: TextStyle(fontSize: 16, color: Colors.black),
          items: const [
            DropdownMenuItem(
              value: ProductFilterType.price,
              child: Text('Price'),
            ),
            DropdownMenuItem(
              value: ProductFilterType.distance,
              child: Text('Distance'),
            ),
            DropdownMenuItem(
              value: ProductFilterType.rating,
              child: Text('Rating'),
            ),
            DropdownMenuItem(
              value: ProductFilterType.discount,
              child: Text('Discount'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedFilter = value;
            });
            widget.onFilterChanged(
              filterType: _selectedFilter,
              sortOrder: _selectedSortOrder,
            );
          },
        ),
        // Sort Order Toggle Button
        Row(
          children: [
            const Text('Sort:',style: TextStyle(fontSize: 10),),
            const SizedBox(width: 8),
            ToggleButtons(
              isSelected: [
                _selectedSortOrder == SortOrder.lowToHigh,
                _selectedSortOrder == SortOrder.highToLow,
              ],
              onPressed: (index) {
                setState(() {
                  _selectedSortOrder =
                      index == 0 ? SortOrder.lowToHigh : SortOrder.highToLow;
                });
                widget.onFilterChanged(
                  filterType: _selectedFilter,
                  sortOrder: _selectedSortOrder,
                );
              },
              children: const [
                Text('Lower to Higher',style: TextStyle(fontSize: 10),),
                Text('Higher to Lower',style: TextStyle(fontSize: 10),),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Backend integration: Fetch products from Firestore with filter and sort
///
/// Usage:
///   Call fetchFilteredProducts with the selected filter and sort order.
///   For distance, you must provide the user's location and product locations.
Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchFilteredProducts({
  ProductFilterType? filterType,
  SortOrder sortOrder = SortOrder.lowToHigh,
  // For distance filtering, pass user's location and implement logic as needed
  double? userLat,
  double? userLng,
}) async {
  Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('products');

  // For Firestore, sorting is done with orderBy
  String? orderByField;
  bool descending = sortOrder == SortOrder.highToLow;

  switch (filterType) {
    case ProductFilterType.price:
      orderByField = 'sellingPrice';
      break;
    case ProductFilterType.discount:
      orderByField = 'discountPercent';
      break;
    case ProductFilterType.rating:
      orderByField = 'rating'; // Ensure this field exists in Firestore
      break;
    case ProductFilterType.distance:
      // Firestore does not support geo queries natively; you must fetch all and sort/filter in Dart
      // Placeholder: fetch all, then sort by distance in Dart
      orderByField = null;
      break;
    default:
      orderByField = 'sellingPrice';
  }

  if (orderByField != null) {
    query = query.orderBy(orderByField, descending: descending);
  }

  final snapshot = await query.get();
  List<QueryDocumentSnapshot<Map<String, dynamic>>> products = snapshot.docs;

  // For distance, sort in Dart if user location is provided
  if (filterType == ProductFilterType.distance && userLat != null && userLng != null) {
    products.sort((a, b) {
      double aLat = a['latitude'] ?? 0.0;
      double aLng = a['longitude'] ?? 0.0;
      double bLat = b['latitude'] ?? 0.0;
      double bLng = b['longitude'] ?? 0.0;
      double aDist = _calculateDistance(userLat, userLng, aLat, aLng);
      double bDist = _calculateDistance(userLat, userLng, bLat, bLng);
      return sortOrder == SortOrder.lowToHigh
          ? aDist.compareTo(bDist)
          : bDist.compareTo(aDist);
    });
  }

  return products;
}

/// Haversine formula for distance between two lat/lng points
/// Returns distance in kilometers
double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double R = 6371; // Radius of the earth in km
  double dLat = _deg2rad(lat2 - lat1);
  double dLon = _deg2rad(lon2 - lon1);
  double a =
      (sin(dLat / 2) * sin(dLat / 2)) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
          (sin(dLon / 2) * sin(dLon / 2));
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = R * c;
  return distance;
}

double _deg2rad(double deg) {
  return deg * (3.1415926535897932 / 180.0);
}

/// Example filter/sort function for a product list
///
/// Call this function with your product list and the selected filter/sort options.
List<T> filterAndSortProducts<T>({
  required List<T> products,
  ProductFilterType? filterType,
  SortOrder sortOrder = SortOrder.lowToHigh,
  required num Function(T) getPrice,
  required num Function(T) getDistance,
  required num Function(T) getRating,
  required num Function(T) getDiscount,
  }) {
  List<T> filtered = List<T>.from(products);

  // Sort based on selected filter
  int compare(T a, T b) {
    num aValue, bValue;
    switch (filterType) {
      case ProductFilterType.price:
        aValue = getPrice(a);
        bValue = getPrice(b);
        break;
      case ProductFilterType.distance:
        aValue = getDistance(a);
        bValue = getDistance(b);
        break;
      case ProductFilterType.rating:
        aValue = getRating(a);
        bValue = getRating(b);
        break;
      case ProductFilterType.discount:
        aValue = getDiscount(a);
        bValue = getDiscount(b);
        break;
      default:
        aValue = getPrice(a);
        bValue = getPrice(b);
    }
    return sortOrder == SortOrder.lowToHigh
        ? aValue.compareTo(bValue)
        : bValue.compareTo(aValue);
  }

  filtered.sort(compare);
  return filtered;
}