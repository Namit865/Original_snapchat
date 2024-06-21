import 'dart:convert';

import 'package:chat_app/Helper/auth_helper.dart';
import 'package:chat_app/Models/settings_model.dart';
import 'package:chat_app/Views/Home%20Screens/Controller/homescreen_controller.dart';
import 'package:chat_app/jsonData/jsondata_settingpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<SettingItems> settingItems = [];

  @override
  void initState() {
    super.initState();
    settingItems = parseSettings(settingDataJson);
  }

  List<SettingItems> parseSettings(String jsonStr) {
    final jsonData = json.decode(jsonStr);
    return (jsonData['settings'] as List)
        .map((item) => SettingItems.fromJson(item))
        .toList();
  }

  HomePageController controller = Get.find<HomePageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leadingWidth: 150,
        toolbarHeight: 40,
        leading: Row(
          children: [
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: const Icon(
                CupertinoIcons.back,
                size: 30,
                color: Color(0xff27BA49),
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff27BA49),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: ListView.builder(
            itemCount: settingItems.length,
            itemBuilder: (BuildContext context, int index) {
              var setting = settingItems[index];
              return ListTile(
                tileColor: const Color(0xff1D1D1D),
                onTap: (){
                  Get.dialog(
                      showAlertBox()
                  );
                },
                title:
                    Text(setting.title, style: TextStyle(color: Colors.white)),
                trailing: setting.trailingText != null
                    ? Text(setting.trailingText!,
                        style: TextStyle(color: Colors.grey))
                    : null,
              );
            },
          ),
        ),
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
