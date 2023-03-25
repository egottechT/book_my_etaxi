import 'package:book_my_taxi/model/message_model.dart';
import 'package:book_my_taxi/service/database.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  TextEditingController textController = TextEditingController();
  List<MessageModel> messages = [];

  @override
  void initState() {
    super.initState();
    readData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Messages"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              Expanded(
                  child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemBuilder: (context, index) {
                  bool self = (messages[index].sender == "customer");
                  return Align(
                    alignment:
                        self ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      children: [
                        Container(
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: self ? Colors.green : Colors.grey),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(messages[index].msg),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  );
                },
                itemCount: messages.length,
              )),
              SizedBox(
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: textController,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                              onPressed: () {
                                uploadChatData(textController.text);
                                textController.text = "";
                                readData();
                              },
                              icon: const Icon(Icons.send)),
                          border: const OutlineInputBorder(),
                          hintText: "Message your driver..",
                          hintStyle: const TextStyle(color: Colors.grey)),
                    ))
                  ],
                ),
              )
            ],
          ),
        ));
  }

  void readData() async {
    List<MessageModel> list = await fetchMessageData();
    setState(() {
      messages = list;
    });
  }
}
