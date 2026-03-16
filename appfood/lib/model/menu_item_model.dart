class MenuItemModel {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String category; // "Món chính", "Khai vị", "Tráng miệng", "Đồ uống"
  final String emoji;
  final bool isAvailable;
  final bool isBestSeller;

  MenuItemModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.emoji,
    this.isAvailable = true,
    this.isBestSeller = false,
  });

  // Mock data theo từng nhà hàng
  static List<MenuItemModel> mockForRestaurant(String restaurantId) {
    final all = _allMock();
    return all.where((item) => item.restaurantId == restaurantId).toList();
  }

  // Lấy danh sách category không trùng
  static List<String> categoriesOf(List<MenuItemModel> items) {
    final seen = <String>{};
    return items.map((e) => e.category).where(seen.add).toList();
  }

  static List<MenuItemModel> _allMock() {
    return [
      // --- r1: Cơm tấm ---
      MenuItemModel(id: "m1", restaurantId: "r1", name: "Cơm tấm sườn bì chả", description: "Cơm tấm với sườn nướng, bì heo, chả trứng", price: 55000, category: "Món chính", emoji: "🍚", isBestSeller: true),
      MenuItemModel(id: "m2", restaurantId: "r1", name: "Cơm tấm sườn nướng", description: "Sườn nướng mật ong thơm ngon", price: 50000, category: "Món chính", emoji: "🍚"),
      MenuItemModel(id: "m3", restaurantId: "r1", name: "Cơm tấm bì chả", description: "Bì heo và chả trứng hấp", price: 45000, category: "Món chính", emoji: "🍚"),
      MenuItemModel(id: "m4", restaurantId: "r1", name: "Nước ngọt", description: "Coca, Pepsi, 7Up", price: 15000, category: "Đồ uống", emoji: "🥤"),
      MenuItemModel(id: "m5", restaurantId: "r1", name: "Trà đá", description: "Trà đá miễn phí", price: 0, category: "Đồ uống", emoji: "🍵"),

      // --- r2: Phở ---
      MenuItemModel(id: "m6", restaurantId: "r2", name: "Phở bò tái", description: "Phở bò với thịt tái thơm, nước dùng đậm đà", price: 60000, category: "Món chính", emoji: "🍜", isBestSeller: true),
      MenuItemModel(id: "m7", restaurantId: "r2", name: "Phở bò chín", description: "Thịt bò chín mềm, nước trong", price: 60000, category: "Món chính", emoji: "🍜"),
      MenuItemModel(id: "m8", restaurantId: "r2", name: "Phở gà", description: "Phở gà ta luộc vàng", price: 55000, category: "Món chính", emoji: "🍜"),
      MenuItemModel(id: "m9", restaurantId: "r2", name: "Quẩy giòn", description: "2 cái quẩy chiên giòn", price: 10000, category: "Khai vị", emoji: "🥐"),
      MenuItemModel(id: "m10", restaurantId: "r2", name: "Nước chanh", description: "Chanh tươi đá lạnh", price: 20000, category: "Đồ uống", emoji: "🍋"),

      // --- r3: Burger ---
      MenuItemModel(id: "m11", restaurantId: "r3", name: "Whopper", description: "Bánh burger bò 100g với rau xà lách, cà chua", price: 89000, category: "Burger", emoji: "🍔", isBestSeller: true),
      MenuItemModel(id: "m12", restaurantId: "r3", name: "Double Whopper", description: "2 lớp thịt bò siêu ngon", price: 119000, category: "Burger", emoji: "🍔"),
      MenuItemModel(id: "m13", restaurantId: "r3", name: "Chicken Burger", description: "Gà giòn sốt mayonnaise", price: 79000, category: "Burger", emoji: "🍔"),
      MenuItemModel(id: "m14", restaurantId: "r3", name: "Khoai tây chiên", description: "Vừa/Lớn, giòn tan", price: 35000, category: "Khai vị", emoji: "🍟"),
      MenuItemModel(id: "m15", restaurantId: "r3", name: "Coca Cola", description: "330ml", price: 25000, category: "Đồ uống", emoji: "🥤"),

      // --- r4: Pizza ---
      MenuItemModel(id: "m16", restaurantId: "r4", name: "Pizza Margherita", description: "Cà chua, phô mai mozzarella, húng quế", price: 150000, category: "Pizza", emoji: "🍕", isBestSeller: true),
      MenuItemModel(id: "m17", restaurantId: "r4", name: "Pizza BBQ Chicken", description: "Gà nướng BBQ, hành tây, ớt chuông", price: 175000, category: "Pizza", emoji: "🍕"),
      MenuItemModel(id: "m18", restaurantId: "r4", name: "Garlic Bread", description: "Bánh mì bơ tỏi nướng", price: 45000, category: "Khai vị", emoji: "🥖"),

      // --- r5: Bánh mì ---
      MenuItemModel(id: "m19", restaurantId: "r5", name: "Bánh mì đặc biệt", description: "Pate, thịt nguội, chả, rau thơm", price: 35000, category: "Bánh mì", emoji: "🥖", isBestSeller: true),
      MenuItemModel(id: "m20", restaurantId: "r5", name: "Bánh mì trứng", description: "2 trứng chiên, dưa leo, cà rốt", price: 25000, category: "Bánh mì", emoji: "🥖"),
      MenuItemModel(id: "m21", restaurantId: "r5", name: "Bánh mì gà", description: "Gà xé, sốt tương ớt", price: 30000, category: "Bánh mì", emoji: "🥖"),
      MenuItemModel(id: "m22", restaurantId: "r5", name: "Cà phê sữa đá", description: "Cà phê phin truyền thống", price: 20000, category: "Đồ uống", emoji: "☕"),
    ];
  }
}
