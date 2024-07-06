import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Controller/authcontroller.dart';
import '../../../Helper/firebase_helper.dart';
import '../../../Models/user.dart';

class HomePageController extends GetxController {
  late RxInt currentIndex = 1.obs;
  RxList<userData> fetchedAllUserData = <userData>[].obs;
  RxBool isDark = false.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
    update();
  }

  @override
  void onInit() async {
    super.onInit();
    fetchData();
  }

  fetchData() async {
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
