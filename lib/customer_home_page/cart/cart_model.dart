class CartItem {
  final String name;
  final String price;
  final String weight;
  final String imagePath;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.weight,
    required this.imagePath,
    this.quantity = 1,
  });
}

class Cart {
  static final List<CartItem> _items = [];

  static List<CartItem> get items => _items;

  static void addItem(CartItem newItem) {
    final index = _items.indexWhere((item) => item.name == newItem.name);
    if (index != -1) {
      _items[index].quantity += 1;
    } else {
      _items.add(newItem);
    }
  }

  static void removeItem(CartItem item) {
    _items.remove(item);
  }

  static void clear() {
    _items.clear();
  }
}
