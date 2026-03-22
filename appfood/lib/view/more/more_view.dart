// ========== PHẦN PUSH: TAB "KHÁC" (More) ==========
// Menu: Payment, My Orders, Notifications (badge số chưa đọc), Inbox, About Us.
// API badge: GET /api/user/notifications/unread-count. Mỗi dòng dùng Navigator.push sang màn con.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:appfood/common/api_config.dart';
import 'package:appfood/common/auth_token.dart';
import 'package:appfood/common/color_extension.dart';
import 'package:appfood/view/more/about_us_view.dart';
import 'package:appfood/view/more/inbox_view.dart';
import 'package:appfood/view/more/my_order_view.dart';
import 'package:appfood/view/more/notifications_view.dart';
import 'package:appfood/view/payment/payment_details_view.dart';

class MoreView extends StatefulWidget {
  const MoreView({super.key});

  @override
  State<MoreView> createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  int _unreadNotifications = 0; // hiển thị badge trên tile Notifications

  @override
  void initState() {
    super.initState();
    _loadUnread();
  }

  // --- Đếm thông báo chưa đọc (cần đăng nhập) ---
  Future<void> _loadUnread() async {
    final token = await AuthToken.get();
    if (token == null) {
      setState(() => _unreadNotifications = 0);
      return;
    }
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/user/notifications/unread-count');
      final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (res.statusCode == 200) {
        final m = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() => _unreadNotifications = (m['count'] as num?)?.toInt() ?? 0);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: TColor.background,
        elevation: 0,
        title: Text(
          'More',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
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
      // --- Danh sách chức năng "Khác" ---
      body: RefreshIndicator(
        onRefresh: _loadUnread,
        child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _tile(
            icon: Icons.payments_outlined,
            title: 'Payment Details',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaymentDetailsView()),
            ).then((_) => _loadUnread()),
          ),
          const SizedBox(height: 10),
          _tile(
            icon: Icons.shopping_bag_outlined,
            title: 'My Orders',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyOrderView()),
            ),
          ),
          const SizedBox(height: 10),
          _tile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            badge: _unreadNotifications > 0 ? _unreadNotifications : null,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsView()),
            ).then((_) => _loadUnread()),
          ),
          const SizedBox(height: 10),
          _tile(
            icon: Icons.mail_outline_rounded,
            title: 'Inbox',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InboxView()),
            ),
          ),
          const SizedBox(height: 10),
          _tile(
            icon: Icons.info_outline_rounded,
            title: 'About Us',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutUsView()),
            ),
          ),
        ],
        ),
      ),
    );
  }

  // --- Một hàng menu: icon + title + badge (tuỳ chọn) + chevron ---
  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    int? badge,
  }) {
    return Material(
      color: TColor.textfield,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(icon, color: TColor.primaryText),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: TColor.primaryText,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: TColor.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: TColor.placeholder),
            ],
          ),
        ),
      ),
    );
  }
}
