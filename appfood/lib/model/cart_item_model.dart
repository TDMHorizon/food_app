import 'package:flutter/foundation.dart';
import 'menu_item_model.dart';

// CartItem: gộp MenuItem + số lượng
class CartItem {
  final MenuItemModel item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});

  double get subtotal => item.price * quantity;
}

// CartManager: Singleton + ChangeNotifier để cập nhật UI tự động
class CartManager extends ChangeNotifier {
  // Singleton instance
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final List<CartItem> _items = [];
  String _restaurantId = "";
  String _restaurantName = "";

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  String get restaurantName => _restaurantName;
  bool get isEmpty => _items.isEmpty;
  int get totalQuantity => _items.fold(0, (sum, e) => sum + e.quantity);

  double get subtotal => _items.fold(0.0, (sum, e) => sum + e.subtotal);
  double get deliveryFee => subtotal > 150000 ? 0 : 15000;
  double get total => subtotal + deliveryFee;

  // Thêm món vào giỏ
  // Nếu khác nhà hàng → xoá giỏ cũ, thêm mới
  void addItem(MenuItemModel item, String restaurantId, String restaurantName) {
    if (_restaurantId != restaurantId && _items.isNotEmpty) {
      _items.clear();
    }
    _restaurantId = restaurantId;
    _restaurantName = restaurantName;

    final existing = _items.where((e) => e.item.id == item.id);
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      _items.add(CartItem(item: item));
    }
    notifyListeners();
  }

  void removeItem(String itemId) {
    _items.removeWhere((e) => e.item.id == itemId);
    if (_items.isEmpty) _restaurantId = "";
    notifyListeners();
  }

  void decreaseItem(String itemId) {
    final idx = _items.indexWhere((e) => e.item.id == itemId);
    if (idx == -1) return;
    if (_items[idx].quantity > 1) {
      _items[idx].quantity--;
    } else {
      _items.removeAt(idx);
      if (_items.isEmpty) _restaurantId = "";
    }
    notifyListeners();
  }

  int quantityOf(String itemId) {
    final found = _items.where((e) => e.item.id == itemId);
    return found.isEmpty ? 0 : found.first.quantity;
  }

  void clear() {
    _items.clear();
    _restaurantId = "";
    _restaurantName = "";
    notifyListeners();
  }

  // Format tiền VND
  static String formatPrice(double price) {
    if (price == 0) return "Miễn phí";
    final formatted = price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return "${formatted}đ";
  }
}
