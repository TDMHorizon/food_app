// ========== PHẦN PUSH: TAB "HỒ SƠ" (Profile) ==========
// Màn hình xem/sửa thông tin user: GET/PUT /api/auth/profile + JWT (AuthToken).
// Avatar: chọn ảnh local (ImagePicker); đăng xuất: xóa token + về LoginView (root navigator).

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:appfood/common/api_config.dart';
import 'package:appfood/common/auth_token.dart';
import 'package:appfood/common/color_extension.dart';
import 'package:appfood/common_widget/round_button.dart';
import 'package:appfood/common_widget/round_textfield.dart';
import 'package:appfood/view/login/login_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // --- Controller cho form chỉnh sửa ---
  final _txtName = TextEditingController();
  final _txtEmail = TextEditingController();
  final _txtMobile = TextEditingController();
  final _txtAddress = TextEditingController();
  final _txtPassword = TextEditingController();
  final _txtConfirmPassword = TextEditingController();

  XFile? _pickedAvatar; // ảnh đại diện (chưa upload server trong demo này)
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String _greetingName = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _txtName.dispose();
    _txtEmail.dispose();
    _txtMobile.dispose();
    _txtAddress.dispose();
    _txtPassword.dispose();
    _txtConfirmPassword.dispose();
    super.dispose();
  }

  // --- Tải hồ sơ từ backend (Bearer token) ---
  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final token = await AuthToken.get();
    if (token == null || token.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Chưa đăng nhập. Vui lòng đăng nhập qua server để xem hồ sơ.';
        _greetingName = '';
      });
      return;
    }
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/profile');
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        final m = jsonDecode(res.body) as Map<String, dynamic>;
        _txtName.text = m['fullname']?.toString() ?? '';
        _txtEmail.text = m['email']?.toString() ?? '';
        _txtMobile.text = m['phone']?.toString() ?? '';
        _txtAddress.text = m['address']?.toString() ?? '';
        _greetingName = _txtName.text.isNotEmpty ? _txtName.text : 'bạn';
        _loading = false;
        _error = null;
      } else {
        _loading = false;
        _error = 'Không tải được hồ sơ (${res.statusCode}).';
      }
      setState(() {});
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Lỗi kết nối: $e';
        });
      }
    }
  }

  // --- Chọn ảnh từ thư viện ---
  Future<void> _pickAvatar() async {
    final p = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (p != null) setState(() => _pickedAvatar = p);
  }

  // --- Lưu hồ sơ: PUT /api/auth/profile (có thể kèm đổi mật khẩu) ---
  Future<void> _save() async {
    final token = await AuthToken.get();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa đăng nhập.')),
      );
      return;
    }
    if (_txtPassword.text.isNotEmpty || _txtConfirmPassword.text.isNotEmpty) {
      if (_txtPassword.text != _txtConfirmPassword.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mật khẩu xác nhận không khớp')),
        );
        return;
      }
      if (_txtPassword.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mật khẩu tối thiểu 6 ký tự')),
        );
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final body = <String, dynamic>{
        'fullname': _txtName.text,
        'phone': _txtMobile.text,
        'address': _txtAddress.text,
      };
      if (_txtPassword.text.isNotEmpty) {
        body['password'] = _txtPassword.text;
        body['confirmPassword'] = _txtConfirmPassword.text;
      }
      final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/profile');
      final res = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        _txtPassword.clear();
        _txtConfirmPassword.clear();
        final m = jsonDecode(res.body) as Map<String, dynamic>;
        _greetingName = m['fullname']?.toString().isNotEmpty == true
            ? m['fullname'].toString()
            : 'bạn';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu hồ sơ')),
        );
        setState(() {});
      } else {
        String msg = 'Lưu thất bại';
        try {
          msg = (jsonDecode(res.body) as Map)['message']?.toString() ?? msg;
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // --- Đăng xuất: clear JWT, đưa Login lên stack gốc (không lồng trong tab) ---
  Future<void> _signOut() async {
    await AuthToken.clear();
    if (!mounted) return;
    // rootNavigator: tránh đẩy LoginView vào stack trong tab → vẫn còn bottom bar ngoài
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: TColor.background,
        elevation: 0,
        title: Text(
          'Profile',
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
      // --- UI: loading / form / lỗi ---
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_error != null) ...[
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: TColor.red, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _loadProfile,
                      child: Text('Thử lại', style: TextStyle(color: TColor.orangeDark)),
                    ),
                  ],
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: TColor.textfield,
                        backgroundImage: _pickedAvatar != null
                            ? FileImage(File(_pickedAvatar!.path))
                            : null,
                        child: _pickedAvatar == null
                            ? Icon(Icons.person_rounded, size: 56, color: TColor.placeholder)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _pickAvatar,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(Icons.camera_alt_rounded, size: 18, color: TColor.placeholder),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.edit_rounded, size: 18, color: TColor.orangeDark),
                    label: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: TColor.orangeDark,
                      ),
                    ),
                  ),
                  Text(
                    _error == null ? 'Hi there $_greetingName!' : 'Hi there!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: TColor.primaryText,
                    ),
                  ),
                  TextButton(
                    onPressed: _signOut,
                    child: Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 14,
                        color: TColor.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_error == null) ...[
                    RoundTitleTextfield(
                      title: 'Name',
                      hintText: 'Họ và tên',
                      controller: _txtName,
                    ),
                    const SizedBox(height: 14),
                    RoundTitleTextfield(
                      title: 'Email',
                      hintText: 'Email',
                      controller: _txtEmail,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true,
                    ),
                    const SizedBox(height: 14),
                    RoundTitleTextfield(
                      title: 'Mobile No',
                      hintText: 'Số điện thoại',
                      controller: _txtMobile,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    RoundTitleTextfield(
                      title: 'Address',
                      hintText: 'Địa chỉ',
                      controller: _txtAddress,
                    ),
                    const SizedBox(height: 14),
                    RoundTitleTextfield(
                      title: 'Password',
                      hintText: 'Để trống nếu không đổi',
                      controller: _txtPassword,
                      obscureText: true,
                    ),
                    const SizedBox(height: 14),
                    RoundTitleTextfield(
                      title: 'Confirm Password',
                      hintText: 'Xác nhận mật khẩu mới',
                      controller: _txtConfirmPassword,
                      obscureText: true,
                    ),
                    const SizedBox(height: 28),
                    RoundButton(
                      title: _saving ? 'Đang lưu...' : 'Save',
                      backgroundColor: TColor.orangeDark,
                      isDisabled: _saving,
                      onPressed: _save,
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
