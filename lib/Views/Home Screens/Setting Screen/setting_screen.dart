import 'package:chat_app/Helper/auth_helper.dart';
import 'package:chat_app/Views/Home%20Screens/Controller/homescreen_controller.dart';
import 'package:chat_app/Views/Home%20Screens/Setting%20Screen/description.dart';
import 'package:chat_app/Views/Home%20Screens/Setting%20Screen/lightdark_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class settingPage extends StatefulWidget {
  const settingPage({super.key});

  @override
  State<settingPage> createState() => _settingPageState();
}

class _settingPageState extends State<settingPage> {
  HomePageController controller = Get.find<HomePageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffFFF375),
        title: Text(
          'Settings',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: controller.isDark.value ? Colors.black : Colors.white),
        ),
      ),
      body: Obx(
        () {
          return Column(
          children: [
            InkWell(
              onTap: () {
                Get.to(
                  () => ThemePage(),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 9.0),
                child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0.5),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          offset: const Offset(0, 5),
                          spreadRadius: 3,
                          color: Colors.grey.withOpacity(0.2),
                        )
                      ]),
                  width: double.infinity,
                  child: Hero(
                    tag: 'Appearance',
                    transitionOnUserGestures: true,
                    flightShuttleBuilder: (flightContext, animation,
                        flightDirection, fromHeroContext, toHeroContext) {
                      return const Text(
                        "App Appearance",
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      );
                    },
                    placeholderBuilder: (context, heroSize, child) {
                      return const Text(
                        "App Appearance",
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      );
                    },
                    child: Text(
                      "App Appearance",
                      style: TextStyle(
                        fontSize: 18,
                        color: controller.isDark.value
                            ? Colors.black.withOpacity(0.7)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(
                  () => const Description(),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 9.0),
                child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0.5),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          offset: const Offset(0, 5),
                          spreadRadius: 3,
                          color: Colors.grey.withOpacity(0.2),
                        )
                      ]),
                  width: double.infinity,
                  child: Hero(
                    tag: "title",
                    placeholderBuilder: (context, heroSize, child) {
                      return Text(
                        "Privacy & Policy",
                        style: TextStyle(
                          color: controller.isDark.value
                              ? Colors.black.withOpacity(0.7)
                              : Colors.white,
                          fontSize: 15,
                        ),
                      );
                    },
                    flightShuttleBuilder: (flightContext, animation,
                        flightDirection, fromHeroContext, toHeroContext) {
                      return Text(
                        "Privacy & Policy",
                        style: TextStyle(
                          color: controller.isDark.value
                              ? Colors.black.withOpacity(0.7)
                              : Colors.white,
                          fontSize: 15,
                        ),
                      );
                    },
                    transitionOnUserGestures: true,
                    child: Text(
                      "Privacy & Policy",
                      style: TextStyle(
                        fontSize: 18,
                        color: controller.isDark.value
                            ? Colors.black.withOpacity(0.7)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return showAlertBox();
                    });
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0.5),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          offset: const Offset(0, 5),
                          spreadRadius: 3,
                          color: Colors.grey.withOpacity(0.2),
                        )
                      ]),
                  width: double.infinity,
                  child: Text(
                    "Log Out",
                    style: TextStyle(
                        fontSize: 18,
                        color: controller.isDark.value
                            ? Colors.black.withOpacity(0.7)
                            : Colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
        },
      ),
    );
  }

  showAlertBox() {
    return AlertDialog(
      title: const Text("Logout!"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Do you really want to Logout",
            style: TextStyle(fontSize: 20),
          ),
          Center(
            child: Lottie.asset("asset/logout.json",
                fit: BoxFit.cover, filterQuality: FilterQuality.high),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            AuthHelper.authHelper.signOut();
          },
          child: const Text("Ok"),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
