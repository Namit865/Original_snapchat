import 'package:chat_app/Controller/authcontroller.dart';
import 'package:chat_app/Helper/auth_helper.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          InkWell(
            onTap: () {
              Get.to(
                () => ThemePage(),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(15.0),
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
                  "App Appearance",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black.withOpacity(0.7),
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
              padding: const EdgeInsets.all(15.0),
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
                      fontSize: 18, color: Colors.black.withOpacity(0.7)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  showAlertBox() {
    return AlertDialog(
      title: const Text("Do you really want to Logout"),
      content: Container(
        height: 100,
        width: 100,
        child: Center(
          child: Lottie.asset("asset/logout.json",
              fit: BoxFit.cover, filterQuality: FilterQuality.high),
        ),
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
