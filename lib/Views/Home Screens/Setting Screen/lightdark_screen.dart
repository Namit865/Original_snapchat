import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_app/Views/Home%20Screens/Controller/homescreen_controller.dart';

class ThemePage extends StatelessWidget {
  final HomePageController _homePageController = Get.find<HomePageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Appearance'),
      ),
      body: Obx(
        () => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "App is going to be automatically relaunched after selecting one of the available options",
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
            ListTile(
              onTap: () {
                _homePageController.toggleLightTheme();
              },
              trailing: _homePageController.isDark.value
                  ? null
                  : const Icon(Icons.check),
              title: const Text(
                "Always Light",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(
              thickness: 1,
              indent: 15,
              endIndent: 15,
            ),
            ListTile(
              onTap: () async {
                await _homePageController.toggleDarkTheme();
              },
              trailing: _homePageController.isDark.value
                  ? const Icon(Icons.check)
                  : null,
              title: const Text(
                "Always Dark",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
