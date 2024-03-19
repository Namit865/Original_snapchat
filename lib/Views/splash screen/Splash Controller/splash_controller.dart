import 'dart:async';
import 'package:get/get.dart';
import '../../Login Screens/login_screen.dart';

class splashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Timer(const Duration(milliseconds: 350), () {
      Get.to(const LoginScreen());

    });
  }
}
