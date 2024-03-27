import 'dart:async';
import 'package:chat_app/Views/Login%20Screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../Controller/authcontroller.dart';
import '../Models/user.dart';
import 'firebase_helper.dart';

class AuthHelper {
  AuthHelper._();

  static final AuthHelper authHelper = AuthHelper._();

  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<void> signOut() async {
    await firebaseAuth.signOut().then(
          (value) => Get.offAll(
            () => const LoginScreen(),
          ),
        );
  }

  static Future<String?> SignupwithEmailandPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      userData data = userData(
        name: "${email.split("@")[0].capitalizeFirst}",
        email: email,
        password: password,
      );

      AuthController.currentUser = userCredential.user!;
      await FireStoreHelper.fireStoreHelper.addUserInFirebaseFireStore(data);
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      print("Unexpected Error: $e");
      return "Unexpected error occurred";
    }
    return null;
  }

  Future<String?> loginUserWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      AuthController.currentUser = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return '${e.code}';
      }
    }
    return null;
  }

  Future<User?> loginUserWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      AuthController.currentUser = await userCredential.user;

      return AuthController.currentUser;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }
}
