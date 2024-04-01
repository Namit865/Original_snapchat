import 'package:chat_app/Helper/firebase_helper.dart';
import 'package:chat_app/Models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class HomePageController extends GetxController {
  late RxInt currentIndex = 0.obs;
  RxList<userData> fetchedAllUserData = <userData>[].obs;
  RxBool isDark = false.obs;
  RxList<Map<String, String>> lastMessages = <Map<String, String>>[].obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() async {
    super.onInit();

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

    lastMessages.value = (await FireStoreHelper.fireStoreHelper
        .getAllLastMessages(data)) as List<Map<String, String>>;
  }
}
