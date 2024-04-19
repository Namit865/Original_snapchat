import 'package:chat_app/Controller/authcontroller.dart';
import 'package:chat_app/Helper/firebase_helper.dart';
import 'package:chat_app/Models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePageController extends GetxController {
  late RxInt currentIndex = 1.obs;
  RxList<userData> fetchedAllUserData = <userData>[].obs;
  RxBool isDark = false.obs;

  void changeIndex(int index) {
     currentIndex.value = index;
    refresh();
    update();
  }

  @override
  void onInit() async {
    super.onInit();
    List<QueryDocumentSnapshot<Object?>> data =
        (await FireStoreHelper.fireStoreHelper.fetchAllUserData());

    for (var element in data) {
      fetchedAllUserData.add(
        userData(
          name: element['name'],
          email: element['email'],
          password: element['password'],
        ),
      );
    }
  }

  dayNightTheme({required bool light}) {
    isDark.value = !isDark.value;
    Get.changeThemeMode(isDark.value ? ThemeMode.light : ThemeMode.dark);
    update();
  }
}
