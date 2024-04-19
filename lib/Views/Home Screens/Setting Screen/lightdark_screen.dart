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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("asset/appbar.gif"),
              fit: BoxFit.cover,
              repeat: ImageRepeat.repeat,
              filterQuality: FilterQuality.high,
              isAntiAlias: true,
            ),
          ),
        ),
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
            Switch(
              value: controller.isDark.value ? false : true,
              onChanged: (val) {
                controller.dayNightTheme(light: true);
              },
              thumbIcon: MaterialStatePropertyAll(
                controller.isDark.value
                    ? const Icon(Icons.light_mode)
                    : const Icon(Icons.dark_mode),
              ),
              autofocus: true,
            ),
          ],
        ),
      ),
    );
  }
}
