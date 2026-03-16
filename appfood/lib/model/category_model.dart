class CategoryModel {
  final String name;
  final String icon; // emoji icon

  CategoryModel({required this.name, required this.icon});

  // Mock data — sau này thay bằng Firestore
  static List<CategoryModel> mockList() {
    return [
      CategoryModel(name: "Cơm", icon: "🍚"),
      CategoryModel(name: "Phở", icon: "🍜"),
      CategoryModel(name: "Bánh mì", icon: "🥖"),
      CategoryModel(name: "Pizza", icon: "🍕"),
      CategoryModel(name: "Burger", icon: "🍔"),
      CategoryModel(name: "Tráng miệng", icon: "🍰"),
      CategoryModel(name: "Trà sữa", icon: "🧋"),
      CategoryModel(name: "Khác", icon: "🍱"),
    ];
  }
}
