import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:chat_app/Models/chatpage_variables.dart';
import 'package:chat_app/Controller/authcontroller.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffFFF375),
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
        title: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 22),
                const SizedBox(width: 20),
                Text(
                  widget.userName,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold,color: Colors.white),
                ),
              ],
            ),
          ],
        ),
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
                return getMessageData(
                  sender: e['sender'] ?? '',
                  message: e.data().containsKey('message') ? e['message'] : '',
                  receiver: e['receiver'] ?? '',
                  time: formattedDateTime,
                );
              },
            ).toList();

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("asset/audi.jpeg"),
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
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
                              child: Chip(
                                side: const BorderSide(
                                    width: 1, color: Colors.white),
                                elevation: 15,
                                label: Column(
                                  crossAxisAlignment: message.sender ==
                                          AuthController.currentUser!.email
                                      ? CrossAxisAlignment.start
                                      : CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      message.message,
                                      style: TextStyle(
                                        color: controller.isDark.value
                                            ? Colors.black
                                            : Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      message.time.split("-")[1],
                                      style: TextStyle(
                                        color: controller.isDark.value
                                            ? Colors.black
                                            : Colors.white54,
                                      ),
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
                          scribbleEnabled: true,
                          cursorColor: Colors.yellow,
                          controller: _controller,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
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
                            ),
                          ),
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
}
