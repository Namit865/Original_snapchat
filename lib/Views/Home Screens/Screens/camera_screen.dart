import 'package:chat_app/Views/Home%20Screens/Controller/camera_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class cameraScreen extends StatefulWidget {
  const cameraScreen({super.key});

  @override
  _cameraScreenState createState() => _cameraScreenState();
}

class _cameraScreenState extends State<cameraScreen> {
  camerController controller = Get.put(camerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: () {
              },
              child: FutureBuilder<void>(
                future: controller.initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(controller.controller!);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Positioned(
              right: 110,
              bottom: -10,
              child: GestureDetector(
                onTap: () {
                  controller.captureImage();
                },
                child: SizedBox(
                  height: 180,
                  width: 180,
                  child: Lottie.asset('asset/shot.json',
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.cover,
                      animate: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
