import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static User? currentUser;
  static String? currentChatRoomOfUser = "";
}
