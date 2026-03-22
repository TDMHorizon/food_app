// ========== PHẦN PUSH: MỤC "MY ORDERS" (mở từ tab Khác) ==========
// GET /api/user/orders — danh sách đơn của user đã đăng nhập (JWT).

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:appfood/common/api_config.dart';
import 'package:appfood/common/auth_token.dart';
import 'package:appfood/common/color_extension.dart';

class MyOrderView extends StatefulWidget {
  const MyOrderView({super.key});

  @override
  State<MyOrderView> createState() => _MyOrderViewState();
}

class _MyOrderViewState extends State<MyOrderView> {
  List<dynamic> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // --- Gọi API lấy đơn hàng ---
  Future<void> _load() async {
    final token = await AuthToken.get();
    if (token == null) {
      setState(() {
        _loading = false;
        _orders = [];
      });
      return;
    }
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/user/orders');
      final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (res.statusCode == 200) {
        setState(() {
          _orders = jsonDecode(res.body) as List<dynamic>;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
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
          'My Order',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: TColor.primaryText),
        ),
      ),
      // --- Danh sách đơn hoặc empty state ---
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(
                  child: Text(
                    'Chưa có đơn hàng',
                    style: TextStyle(color: TColor.secondaryText, fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      // Mỗi phần tử: id, total_price, status, created_at
                      final o = _orders[i] as Map<String, dynamic>;
                      final id = o['id'];
                      final total = o['total_price'];
                      final status = o['status']?.toString() ?? '';
                      DateTime? dt;
                      try {
                        dt = DateTime.parse(o['created_at'].toString());
                      } catch (_) {}
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: TColor.textfield,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Đơn #$id',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: TColor.primaryText,
                                  ),
                                ),
                                Text(
                                  '${total?.toString() ?? '0'} đ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: TColor.orangeDark,
                                  ),
                                ),
                              ],
                            ),
                            if (dt != null)
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(dt),
                                style: TextStyle(fontSize: 12, color: TColor.secondaryText),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              status,
                              style: TextStyle(fontSize: 13, color: TColor.secondaryText),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
