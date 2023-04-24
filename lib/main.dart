import 'dart:collection';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_chatbotgpt/models/message_model.dart';

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
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 100)),
      isLog: true);

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
          title: const Text('영화예매 ChatGPT'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(children: [
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
                const SizedBox(
                  height: 45,
                )
              ],
            ),
            SendMessage(
              sendMessage: () => sendMessage(txtMessage.text),
            )
          ]),
        ),
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

//유저 카드 위젯
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
              Text('구굴러')
            ],
          ),
        ),
        Positioned(
          right: 50,
          bottom: 15,
          child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(.12),
                            offset: const Offset(-1, 1),
                            blurRadius: 2)
                      ]),
                  child: Text(
                    messages[index].message,
                    softWrap: true,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ))
            ],
          ),
        )
      ],
    );
  }
}

//챗봇 카드 위젯
class BotCard extends StatelessWidget {
  final int index;
  const BotCard({
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              child: Icon(
                Icons.person,
                size: 35,
                color: Colors.cyan,
              ),
            ),
            Text('챗 봇'),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          width: 300,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    offset: const Offset(2, 2))
              ]),
          child: Transform.translate(
            offset: const Offset(0, -15),
            child: Text(
              messages[index].message,
              softWrap: true,
            ),
          ),
        ),
      ],
    );
  }
}
