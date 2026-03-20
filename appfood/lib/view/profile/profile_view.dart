import 'package:flutter/material.dart';
import 'package:appfood/common/color_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      final url = Uri.parse('http://localhost:3000/api/auth/profile');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer \$token'
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    
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
              _buildInfoRow(Icons.phone, "Số điện thoại", userData?['phone'] ?? "N/A"),
              _buildInfoRow(Icons.location_on, "Địa chỉ", userData?['address'] ?? "Chưa thiết lập"),
              const SizedBox(height: 50),
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Đăng xuất", style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
              )
            ],
          ),
        ),
      ),
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

