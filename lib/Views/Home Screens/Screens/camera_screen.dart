import 'dart:async';
import 'package:camera/camera.dart';
import 'package:chat_app/Views/Home%20Screens/Profile%20Screens/profile_screen.dart';
import 'package:chat_app/Views/Home%20Screens/Screens/addFriends.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../../../Controller/authcontroller.dart';
import '../Controller/homescreen_controller.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final HomePageController controller = Get.put(HomePageController());
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool isRecording = false;
  Timer? timer;
  bool showRecordingText = false;
  int recordingDuration = 15;
  Timer? _recordingTextTimer;
  String? videoPath;
  double incHeight = 100;
  double incWidth = 100;
  bool showBlinkingText = false;
  int selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> onCameraSwitched(int index) async {
    _controller?.dispose();
    _controller = CameraController(
      _cameras![index],
      ResolutionPreset.ultraHigh,
      enableAudio: true,
    );

    try {
      await _controller?.initialize();
      await _controller?.lockCaptureOrientation(DeviceOrientation.portraitUp);
      setState(() {
        _isCameraInitialized = true;
        selectedCameraIndex = index;
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      onCameraSwitched(selectedCameraIndex);
    }
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _recordingTextTimer?.cancel();
    timer?.cancel();
    super.dispose();
  }

  void blinkingText() {
    _recordingTextTimer?.cancel();
    _recordingTextTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        showBlinkingText != showBlinkingText;
      });
    });
  }

  Future<void> startRecording() async {
    if (_controller != null && !_controller!.value.isRecordingVideo) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        videoPath = path.join(directory.path, '${DateTime.now()}.mp4');
        await _controller!.startVideoRecording();
        print('Recording started: $videoPath');

        setState(() {
          isRecording = true;
          showBlinkingText = true;
        });

        blinkingText();

        _recordingTextTimer?.cancel();
        _recordingTextTimer = Timer(const Duration(seconds: 2), () {
          setState(() {
            showRecordingText = false;
          });
        });

        timer = Timer(Duration(seconds: recordingDuration), () async {
          await stopRecording();
        });

        Get.snackbar('Success', 'Video Recording Starts');
      } catch (e) {
        print('Error starting recording: $e');
      }
    }
  }

  Future<void> stopRecording() async {
    if (_controller != null && _controller!.value.isRecordingVideo) {
      try {
        XFile videoFile = await _controller!.stopVideoRecording();
        print('Recording stopped: ${videoFile.path}');

        timer?.cancel();
        setState(() {
          isRecording = false;
          showBlinkingText = false;
        });

        Get.snackbar("Video Taken Successfully", "Saved");
      } catch (e) {
        print('Error stopping recording: $e');
      }
    }
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) {
      print('Error: select a camera first.');
      return;
    }

    if (_controller!.value.isTakingPicture) {
      return;
    }

    try {
      XFile picture = await _controller!.takePicture();
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/Pictures/flutter_test';
      await Directory(dirPath).create(recursive: true);
      final String filePath =
          '$dirPath/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await picture.saveTo(filePath);
      print('Picture saved to $filePath');
      Get.snackbar(
        "Picture Taken And Saved Successfully",
        filePath,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () {
            OpenFile.open(filePath);
          },
          child: const Text(
            'View',
            style: TextStyle(color: Colors.purple),
          ),
        ),
      );
    } catch (e) {
      print('Error: $e');
      return;
    }
  }

  void switchCamera() {
    if (_cameras != null && _cameras!.length > 1) {
      int newIndex = (selectedCameraIndex + 1) % _cameras!.length;
      onCameraSwitched(newIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        leadingWidth: 150,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Row(
          children: [
            const SizedBox(width: 15),
            GestureDetector(
              onTap: () {
                Get.to(
                  transition: Transition.rightToLeftWithFade,
                  () => ProfileScreen(),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.white54,
                backgroundImage: (AuthController.currentUser?.photoURL != null)
                    ? NetworkImage(AuthController.currentUser!.photoURL!)
                    : null,
                radius: 15,
                child: AuthController.currentUser?.photoURL == null
                    ? const Icon(Icons.person, color: Colors.black)
                    : null,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search_sharp,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Get.to(
                transition: Transition.downToUp,
                () =>  const AddFriends(),
              );
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(30),
              ),
              height: 22,
              width: 22,
              child: Image.asset(
                alignment: Alignment.center,
                'asset/invite.png',
                color: Colors.white.withOpacity(0.9),
                fit: BoxFit.cover,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.cameraswitch_rounded,
              size: 25,
              color: Colors.white,
            ),
            onPressed: switchCamera,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (_isCameraInitialized)
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Transform(
                      filterQuality: FilterQuality.high,
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi * 8),
                      child: CameraPreview(_controller!),
                    ),
                    GestureDetector(
                      onLongPressStart: (_) async {
                        await startRecording();
                        setState(() {
                          incHeight = 130;
                          incWidth = 130;
                        });
                      },
                      onLongPressEnd: (_) async {
                        await stopRecording();
                        setState(() {
                          incHeight = 100;
                          incWidth = 100;
                        });
                      },
                      onTap: () {
                        _takePicture();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 30),
                        height: incHeight,
                        width: incWidth,
                        decoration: const BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.all(
                            Radius.circular(60),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 60,
                      bottom: 50,
                      child: IconButton(
                        onPressed: () {},
                        icon: SizedBox(
                          height: 30,
                          child: Image.asset(
                            "asset/album.png",
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 60,
                      bottom: 50,
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          CupertinoIcons.smiley,
                          size: 35,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (isRecording && showBlinkingText)
                      const Positioned(
                        bottom: 650,
                        child: Center(
                          child: Text(
                            "Recording....",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.yellow,
                                fontSize: 25),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
