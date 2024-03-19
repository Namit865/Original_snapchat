import 'package:chat_app/Helper/firebase_helper.dart';
import 'package:chat_app/Models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class HomePageController extends GetxController {
  late RxInt currentIndex = 0.obs;
  RxList<userData> fetchedAllUserData = <userData>[].obs;

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
  }
}
