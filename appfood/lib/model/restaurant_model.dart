class RestaurantModel {
  final String id;
  final String name;
  final String category;
  final String imageUrl;   // sau dùng Firebase Storage URL
  final double rating;
  final int reviewCount;
  final String deliveryTime; // "15-25 phút"
  final double deliveryFee;  // 0 = miễn phí
  final double distanceKm;
  final bool isOpen;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.distanceKm,
    required this.isOpen,
  });

  // Mock data — sau thay bằng Firestore
  static List<RestaurantModel> mockList() {
    return [
      RestaurantModel(
        id: "r1",
        name: "Cơm tấm Sài Gòn",
        category: "Cơm",
        imageUrl: "", // để trống, dùng placeholder
        rating: 4.8,
        reviewCount: 320,
        deliveryTime: "15-25 phút",
        deliveryFee: 0,
        distanceKm: 1.2,
        isOpen: true,
      ),
      RestaurantModel(
        id: "r2",
        name: "Phở Hà Nội",
        category: "Phở",
        imageUrl: "",
        rating: 4.6,
        reviewCount: 210,
        deliveryTime: "20-30 phút",
        deliveryFee: 15000,
        distanceKm: 2.5,
        isOpen: true,
      ),
      RestaurantModel(
        id: "r3",
        name: "Burger King",
        category: "Burger",
        imageUrl: "",
        rating: 4.3,
        reviewCount: 180,
        deliveryTime: "25-35 phút",
        deliveryFee: 0,
        distanceKm: 3.1,
        isOpen: true,
      ),
      RestaurantModel(
        id: "r4",
        name: "The Pizza Company",
        category: "Pizza",
        imageUrl: "",
        rating: 4.5,
        reviewCount: 290,
        deliveryTime: "30-40 phút",
        deliveryFee: 20000,
        distanceKm: 4.0,
        isOpen: false,
      ),
      RestaurantModel(
        id: "r5",
        name: "Bánh mì Huỳnh Hoa",
        category: "Bánh mì",
        imageUrl: "",
        rating: 4.9,
        reviewCount: 512,
        deliveryTime: "10-20 phút",
        deliveryFee: 0,
        distanceKm: 0.8,
        isOpen: true,
      ),
    ];
  }
}
