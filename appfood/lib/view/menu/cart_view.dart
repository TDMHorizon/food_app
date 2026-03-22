import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:appfood/common/color_extension.dart';
import 'package:appfood/common/cart_controller.dart';
import 'package:appfood/common/smart_image.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  bool isCheckout = false;

  @override
  void initState() {
    super.initState();
    CartController().addListener(_onCartChanged);
  }

  @override
  void dispose() {
    CartController().removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }

  Future<void> _handleCheckout() async {
    if (CartController().items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Giỏ hàng của bạn đang trống!")),
      );
      return;
    }

    setState(() {
      isCheckout = true;
    });

    try {
      final url = Uri.parse('http://localhost:3000/api/food/checkout');
      final body = jsonEncode({
        "total_price": CartController().totalPrice,
        "items": CartController().items.map((e) => {
          "menuItemId": e.menuItemId,
          "name": e.name,
          "quantity": e.quantity,
          "price": e.price
        }).toList(),
      });

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 201) {
        CartController().clearCart();
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Thành công"),
              content: const Text("Đơn hàng của bạn đã được đặt thành công!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to previous screen
                  },
                  child: const Text("Đóng"),
                )
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Thanh toán thất bại, vui lòng thử lại!")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi kết nối: \$e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isCheckout = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = CartController().items;
    final totalPrice = CartController().totalPrice;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Giỏ hàng",
          style: TextStyle(color: TColor.primaryText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: TColor.primaryText),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Text(
                "Chưa có món nào trong giỏ",
                style: TextStyle(color: TColor.secondaryText, fontSize: 16),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: SmartImage(
                                item.imageUrl.isNotEmpty ? item.imageUrl : "https://loremflickr.com/200/200/food",
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "đ ${item.price.toStringAsFixed(0)}",
                                    style: TextStyle(
                                      color: TColor.primary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            CartController().updateQuantity(item.menuItemId, item.quantity - 1);
                                          },
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: TColor.placeholder.withOpacity(0.5)),
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: const Icon(Icons.remove, size: 16),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "${item.quantity}",
                                          style: TextStyle(
                                            color: TColor.primaryText,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            CartController().updateQuantity(item.menuItemId, item.quantity + 1);
                                          },
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: TColor.placeholder.withOpacity(0.5)),
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: const Icon(Icons.add, size: 16),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          onPressed: () {
                                            CartController().removeItem(item.menuItemId);
                                          },
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tổng cộng:", style: TextStyle(color: TColor.primaryText, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("đ ${totalPrice.toStringAsFixed(0)}", style: TextStyle(color: TColor.primary, fontSize: 24, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: isCheckout ? null : _handleCheckout,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: isCheckout ? Colors.grey : TColor.primary,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: isCheckout 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text(
                                "Thanh toán",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
