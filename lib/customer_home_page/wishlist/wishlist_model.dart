class WishlistItem {
  final String name;
  final String imagePath;
  final String price;
  final String weight;
  final String mrp;
  final String rating;

  WishlistItem({
    required this.name,
    required this.imagePath,
    required this.price,
    required this.weight,
    required this.mrp,
    required this.rating,
  });
}

class Wishlist {
  static final List<WishlistItem> _items = [];

  static List<WishlistItem> get items => _items;

  static void addItem(WishlistItem item) {
    // Optional: Prevent duplicates
    if (!_items.any((element) => element.name == item.name)) {
      _items.add(item);
    }
  }

  static void removeItem(String name) {
    _items.removeWhere((item) => item.name == name);
  }
}