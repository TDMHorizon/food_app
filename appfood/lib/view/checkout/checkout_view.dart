import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:appfood/common/api_config.dart';
import 'package:appfood/common/auth_token.dart';
import 'package:appfood/common/cart_controller.dart';
import 'package:appfood/common/color_extension.dart';
import 'package:appfood/view/checkout/order_success_view.dart';
import 'package:appfood/view/map/map_picker_view.dart';
import 'package:appfood/view/payment/add_card_view.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  String _deliveryAddress = '';
  int _paymentIndex = 0;
  List<Map<String, dynamic>> _cards = [];
  bool _loadingCards = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final token = await AuthToken.get();
    if (token == null || token.isEmpty) {
      setState(() {
        _loadingCards = false;
        _cards = [];
      });
      return;
    }
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/user/cards');
      final res = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        setState(() {
          _cards = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _loadingCards = false;
        });
      } else {
        setState(() => _loadingCards = false);
      }
    } catch (_) {
      setState(() => _loadingCards = false);
    }
  }

  Future<void> _changeAddress() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerView()),
    );
    if (result != null && result['address'] != null) {
      setState(() => _deliveryAddress = result['address'] as String);
    }
  }

  double get _subtotal => CartController().totalPrice;
  double get _deliveryFee => _subtotal >= 150000 ? 0 : 15000;
  double get _total => _subtotal + _deliveryFee;

  Future<void> _sendOrder() async {
    if (CartController().items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giỏ hàng trống')),
      );
      return;
    }
    if (_deliveryAddress.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn địa chỉ giao hàng')),
      );
      return;
    }
    final token = await AuthToken.get();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/food/checkout');
      final body = jsonEncode({
        'total_price': _total,
        'delivery_address': _deliveryAddress,
        'items': CartController().items.map((e) => {
              'menuItemId': e.menuItemId,
              'name': e.name,
              'quantity': e.quantity,
              'price': e.price,
            }).toList(),
      });
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );
      if (!mounted) return;
      if (res.statusCode == 201) {
        CartController().clearCart();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrderSuccessView()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt hàng thất bại')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = CartController().items;

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
          'Checkout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: TColor.primaryText,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: TColor.primaryText),
            onPressed: () {},
          ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                'Giỏ hàng trống',
                style: TextStyle(color: TColor.secondaryText),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Address',
                    style: TextStyle(fontSize: 13, color: TColor.secondaryText),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _deliveryAddress.isEmpty
                              ? 'Chưa chọn địa chỉ'
                              : _deliveryAddress,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TColor.primaryText,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _changeAddress,
                        child: Text(
                          'Change',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: TColor.orangeDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment method',
                        style: TextStyle(fontSize: 13, color: TColor.secondaryText),
                      ),
                      TextButton(
                        onPressed: () async {
                          final ok = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(builder: (_) => const AddCardView()),
                          );
                          if (ok == true) _loadCards();
                        },
                        child: Text(
                          '+ Add Card',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: TColor.orangeDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _paymentTile(0, 'Cash/Card on delivery'),
                  if (_loadingCards)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    ...List.generate(_cards.length, (i) {
                      final c = _cards[i];
                      final idx = i + 1;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _paymentTile(
                          idx,
                          '${c['brand']} **** **** ${c['last4']}',
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TColor.textfield,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _sumRow('Sub Total', '${_subtotal.toStringAsFixed(0)} đ'),
                        const SizedBox(height: 8),
                        _sumRow('Delivery Cost', '${_deliveryFee.toStringAsFixed(0)} đ'),
                        const SizedBox(height: 12),
                        Divider(height: 1, color: TColor.placeholder),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: TColor.primaryText,
                              ),
                            ),
                            Text(
                              '${_total.toStringAsFixed(0)} đ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: TColor.orangeDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _sendOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.orangeDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Send Order',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _paymentTile(int index, String label) {
    final sel = _paymentIndex == index;
    return InkWell(
      onTap: () => setState(() => _paymentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: TColor.textfield,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: TColor.primaryText,
                ),
              ),
            ),
            Icon(
              sel ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: TColor.orangeDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sumRow(String a, String b) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(a, style: TextStyle(fontSize: 14, color: TColor.secondaryText)),
        Text(
          b,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: TColor.primaryText,
          ),
        ),
      ],
    );
  }
}
