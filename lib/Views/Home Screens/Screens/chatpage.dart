import 'package:chat_app/Controller/authcontroller.dart';
import 'package:chat_app/Models/chatpage_variables.dart';
import 'package:flutter/material.dart';

import '../../../Helper/firebase_helper.dart';

class chatPage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const chatPage({
    Key? key,
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<chatPage> createState() => _chatPageState();
}

class _chatPageState extends State<chatPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
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
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: FireStoreHelper.fireStoreHelper.getMessage(),
        builder: (context, snapshot) {
          List<getMessageData> fetchData = [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else{

          } if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemBuilder: (BuildContext context, int index) {},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 6,
                        child: TextFormField(
                          controller: _controller,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
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
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: IconButton(
                              color: Colors.white,
                              icon: const Icon(Icons.send, size: 30),
                              onPressed: () {
                                if (_controller.text.isNotEmpty) {
                                  FireStoreHelper.fireStoreHelper.sendMessage(
                                      AuthController.currentUser!.email!,
                                      widget.userEmail,
                                      _controller.text);
                                  _controller.text;
                                  _controller.clear();
                                }
                              }),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          }
      ),
    );
  }
}
