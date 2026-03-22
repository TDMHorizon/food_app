import 'package:flutter/material.dart';
import 'package:appfood/common/color_extension.dart';
import 'package:appfood/model/restaurant_model.dart';
import 'package:appfood/common/smart_image.dart';
import 'package:appfood/view/menu/item_detail_view.dart'; // optional, to navigate when clicked

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  List<RestaurantModel> _offerItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final resData = await RestaurantModel.fetchAll();
    if (mounted) {
      setState(() {
        _offerItems = resData;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Siêu Ưu Đãi Hôm Nay",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.shopping_cart_outlined, color: TColor.primaryText, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Tìm kiếm siêu ưu đãi, các bữa ăn đặc biệt\nvà hơn thế nữa!",
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 150,
                      height: 35,
                      decoration: BoxDecoration(
                        color: TColor.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Kiểm tra Ưu đãi",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // List of Offers
            Expanded(
              child: ListView.builder(
                itemCount: _offerItems.length,
                itemBuilder: (context, index) {
                  var restaurant = _offerItems[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailView(itemObj: {
                            "name": restaurant.name,
                            "price": "69000",
                            "image": restaurant.imageUrl,
                            "category": restaurant.type1,
                            "rate": restaurant.rating.toString(),
                            "food_type": restaurant.type2,
                          }),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image edge-to-edge with Stack for Badge
                        Stack(
                          children: [
                            SmartImage(
                              restaurant.imageUrl,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: double.infinity,
                                height: 200,
                                color: Colors.grey[300],
                                child: const Icon(Icons.restaurant, color: Colors.grey, size: 50),
                              ),
                            ),
                            Positioned(
                              top: 15,
                              left: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.local_fire_department_rounded, color: Colors.amber, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      "Giảm sốc 30%",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Details text below
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.name,
                                style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.star, color: TColor.primary, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${restaurant.rating} (${restaurant.reviewCount} đánh giá)",
                                    style: TextStyle(
                                      color: TColor.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${restaurant.type1}   ·   ${restaurant.type2}",
                                    style: TextStyle(
                                      color: TColor.secondaryText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
