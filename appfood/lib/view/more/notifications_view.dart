// ========== PHẦN PUSH: "NOTIFICATIONS" (từ tab Khác) ==========
// GET /api/user/notifications — hiển thị title/body/thời gian; chấm cam = chưa đọc.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:appfood/common/api_config.dart';
import 'package:appfood/common/auth_token.dart';
import 'package:appfood/common/color_extension.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Bearer token bắt buộc
    final token = await AuthToken.get();
    if (token == null) {
      setState(() {
        _loading = false;
        _items = [];
      });
      return;
    }
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/user/notifications');
      final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        setState(() {
          _items = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
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
          'Notifications',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: TColor.primaryText),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: TColor.primaryText),
            onPressed: () {},
          ),
        ],
      ),
      // --- List thông báo hoặc empty ---
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Text(
                    'Không có thông báo',
                    style: TextStyle(color: TColor.secondaryText),
                  ),
                )
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, i) {
                    final n = _items[i];
                    final read = n['is_read'] == true;
                    DateTime? dt;
                    try {
                      dt = DateTime.parse(n['created_at'].toString());
                    } catch (_) {}
                    final stripe = i.isEven ? Colors.white : TColor.textfield;
                    return Container(
                      color: stripe,
                      child: ListTile(
                        leading: Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: read ? Colors.transparent : TColor.orangeDark,
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(
                          n['title']?.toString() ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: TColor.primaryText,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (n['body'] != null)
                              Text(
                                n['body'].toString(),
                                style: TextStyle(fontSize: 13, color: TColor.secondaryText),
                              ),
                            if (dt != null)
                              Text(
                                DateFormat('dd MMM yyyy, HH:mm').format(dt),
                                style: TextStyle(fontSize: 12, color: TColor.placeholder),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
