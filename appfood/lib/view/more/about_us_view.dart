// ========== PHẦN PUSH: "ABOUT US" (từ tab Khác) ==========
// Màn tĩnh: giới thiệu app, không gọi API.

import 'package:flutter/material.dart';
import 'package:appfood/common/color_extension.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  // Nội dung hiển thị dạng bullet + đoạn văn
  static const _paragraphs = [
    'AppFood là ứng dụng đặt món và giao hàng, giúp bạn khám phá nhà hàng, thực đơn và đặt món nhanh chóng.',
    'Chúng tôi cam kết đồng hành cùng nhà hàng địa phương và mang đến trải nghiệm đặt món thuận tiện, minh bạch.',
    'Thông tin chi tiết về điều khoản và chính sách sẽ được cập nhật trên website chính thức của ứng dụng.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: TColor.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
          color: TColor.primaryText,
        ),
        title: Text(
          'About Us',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: TColor.primaryText),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: TColor.primaryText),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final p in _paragraphs) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    decoration: BoxDecoration(
                      color: TColor.orangeDark,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      p,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        color: TColor.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
