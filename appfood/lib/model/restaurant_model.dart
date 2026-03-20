import 'dart:convert';
import 'package:http/http.dart' as http;

class RestaurantModel {
  final String id;
  final String name;
  final String type1;
  final String type2;
  final String imageUrl;
  final double rating;
  final int reviewCount;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.type1,
    required this.type2,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type1: json['type1'] ?? '',
      type2: json['type2'] ?? '',
      imageUrl: json['image'] ?? '',
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      reviewCount: int.tryParse(json['review_count'].toString()) ?? 0,
    );
  }

  static Future<List<RestaurantModel>> fetchAll() async {
    try {
      final url = Uri.parse('http://localhost:3000/api/food/restaurants');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => RestaurantModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }
}
