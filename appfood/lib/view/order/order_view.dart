import 'package:flutter/material.dart';
import 'package:appfood/common/color_extension.dart';

class OrderView extends StatelessWidget {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("📦", style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              "Đơn hàng",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: TColor.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Sắp ra mắt — Phase 2",
              style: TextStyle(fontSize: 14, color: TColor.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
