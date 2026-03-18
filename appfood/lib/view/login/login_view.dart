import 'package:appfood/common/color_extension.dart';
import 'package:appfood/common_widget/round_button.dart';
import 'package:appfood/common_widget/round_icon_button.dart';
import 'package:appfood/common_widget/round_textfield.dart';
import 'package:appfood/view/login/rest_password_view.dart';
import 'package:appfood/view/login/sing_up_view.dart';
import 'package:appfood/view/main_tabview/main_tabview.dart';
import 'package:appfood/view/on_boarding/on_boarding_view.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
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
              RoundButton(
                title: "Login",
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const OnBoardingView()),
                    (route) => false,
                  );
                },
              ),

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
                onPressed: () {
                  print("Facebook login");
                },
              ),

              SizedBox(height: 25),

              RoundIconButton(
                title: "Login with Google",
                icon: "assets/img/google_logo.png",
                backgroundColor: const Color(0xFF6F0706),

                onPressed: () {
                  print("Google login");
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
