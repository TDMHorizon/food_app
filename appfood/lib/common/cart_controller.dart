import 'package:flutter/material.dart';

class CartItem {
  final String menuItemId;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });
}

class CartController extends ChangeNotifier {
  static final CartController _instance = CartController._internal();

  factory CartController() {
    return _instance;
  }

  CartController._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalPrice {
    double total = 0;
    for (var item in _items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  void addItem({
    required String menuItemId,
    required String name,
    required double price,
    required String imageUrl,
    required int quantity,
  }) {
    if (quantity <= 0) return;

    int index = _items.indexWhere((item) => item.menuItemId == menuItemId);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(
        menuItemId: menuItemId,
        name: name,
        price: price,
        imageUrl: imageUrl,
        quantity: quantity,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(String menuItemId, int quantity) {
    int index = _items.indexWhere((item) => item.menuItemId == menuItemId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void removeItem(String menuItemId) {
    _items.removeWhere((item) => item.menuItemId == menuItemId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
