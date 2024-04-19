import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class camerController extends GetxController {
  CameraController? controller;
  late Future<void> initializeControllerFuture;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      controller = CameraController(firstCamera, ResolutionPreset.high);
      initializeControllerFuture = controller!.initialize();
    } catch (e) {
      print("error ============= $e");
    }
  }

  toggleCamera(CameraLensDirection direction) {}

  void captureImage() async {
    try {
      final Directory? externalDirectory = await getExternalStorageDirectory();
      final String directPath = '${externalDirectory!.path}/Pictures/flutter';
      await Directory(directPath).create(recursive: true);
      final String fileName = '${DateTime.now()}.jpg';
      final String filePath = '$directPath/$fileName';
      XFile pictureFile = await controller!.takePicture();
      File(pictureFile.path).copy(filePath);
      if (pictureFile != null) {
        Get.snackbar(
            colorText: Colors.black,
            onTap: (data) {},
            'Photo Captured',
            filePath);
        print('$filePath');
      }
    } catch (e) {
      print('$e');
    }
  }
}
