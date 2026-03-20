import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:appfood/common/color_extension.dart';
import 'package:appfood/common_widget/round_button.dart';

import 'package:appfood/common_widget/round_textfield.dart';
import 'package:appfood/view/login/login_view.dart';
import 'package:appfood/view/login/otp_view.dart';
import 'package:flutter/material.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  TextEditingController txtName = TextEditingController();
  TextEditingController txtMobile = TextEditingController();
  TextEditingController txtAddress = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtConfirmPassword = TextEditingController();

  Future<void> _signUp() async {
    if (txtPassword.text != txtConfirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mật khẩu không khớp!")));
      return;
    }
    
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    
    // Đối với Emulator Android, localhost là 10.0.2.2. IOS/Web là localhost
    final url = Uri.parse('http://localhost:3000/api/auth/register');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullname': txtName.text,
          'email': txtEmail.text,
          'phone': txtMobile.text,
          'address': txtAddress.text,
          'password': txtPassword.text,
        }),
      );
      
      if (!mounted) return;
      Navigator.pop(context); // close dialog
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đăng ký thành công!")));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OtpView()),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? "Lỗi đăng ký")));
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // close dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi kết nối server: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 74),
              Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: TColor.primaryText,
                ),
              ),

              Text(
                "Add your details to sign up",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: TColor.secondaryText,
                ),
              ),
              const SizedBox(height: 35),
              RoundTextfield(hintText: "Name", controller: txtName),
              const SizedBox(height: 25),

              RoundTextfield(
                hintText: "Email",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 25),
              RoundTextfield(
                hintText: "Mobile No",
                controller: txtMobile,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 25),
              RoundTextfield(hintText: "Address", controller: txtAddress),
              const SizedBox(height: 25),
              RoundTextfield(
                hintText: "Password",
                controller: txtPassword,
                obscureText: true,
              ),
              const SizedBox(height: 25),
              RoundTextfield(
                hintText: "Confirm Password",
                controller: txtConfirmPassword,
                obscureText: true,
              ),
              const SizedBox(height: 30),
              RoundButton(
                title: "Sign Up",
                onPressed: _signUp,
              ),

              SizedBox(height: 30),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: TColor.secondaryText,
                      ),
                    ),
                    Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: TColor.orangeDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
