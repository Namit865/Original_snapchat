import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_app/Views/Home%20Screens/Controller/homescreen_controller.dart';

class ThemePage extends StatefulWidget {
  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  final HomePageController controller = Get.find<HomePageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'Appearance',
          placeholderBuilder: (context, heroSize, child) {
            return const Text(
              "App Appearance",
              style: TextStyle(fontSize: 15, color: Colors.black),
            );
          },
          flightShuttleBuilder: (flightContext, animation, flightDirection,
              fromHeroContext, toHeroContext) {
            return const Text(
              "App Appearance",
              style: TextStyle(fontSize: 15, color: Colors.black),
            );
          },
          transitionOnUserGestures: true,
          child: Text(
            'App Appearance',
            style: TextStyle(
                color: controller.isDark.value ? Colors.black54 : Colors.white),
          ),
        ),
      ),
      body: Obx(
        () => Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "App is going to be automatically relaunched after selecting one of the available options",
                style: TextStyle(
                    color:
                        controller.isDark.value ? Colors.black54 : Colors.white,
                    fontSize: 12),
              ),
            ),
            ListTile(
              enabled: !controller.isDark.value,
              onTap: () async {
                if (!controller.isDark.value) {
                  await controller.dayNightTheme(light: false);
                }
              },
              trailing:
                  controller.isDark.value ? const Icon(Icons.check) : null,
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
              enabled: controller.isDark.value,
              onTap: () async {
                if (controller.isDark.value) {
                  await controller.dayNightTheme(light: true);
                }
              },
              trailing:
                  controller.isDark.value ? null : const Icon(Icons.check),
              title: const Text(
                "Always Dark",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(
              thickness: 1,
              indent: 15,
              endIndent: 15,
            ),
          ],
        ),
      ),
    );
  }
}
