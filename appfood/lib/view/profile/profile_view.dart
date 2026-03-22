import 'package:flutter/material.dart';
import 'package:appfood/common/color_extension.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:appfood/view/login/login_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final url = Uri.parse('http://localhost:3000/api/auth/profile');
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json'
      });
      
      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() { isLoading = false; });
      }
    } catch (e) {
      setState(() { isLoading = false; });
    }
  }

  Future<void> _logout() async {
    if (!mounted) return;
    // Chuyển về màn hình Login và xóa toàn bộ route cũ
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: TColor.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: TColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: TColor.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Text("👤", style: TextStyle(fontSize: 50))),
              ),
              const SizedBox(height: 15),
              Text(
                userData?['fullname'] ?? "Chưa có tên",
                style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w700,
                  color: TColor.primaryText,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                userData?['email'] ?? "Chưa có email",
                style: TextStyle(
                  fontSize: 14, color: TColor.secondaryText,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.phone_outlined, "Số điện thoại", userData?['phone'] ?? "Chưa cập nhật"),
                    const Divider(color: Colors.black12, height: 1),
                    _buildInfoRow(Icons.location_on_outlined, "Địa chỉ", userData?['address'] ?? "Chưa thiết lập"),
                    const Divider(color: Colors.black12, height: 1),
                    _buildInfoRow(
                      Icons.calendar_today_outlined, 
                      "Ngày tham gia", 
                      userData?['created_at'] != null 
                        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(userData!['created_at'])) 
                        : "Không rõ"
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              
              // Menu Actions
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    _buildActionMenu(Icons.receipt_long_outlined, "Lịch sử đơn hàng"),
                    const Divider(color: Colors.black12, height: 1),
                    _buildActionMenu(Icons.account_balance_wallet_outlined, "Phương thức thanh toán"),
                    const Divider(color: Colors.black12, height: 1),
                    _buildActionMenu(Icons.local_offer_outlined, "Voucher của tôi"),
                    const Divider(color: Colors.black12, height: 1),
                    _buildActionMenu(Icons.settings_outlined, "Cài đặt tài khoản"),
                    const Divider(color: Colors.black12, height: 1),
                    _buildActionMenu(Icons.help_outline, "Trung tâm hỗ trợ"),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Đăng xuất", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionMenu(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: TColor.primary, size: 24),
      title: Text(title, style: TextStyle(color: TColor.primaryText, fontSize: 15, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black38),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$title hiện đang được phát triển!")),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: TColor.primary, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: TColor.secondaryText)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 16, color: TColor.primaryText, fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

