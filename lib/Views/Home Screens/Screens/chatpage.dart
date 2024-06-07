import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:chat_app/Models/chatpage_variables.dart';
import 'package:chat_app/Controller/authcontroller.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../Helper/firebase_helper.dart';
import '../Controller/homescreen_controller.dart';

class ChatPage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const ChatPage({
    Key? key,
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ScrollController scrollController = ScrollController();
  HomePageController controller = Get.find<HomePageController>();
  final TextEditingController _controller = TextEditingController();
  static const appId = '7fa99ea40b90446990f1b30f68bbb4c7';
  static const channelId = 'Chat Application 2024';

  int? remoteuid;
  bool localUserJoined = false;
  late RtcEngine engine;

  @override
  void initState() {
    super.initState();
    markMessagesRead();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint("local user ${connection.localUid} Joined");
          setState(() {
            localUserJoined = true;
          });
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          debugPrint("remote user $remoteUid Joined");
          setState(() {
            remoteuid = remoteUid;
          });
        },
        onUserOffline: (connection, remoteUid, reason) {
          debugPrint("remote user $remoteUid left Channel");
          setState(() {
            remoteuid = null;
          });
        },
        onTokenPrivilegeWillExpire: (connection, token) {
          debugPrint(
              '[onTokenpriviledgeWillExpire] Connection : ${connection.toJson()},token : $token');
        },
      ),
    );
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine.enableVideo();
    await engine.startPreview();

    await engine.joinChannel(
        token: '007eJxTYAhO21TVq3lwkTbTmvueb1JO8s5eNrX9bJr5tzNzwwVkq7gVGMzTEi0tUxNNDJIsDUxMzCwtDdIMk4wN0swskpKSTJLNn6QkpjUEMjIcvjiPkZEBAkF8UQbnjMQSBceCgpzM5MSSzPw8BSMDIxMGBgCuziVZ',
        channelId: channelId,
        uid: 0,
        options: ChannelMediaOptions());
  }

  void markMessagesRead() async {
    String chatRoomId = AuthController.currentChatRoomOfUser!;
    await FireStoreHelper.fireStoreHelper.markMessagesAsRead(chatRoomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Colors.black,
        leadingWidth: 200,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(
                CupertinoIcons.back,
                size: 28,
              ),
              onPressed: () {
                Get.back();
              },
            ),
            const CircleAvatar(radius: 18),
            const SizedBox(width: 10),
            Text(
              widget.userName,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {},
            icon: const Icon(Icons.videocam_rounded),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.phone),
          ),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FireStoreHelper.fireStoreHelper.getMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<getMessageData> fetchData = snapshot.data!.docs.map(
              (e) {
                DateTime dateTime = (e['time'] as Timestamp).toDate();
                String formattedDateTime =
                    DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
                bool read = e.data().containsKey('read') ? e['read'] : null;
                return getMessageData(
                  sender: e['sender'] ?? '',
                  message: e.data().containsKey('message') ? e['message'] : '',
                  receiver: e['receiver'] ?? '',
                  time: formattedDateTime,
                  read: read,
                );
              },
            ).toList();

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: fetchData.length,
                      itemBuilder: (context, index) {
                        final message = fetchData[index];
                        return Row(
                          mainAxisAlignment: message.receiver ==
                                  AuthController.currentUser!.email
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: ChatBubble(
                                backGroundColor: const Color(0xffFFFAA0),
                                clipper: ChatBubbleClipper6(
                                    type: message.receiver ==
                                            AuthController.currentUser!.email
                                        ? BubbleType.receiverBubble
                                        : BubbleType.sendBubble),
                                child: Row(
                                  crossAxisAlignment: message.sender ==
                                          AuthController.currentUser!.email
                                      ? CrossAxisAlignment.start
                                      : CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      message.message,
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                    Text(
                                      message.time.split("-")[1],
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 6,
                        child: TextFormField(
                          onTap: () {
                            scrollController.animateTo(
                              scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 10),
                              curve: Curves.easeInOut,
                            );
                          },
                          cursorColor: Colors.yellow,
                          controller: _controller,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              filled: true,
                              suffixIcon: InkWell(
                                onTap: () {},
                                child: const Icon(
                                  CupertinoIcons.paperclip,
                                  size: 20,
                                ),
                              ),
                              isDense: true,
                              hintText: "Send Message",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(35),
                                  borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            color: const Color(0xffFFF375),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: IconButton(
                            color: Colors.white,
                            icon: const Icon(Icons.send, size: 30),
                            onPressed: () async {
                              if (_controller.text.trim().isNotEmpty) {
                                await FireStoreHelper.fireStoreHelper
                                    .sendMessage(
                                  AuthController.currentUser!.email!,
                                  widget.userEmail,
                                  _controller.text,
                                );
                                scrollController.animateTo(
                                  scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 10),
                                  curve: Curves.easeInOut,
                                );
                              }
                              _controller.clear();
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
  Widget remoteVideo() {
    if (remoteuid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine,
          canvas: VideoCanvas(uid: remoteuid),
          connection: const RtcConnection(channelId: "Chat Application 2024"),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}
