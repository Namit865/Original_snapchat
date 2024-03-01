// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:awesome_icons/awesome_icons.dart';
import 'package:chat_app/Helper/auth_helper.dart';
import 'package:chat_app/Views/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:get/get.dart';

import '../../Controller/authcontroller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Duration get logintime => const Duration(milliseconds: 3000);

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    return Scaffold(
      body: GetBuilder<AuthController>(
        builder: (controller)
        => FlutterLogin(
          theme: LoginTheme(
            pageColorDark: const Color(0xffFFFBFE),
            pageColorLight: const Color(0xffFFFC00),
            titleStyle: const TextStyle(color: Colors.white),
            buttonTheme: const LoginButtonTheme(
              backgroundColor: Color(0xffF5ED00),
            ),
            cardTheme: const CardTheme(
              color: Colors.white,
            ),
          ),
          logo: "asset/snapchat.png",
          title: "SnapChat",
          loginProviders: <LoginProvider>[
            LoginProvider(
              button: Buttons.google,
              callback: () async {
                await Future.delayed(logintime);
                await AuthHelper.authHelper.loginUserWithGoogle().then((value) {
                  Get.offAll(() => HomeScreen());
                });
                return null;
              },
              label: "Google",
              icon: FontAwesomeIcons.google,
            ),
            LoginProvider(
              label: "Phone Number",
              icon: FontAwesomeIcons.phone,
              button: Buttons.anonymous,
              callback: () {
                return null;
              },
            )
          ],
          onRecoverPassword: (_) {
            return null;
          },
          onLogin: (LoginData loginData) async {
            return await AuthHelper.authHelper.loginUserWithEmailAndPassword(
              email: loginData.name,
              password: loginData.password,
            );
          },
          onSignup: (SignupData signupData) async {
            return await AuthHelper.SignupwithEmailandPassword(
              email: signupData.name!,
              password: signupData.password!,
            );
          },
          onSubmitAnimationCompleted: () {
            if (AuthController.currentUser != null) {
              Get.offAll(
                () => HomeScreen(),
              );
            }
          },
        ),
      ),
    );
  }
}
