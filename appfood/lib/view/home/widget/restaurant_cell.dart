import 'package:flutter/material.dart';
import 'package:appfood/common/color_extension.dart';
import 'package:appfood/model/restaurant_model.dart';

class RestaurantCell extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback onTap;

  const RestaurantCell({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: TColor.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ảnh nhà hàng ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    color: TColor.textfield,
                    child: restaurant.imageUrl.isNotEmpty
                        ? Image.network(restaurant.imageUrl, fit: BoxFit.cover)
                        : Center(
                            child: Text(
                              _categoryEmoji(restaurant.category),
                              style: const TextStyle(fontSize: 50),
                            ),
                          ),
                  ),
                ),
                // Badge "Đóng cửa"
                if (!restaurant.isOpen)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: Text(
                            "Đóng cửa",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Badge "Miễn phí ship"
                if (restaurant.deliveryFee == 0 && restaurant.isOpen)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: TColor.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Miễn phí ship",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Thông tin ──
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên nhà hàng
                  Text(
                    restaurant.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: TColor.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Rating + thời gian + khoảng cách
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: TColor.primary, size: 16),
                      const SizedBox(width: 3),
                      Text(
                        restaurant.rating.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: TColor.primaryText,
                        ),
                      ),
                      Text(
                        " (${restaurant.reviewCount})",
                        style: TextStyle(fontSize: 12, color: TColor.secondaryText),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time_rounded, size: 14, color: TColor.secondaryText),
                      const SizedBox(width: 3),
                      Text(
                        restaurant.deliveryTime,
                        style: TextStyle(fontSize: 12, color: TColor.secondaryText),
                      ),
                      const Spacer(),
                      Icon(Icons.location_on_outlined, size: 14, color: TColor.secondaryText),
                      Text(
                        "${restaurant.distanceKm} km",
                        style: TextStyle(fontSize: 12, color: TColor.secondaryText),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryEmoji(String category) {
    const map = {
      "Cơm": "🍚",
      "Phở": "🍜",
      "Bánh mì": "🥖",
      "Pizza": "🍕",
      "Burger": "🍔",
    };
    return map[category] ?? "🍱";
  }
}
