// ========== PHẦN PUSH: THÊM THẺ (Add Card) ==========
// Dùng từ Payment Details hoặc Checkout. POST /api/user/cards — chỉ gửi brand + last4 (demo, không lưu full PAN).

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:appfood/common/api_config.dart';
import 'package:appfood/common/auth_token.dart';
import 'package:appfood/common/color_extension.dart';
import 'package:appfood/common_widget/round_button.dart';
import 'package:appfood/common_widget/round_textfield.dart';

class AddCardView extends StatefulWidget {
  const AddCardView({super.key});

  @override
  State<AddCardView> createState() => _AddCardViewState();
}

class _AddCardViewState extends State<AddCardView> {
  final _num = TextEditingController();
  final _mm = TextEditingController();
  final _yy = TextEditingController();
  final _cvv = TextEditingController();
  final _first = TextEditingController();
  final _last = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _num.dispose();
    _mm.dispose();
    _yy.dispose();
    _cvv.dispose();
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  // --- Validate 4 số cuối → POST tạo bản ghi thẻ ---
  Future<void> _submit() async {
    final token = await AuthToken.get();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cần đăng nhập')),
      );
      return;
    }
    final digits = _num.text.replaceAll(RegExp(r'\s'), '');
    final last4 = digits.length >= 4 ? digits.substring(digits.length - 4) : '';
    if (last4.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập số thẻ (ít nhất 4 số cuối)')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/user/cards');
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'brand': 'VISA', 'last4': last4}),
      );
      if (!mounted) return;
      if (res.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thêm được thẻ')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
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
          'Add Credit/Debit Card',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: TColor.primaryText,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: TColor.primaryText),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RoundTextfield(hintText: 'Card Number', controller: _num, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            Text('Expiry', style: TextStyle(fontSize: 12, color: TColor.secondaryText)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: RoundTextfield(hintText: 'MM', controller: _mm, keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: RoundTextfield(hintText: 'YY', controller: _yy, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 16),
            RoundTextfield(hintText: 'Security Code', controller: _cvv, obscureText: true, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            RoundTextfield(hintText: 'First Name', controller: _first),
            const SizedBox(height: 16),
            RoundTextfield(hintText: 'Last Name', controller: _last),
            const SizedBox(height: 20),
            Text(
              'You can remove this card at anytime',
              style: TextStyle(fontSize: 13, color: TColor.secondaryText),
            ),
            const SizedBox(height: 28),
            RoundButton(
              title: _busy ? '...' : 'Add Card',
              backgroundColor: TColor.orangeDark,
              isDisabled: _busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
