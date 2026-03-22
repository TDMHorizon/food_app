// ========== PHẦN PUSH (liên quan luồng đặt hàng → xem "Đơn hàng" ở Khác) ==========
// Sau checkout: về MainTabView bằng rootNavigator để không lồng 2 thanh điều hướng dưới.

import 'package:flutter/material.dart';
import 'package:appfood/common/color_extension.dart';
import 'package:appfood/view/main_tabview/main_tabview.dart';

class OrderSuccessView extends StatelessWidget {
  const OrderSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: TColor.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            // Phải dùng root navigator: nếu không, MainTabView bị push vào stack của tab
            // → lồng 2 MainTabView và xuất hiện 2 thanh điều hướng dưới.
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainTabView()),
              (route) => false,
            );
          },
          color: TColor.primaryText,
        ),
      ),
      // --- Nội dung cảm ơn + nút về trang chủ (cùng logic rootNavigator như nút X) ---
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Icon(Icons.check_circle_rounded, size: 88, color: TColor.orangeDark),
              const SizedBox(height: 24),
              Text(
                'Cảm ơn bạn!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: TColor.primaryText,
                ),
              ),
              Text(
                'đã đặt hàng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TColor.primaryText,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Đơn hàng đang được xử lý. Chúng tôi sẽ thông báo khi đơn được lấy từ cửa hàng. Bạn có thể theo dõi trạng thái trong mục Đơn hàng.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: TColor.secondaryText, height: 1.4),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // rootNavigator: thay toàn bộ stack = 1 MainTabView
                    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainTabView()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.orangeDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: const Text(
                    'Về trang chủ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
