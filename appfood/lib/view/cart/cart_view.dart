import 'package:flutter/material.dart';
import 'package:appfood/common/color_extension.dart';
import 'package:appfood/model/cart_item_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:appfood/view/map/map_picker_view.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final CartManager _cart = CartManager();
  String _deliveryAddress = "";
  LatLng? _deliveryLatLng;

  @override
  void initState() {
    super.initState();
    _cart.addListener(_rebuild);
  }

  @override
  void dispose() {
    _cart.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});
  Future<void> _openMapPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerView(initialPosition: _deliveryLatLng),
      ),
    );
    if (result != null) {
      setState(() {
        _deliveryAddress = result["address"] as String;
        _deliveryLatLng = LatLng(
          result["lat"] as double,
          result["lng"] as double,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: TColor.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
        ),
        title: Text(
          "Giỏ hàng",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: TColor.primaryText,
          ),
        ),
        actions: [
          if (!_cart.isEmpty)
            TextButton(
              onPressed: () => _showClearDialog(context),
              child: Text(
                "Xoá tất cả",
                style: TextStyle(color: TColor.red, fontSize: 13),
              ),
            ),
        ],
      ),
      body: _cart.isEmpty ? _buildEmpty() : _buildCartContent(context),
    );
  }

  // ── RỖng ──
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("🛒", style: TextStyle(fontSize: 72)),
          const SizedBox(height: 16),
          Text(
            "Giỏ hàng trống",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: TColor.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Hãy thêm món ăn yêu thích của bạn",
            style: TextStyle(fontSize: 14, color: TColor.secondaryText),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: TColor.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                "Xem nhà hàng",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── NỘI DUNG GIỎ HÀNG ──
  Widget _buildCartContent(BuildContext context) {
    return Column(
      children: [
        // Tên nhà hàng
        Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: TColor.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.storefront_rounded,
                color: TColor.primaryDark,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                _cart.restaurantName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TColor.primaryText,
                ),
              ),
            ],
          ),
        ),

        // Danh sách món
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            itemCount: _cart.items.length,
            itemBuilder: (context, index) => _buildCartItem(_cart.items[index]),
          ),
        ),

        // Tổng tiền + nút đặt
        _buildOrderSummary(context),
      ],
    );
  }

  // ── CART ITEM ROW ──
  Widget _buildCartItem(CartItem cartItem) {
    final item = cartItem.item;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColor.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColor.textfield, width: 1.5),
      ),
      child: Row(
        children: [
          // Emoji
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: TColor.textfield,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(item.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 12),

          // Tên + giá
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TColor.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CartManager.formatPrice(item.price),
                  style: TextStyle(
                    fontSize: 13,
                    color: TColor.orangeDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Số lượng
          Row(
            children: [
              _circleBtn(
                icon: Icons.remove_rounded,
                onTap: () => _cart.decreaseItem(item.id),
                filled: false,
              ),
              SizedBox(
                width: 28,
                child: Center(
                  child: Text(
                    "${cartItem.quantity}",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: TColor.primaryText,
                    ),
                  ),
                ),
              ),
              _circleBtn(
                icon: Icons.add_rounded,
                onTap: () => _cart.addItem(item, "", _cart.restaurantName),
                filled: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required VoidCallback onTap,
    required bool filled,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: filled ? TColor.primary : Colors.transparent,
          border: filled ? null : Border.all(color: TColor.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: filled ? Colors.white : TColor.primary,
          size: 16,
        ),
      ),
    );
  }

  // ── ORDER SUMMARY ──
  Widget _buildOrderSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: TColor.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryRow("Tạm tính", CartManager.formatPrice(_cart.subtotal)),
          const SizedBox(height: 8),
          _summaryRow(
            "Phí giao hàng",
            CartManager.formatPrice(_cart.deliveryFee),
            hint: _cart.subtotal >= 150000 ? "Miễn phí từ 150k" : null,
          ),
          const Divider(height: 20),
          _summaryRow(
            "Tổng cộng",
            CartManager.formatPrice(_cart.total),
            isBold: true,
          ),
          const SizedBox(height: 16),

       
          GestureDetector(
            onTap: _openMapPicker,
            child: Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: TColor.textfield,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _deliveryAddress.isEmpty
                      ? TColor.placeholder
                      : TColor.primary,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: _deliveryAddress.isEmpty
                        ? TColor.placeholder
                        : TColor.red,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _deliveryAddress.isEmpty
                          ? "Chọn địa chỉ giao hàng..."
                          : _deliveryAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: _deliveryAddress.isEmpty
                            ? TColor.placeholder
                            : TColor.primaryText,
                        fontWeight: _deliveryAddress.isEmpty
                            ? FontWeight.w400
                            : FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: TColor.secondaryText,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    String? hint,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isBold ? 15 : 14,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                color: TColor.secondaryText,
              ),
            ),
            if (hint != null)
              Text(
                hint,
                style: TextStyle(fontSize: 11, color: Colors.green.shade600),
              ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 17 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: isBold ? TColor.orangeDark : TColor.primaryText,
          ),
        ),
      ],
    );
  }

  // ── ACTIONS ──
  void _placeOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("🎉 Đặt hàng thành công!"),
        content: Text(
          "Đơn hàng từ ${_cart.restaurantName} đang được xử lý.\nThời gian giao hàng: 20-30 phút.",
          style: TextStyle(color: TColor.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _cart.clear();
              Navigator.of(context)
                ..pop() // đóng dialog
                ..pop(); // về restaurant detail
            },
            child: Text("OK", style: TextStyle(color: TColor.primaryDark)),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Xoá giỏ hàng?"),
        content: const Text("Tất cả món ăn sẽ bị xoá."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Huỷ", style: TextStyle(color: TColor.secondaryText)),
          ),
          TextButton(
            onPressed: () {
              _cart.clear();
              Navigator.pop(context);
            },
            child: Text("Xoá", style: TextStyle(color: TColor.red)),
          ),
        ],
      ),
    );
  }
}
