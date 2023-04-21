import 'dart:collection';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_chatbotgpt/models/message_model.dart';

// final messages = UnmodifiableListView<MessageModel>([MessageModel(true, 'Hi')]);
final List<MessageModel> _messages = [MessageModel(true, 'Hi')];
UnmodifiableListView<MessageModel> messages = UnmodifiableListView(_messages);
final txtMessage = TextEditingController();
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final openAI = OpenAI.instance.build(
      token: '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',
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 20)),
      isLog: true);

  // void sendMessage(String message) async {
  //   final requests = CompleteText(
  //       prompt: message, model: Model.textDavinci2, maxTokens: 10000);
  //   final res = await openAI.onCompletion(request: requests);
  //   setState(() {
  //     _messages.add(MessageModel(true, res?.choices.last.text ?? "Error"));
  //     messages = UnmodifiableListView(_messages);
  //   });
  // }

  void sendMessage(String message) async {
    const maxTokens = 2048;
    final promptLength = message.length;
    final contextLength =
        messages.fold<int>(0, (prev, m) => prev + m.message.length);
    final remainingTokens = maxTokens - promptLength - contextLength;

    final requests = CompleteText(
      prompt: message,
      model: Model.textDavinci3,
      maxTokens: remainingTokens,
    );

    final res = await openAI.onCompletion(request: requests);
    setState(() {
      _messages.add(MessageModel(true, res?.choices.last.text ?? "Error"));
      messages = UnmodifiableListView(_messages);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ChatGPT'),
        ),
        body: Stack(children: [
          Column(
            children: [
              Expanded(
                  flex: 1,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: messages.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return messages[index].isBot
                          ? BotCard(index: index)
                          : UserCard(index: index);
                    },
                  )),
            ],
          ),
          SendMessage(
            sendMessage: () => sendMessage(txtMessage.text),
          )
        ]),
      ),
    );
  }
}

class SendMessage extends StatelessWidget {
  final VoidCallback sendMessage;
  const SendMessage({
    required this.sendMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: MediaQuery.of(context).size.height * .08,
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: TextField(
          controller: txtMessage,
          decoration: InputDecoration(
              suffixIcon: GestureDetector(
                onTap: () {
                  sendMessage();
                  _messages
                      .add(MessageModel(false, txtMessage.text.toString()));
                  txtMessage.clear();
                },
                child: const Icon(
                  Icons.send,
                  color: Colors.blue,
                ),
              ),
              hintText: '...A',
              disabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(20)))),
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final int index;
  const UserCard({
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Align(
          alignment: Alignment.centerRight,
          child: Column(
            children: [
              CircleAvatar(
                child: Icon(
                  Icons.hail,
                  size: 30,
                ),
              ),
              Text('동규')
            ],
          ),
        ),
        Positioned(
          right: 50,
          bottom: 15,
          child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(.12),
                            offset: const Offset(-30, 2),
                            blurRadius: 2)
                      ]),
                  child: Text(
                    messages[index].message,
                    maxLines: 12,
                  ))
            ],
          ),
        )
      ],
    );
  }
}

class BotCard extends StatelessWidget {
  final int index;
  const BotCard({
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              child: Icon(
                Icons.person,
                size: 35,
              ),
            ),
            const Text('전자두뇌상혁'),
            SizedBox(
              width: 300,
              height: 500,
              child: Text(
                messages[index].message,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
