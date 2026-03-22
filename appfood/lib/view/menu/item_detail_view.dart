import 'package:flutter/material.dart';
import 'package:appfood/common/color_extension.dart';
import 'package:appfood/common/cart_controller.dart';
import 'package:appfood/view/menu/cart_view.dart';
import 'package:appfood/common/smart_image.dart';

class ItemDetailView extends StatefulWidget {
  final Map<String, String> itemObj;
  const ItemDetailView({super.key, required this.itemObj});

  @override
  State<ItemDetailView> createState() => _ItemDetailViewState();
}

class _ItemDetailViewState extends State<ItemDetailView> {
  int quantity = 0;

  @override
  Widget build(BuildContext context) {
    double itemPrice = double.tryParse(widget.itemObj["price"].toString()) ?? 75000.0;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header with Curve and Favorite Button
            Stack(
              clipBehavior: Clip.none,
              children: [
                SmartImage(
                  widget.itemObj["image"] ?? "https://loremflickr.com/500/500/food",
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
                
                // Back & Cart Buttons
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ),
                ),

                // White Bottom Curve
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                  ),
                ),

                // Favorite Button Floating on the Curve
                Positioned(
                  bottom: 25,
                  right: 35,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(Icons.favorite, color: TColor.primary, size: 25),
                  ),
                ),
              ],
            ),

            // Content Detail
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.itemObj["name"] ?? "Gà nướng Tandoori Pizza",
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Rating & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                Icons.star,
                                color: index < 4 ? TColor.primary : TColor.placeholder,
                                size: 16,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "4 Sao Đánh giá",
                            style: TextStyle(color: TColor.primary, fontSize: 12),
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "đ ${itemPrice.toStringAsFixed(0)}",
                            style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            "/ phần",
                            style: TextStyle(color: TColor.secondaryText, fontSize: 13),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    "Mô tả",
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Đến với hương vị đích thực, sự mềm mại của gà hòa quyện với phong cách nướng Tandoori chuẩn vị, rắc thêm chút phô mai dai và đế bánh nướng giòn tan trên mọi nẻo đường ẩm thực.",
                    style: TextStyle(color: TColor.secondaryText, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 25),

                  // Customize
                  Text(
                    "Tùy chỉnh Đơn hàng",
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Dropdowns
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: TColor.textfield,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("- Chọn cỡ phần ăn -", style: TextStyle(color: TColor.primaryText)),
                        Icon(Icons.keyboard_arrow_down, color: TColor.secondaryText),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: TColor.textfield,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("- Chọn nguyên liệu -", style: TextStyle(color: TColor.primaryText)),
                        Icon(Icons.keyboard_arrow_down, color: TColor.secondaryText),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Portion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Số lượng",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (quantity > 0) setState(() => quantity--);
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: TColor.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.remove, color: Colors.white, size: 20),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Text(
                            "$quantity",
                            style: TextStyle(color: TColor.primaryText, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 15),
                          GestureDetector(
                            onTap: () {
                              setState(() => quantity++);
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: TColor.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            
            // Output Add to Cart Section (The complex overlapping block)
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Underlying Orange Curve Block
                Container(
                  height: 130, // Big orange block
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: TColor.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                ),
                
                // Overlaying White Card Block
                Container(
                  margin: const EdgeInsets.only(left: 80, bottom: 25, right: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Tổng tiền", style: TextStyle(color: TColor.secondaryText, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            "đ ${(itemPrice * quantity).toStringAsFixed(0)}",
                            style: TextStyle(color: TColor.primaryText, fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              if (quantity > 0) {
                                CartController().addItem(
                                  menuItemId: "\${widget.itemObj['name']}-\${widget.itemObj['restaurant_id'] ?? ''}", // Fallback composite ID
                                  name: widget.itemObj["name"] ?? "Món ăn",
                                  price: itemPrice,
                                  imageUrl: widget.itemObj["image"] ?? "",
                                  quantity: quantity,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Đã thêm ${quantity} phần vào giỏ hàng!"),
                                    backgroundColor: TColor.primary,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Vui lòng chọn số lượng > 0"),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: TColor.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.shopping_cart, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  const Text("Thêm vào giỏ", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CartView()),
                          );
                        },
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(Icons.shopping_cart_outlined, color: TColor.primary),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
