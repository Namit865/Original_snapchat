import 'package:chat_app/Views/splash%20screen/Splash%20Controller/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(splashController());
    return Scaffold(
      body: Container(
        color: Color(0xffFFFC00),
        alignment: Alignment.center,
        child: SizedBox(
          width: 200,
          height: 200,
          child: Image.asset(
            "asset/snapchat.png",
          ),
        ),
      ),
    );
  }
}
