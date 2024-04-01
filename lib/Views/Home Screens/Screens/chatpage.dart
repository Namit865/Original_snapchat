import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/Models/chatpage_variables.dart';
import 'package:chat_app/Controller/authcontroller.dart';
import '../../../Helper/firebase_helper.dart';

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
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffFFF375),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 22,
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              widget.userName,
              style:
              const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FireStoreHelper.fireStoreHelper.getMessages(),
          builder: (context, snapshot) {
            List<getMessageData> fetchData = [];
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              fetchData = snapshot.data!.docs.map(
                    (e) {
                  DateTime dateTime = (e['time'] as Timestamp).toDate();
                  String formattedDateTime =
                  DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
                  return getMessageData(
                    sender: e['sender'] ?? '',
                    message:
                    e.data().containsKey('message') ? e['message'] : '',
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
                      child: ListView(
                        controller: scrollController,
                        children: fetchData
                            .map(
                              (e) => Row(
                            mainAxisAlignment: (e.receiver ==
                                AuthController.currentUser!.email)
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 10,
                                    left: 10,
                                    bottom: 5,
                                    top: 5),
                                child: Chip(
                                  side: const BorderSide(
                                    width: 1,
                                    color: Colors.white,
                                  ),
                                  elevation: 15,
                                  label: Column(
                                    crossAxisAlignment: (e.sender ==
                                        AuthController
                                            .currentUser!.email)
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.end,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: e.message,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16),
                                            ),
                                            TextSpan(
                                                text:
                                                e.time.split("-")[1],
                                                style: const TextStyle(
                                                    color:
                                                    Colors.black54)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            .toList(),
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
                              isDense: true,
                              hintText: "Send Message",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
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
                                      _controller.text);
                                  // Scroll to the bottom after sending message
                                  scrollController.animateTo(
                                    scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 300),
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
          }),
    );
  }
}
