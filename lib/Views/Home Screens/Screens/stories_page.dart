import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Controller/authcontroller.dart';
import '../Controller/homescreen_controller.dart';
import '../Setting Screen/setting_screen.dart';

class Stories extends StatefulWidget {
  const Stories({super.key});

  @override
  State<Stories> createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {
  final HomePageController controller = Get.put(HomePageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 40,
        leading: Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              flex: 5,
              child: CircleAvatar(
                  backgroundColor: Colors.black38,
                  backgroundImage:
                  (AuthController.currentUser?.photoURL != null)
                      ? NetworkImage(AuthController.currentUser!.photoURL!)
                      : null,
                  radius: 25,
                  child: AuthController.currentUser?.photoURL == null
                      ? const Icon(Icons.person, color: Colors.black)
                      : null),
            ),
            const Spacer(),
            Expanded(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.search_sharp,
                  color: Colors.black,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {},
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(30),
              ),
              height: 25,
              width: 25,
              child: Image.asset(
                alignment: Alignment.center,
                'asset/invite.png',
                color: Colors.black.withOpacity(0.6),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              Get.to(const SettingPage());
            },
            child: const Icon(
              Icons.more_horiz,
              size: 30,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 10),
        ],
        centerTitle: true,
        title: const Text(
          "Stories",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
