import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:appfood/common/color_extension.dart';
import 'package:appfood/common_widget/round_button.dart';
import 'package:appfood/common_widget/round_icon_button.dart';
import 'package:appfood/common_widget/round_textfield.dart';
import 'package:appfood/view/login/rest_password_view.dart';
import 'package:appfood/view/login/sing_up_view.dart';
import 'package:appfood/view/main_tabview/main_tabview.dart';
import 'package:appfood/view/on_boarding/on_boarding_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();

  Future<void> _login() async {
    if (txtEmail.text.isEmpty || txtPassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập Email và Mật khẩu")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Đối với Emulator Android, localhost là 10.0.2.2. IOS/Web là localhost
    final url = Uri.parse('http://localhost:3000/api/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': txtEmail.text,
          'password': txtPassword.text,
        }),
      );

      if (!mounted) return;
      Navigator.pop(context); // close dialog

      if (response.statusCode == 200) {

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Đăng nhập thành công!")));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainTabView()),
          (route) => false,
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Lỗi đăng nhập")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // close dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi kết nối server: $e")));
    }
  }

  Future<void> _handleSocialLogin(
    String provider,
    String email,
    String fullname,
    String providerId,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final url = Uri.parse('http://localhost:3000/api/auth/social');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider': provider,
          'email': email,
          'fullname': fullname,
          'provider_id': providerId,
        }),
      );

      if (!mounted) return;
      Navigator.pop(context); // close dialog

      if (response.statusCode == 200) {
        // final data = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đăng nhập $provider thành công!")),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainTabView()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi chứng thực từ server")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi kết nối: $e")));
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
                "Login",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: TColor.primaryText,
                ),
              ),

              Text(
                "Add your details to login",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: TColor.secondaryText,
                ),
              ),
              const SizedBox(height: 35),

              RoundTextfield(
                hintText: "Your Email",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 25),
              RoundTextfield(
                hintText: "Password",
                controller: txtPassword,
                obscureText: true,
              ),
              const SizedBox(height: 25),
              RoundButton(title: "Login", onPressed: _login),

              const SizedBox(height: 25),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResetPasswordView(),
                    ),
                  );
                },
                child: Text(
                  "Forgot your password?",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: TColor.orangeDark,
                  ),
                ),
              ),
              SizedBox(height: 15),
              Text(
                "or login with",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: TColor.secondaryText,
                ),
              ),
              SizedBox(height: 35),
              RoundIconButton(
                title: "Login with Facebook",
                icon: "assets/img/facebook_logo.png",
                backgroundColor: const Color(0xff367FC0),
                onPressed: () async {
                  try {
                    print("Bắt đầu gọi Facebook SDK...");
                    final LoginResult result = await FacebookAuth.instance
                        .login(permissions: ['public_profile', 'email']);

                    if (result.status == LoginStatus.success) {
                      final userData = await FacebookAuth.instance
                          .getUserData();
                      print(
                        "Facebook Login Success! Tên: ${userData['name']}",
                      );
                      _handleSocialLogin(
                        'facebook',
                        userData['email'] ?? "${userData['id']}@facebook.com",
                        userData['name'] ?? 'Facebook User',
                        userData['id'] ?? '',
                      );
                    } else {
                      print("Facebook Login Status: ${result.status}");
                      if (result.status == LoginStatus.failed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Lỗi Facebook: ${result.message}"),
                          ),
                        );
                      }
                    }
                  } catch (error) {
                    print("Facebook Login Error: \$error");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Yêu cầu cấu hình App ID Facebook để dùng tính năng này.",
                        ),
                      ),
                    );
                  }
                },
              ),

              SizedBox(height: 25),

              RoundIconButton(
                title: "Login with Google",
                icon: "assets/img/google_logo.png",
                backgroundColor: const Color(0xFF6F0706),

                onPressed: () async {
                  try {
                    print("Bắt đầu gọi Google SDK...");
                    final GoogleSignIn googleSignIn = GoogleSignIn();
                    // Đăng xuất rỗng trước để force chọn tài khoản (tuỳ chọn)
                    // await googleSignIn.signOut();
                    final GoogleSignInAccount? googleUser = await googleSignIn
                        .signIn();

                    if (googleUser != null) {
                      print(
                        "Google Login Success! Tên: ${googleUser.displayName}",
                      );
                      // Đẩy thông tin lên Backend Auth của chúng ta
                      _handleSocialLogin(
                        'google',
                        googleUser.email,
                        googleUser.displayName ?? 'Google User',
                        googleUser.id,
                      );
                    }
                  } catch (error) {
                    print("Google Login Error: \$error");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi Google Sign In: \$error")),
                    );
                  }
                },
              ),

              SizedBox(height: 30),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpView()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: TColor.secondaryText,
                      ),
                    ),
                    Text(
                      "Sign Up",
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
