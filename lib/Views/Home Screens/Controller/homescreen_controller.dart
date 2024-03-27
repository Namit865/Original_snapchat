import 'package:chat_app/Helper/firebase_helper.dart';
import 'package:chat_app/Models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomePageController extends GetxController {
  late RxInt currentIndex = 0.obs;
  RxList<userData> fetchedAllUserData = <userData>[].obs;
  RxBool isDark = false.obs;

  final box = GetStorage();

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() async {
    super.onInit();
    isDark.value = box.read('isDark') ?? false;
    List<QueryDocumentSnapshot<Object?>> data =
        await FireStoreHelper.fireStoreHelper.fetchAllUserData();

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

  toggleDarkTheme() {
    Get.changeThemeMode(isDark.value ? ThemeMode.light : ThemeMode.dark);
    isDark.value =! isDark.value;
    box.write('isDark', isDark.value);
  }

  toggleLightTheme() {
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
    isDark.value =! isDark.value;
    box.write('isDark', isDark.value);
  }

  ExitApp() {}
}
