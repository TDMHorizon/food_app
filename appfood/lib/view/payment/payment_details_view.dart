// ========== PHẦN PUSH: "PAYMENT DETAILS" (từ tab Khác) ==========
// GET /api/user/cards, DELETE /api/user/cards/:id. Nút Add mở AddCardView; chọn phương thức local (_selected).

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:appfood/common/api_config.dart';
import 'package:appfood/common/auth_token.dart';
import 'package:appfood/common/color_extension.dart';
import 'package:appfood/view/payment/add_card_view.dart';

class PaymentDetailsView extends StatefulWidget {
  const PaymentDetailsView({super.key});

  @override
  State<PaymentDetailsView> createState() => _PaymentDetailsViewState();
}

class _PaymentDetailsViewState extends State<PaymentDetailsView> {
  List<Map<String, dynamic>> _cards = [];
  int _selected = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = await AuthToken.get();
    if (token == null) {
      setState(() {
        _loading = false;
        _cards = [];
      });
      return;
    }
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/user/cards');
      final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        setState(() {
          _cards = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  // --- Xóa một thẻ theo id ---
  Future<void> _delete(int id) async {
    final token = await AuthToken.get();
    if (token == null) return;
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/user/cards/$id');
      final res = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
      if (res.statusCode == 200) _load();
    } catch (_) {}
  }

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
          'Payment Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: TColor.primaryText),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: TColor.primaryText),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customize your payment method',
                    style: TextStyle(fontSize: 14, color: TColor.secondaryText),
                  ),
                  const SizedBox(height: 20),
                  _row(
                    'Cash/Card on delivery',
                    _selected == 0,
                    () => setState(() => _selected = 0),
                  ),
                  const Divider(height: 24),
                  // Render từng thẻ: brand + 4 số cuối + Delete
                  ...List.generate(_cards.length, (i) {
                    final c = _cards[i];
                    final idx = i + 1;
                    return Column(
                      children: [
                        InkWell(
                          onTap: () => setState(() => _selected = idx),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${c['brand']} **** **** ${c['last4']}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: TColor.primaryText,
                                    ),
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () => _delete(int.parse(c['id'].toString())),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: TColor.orangeDark,
                                    side: BorderSide(color: TColor.orangeDark),
                                  ),
                                  child: const Text('Delete Card'),
                                ),
                                if (_selected == idx)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Icon(Icons.check_circle, color: TColor.orangeDark),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),
                  Text(
                    'Other Methods',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: TColor.primaryText),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Thêm thẻ xong pop(true) → gọi lại _load()
                        final ok = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddCardView()),
                        );
                        if (ok == true) _load();
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Add Another Credit/Debit Card',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.orangeDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Hàng chọn phương thức (tiền mặt / giao hàng)
  Widget _row(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: TColor.primaryText),
            ),
          ),
          if (selected) Icon(Icons.check, color: TColor.orangeDark),
        ],
      ),
    );
  }
}
