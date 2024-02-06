import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'chatBubbel.dart';
import 'main.dart';
import 'models/ModelProvider.dart';

const List<String> chats = ["Hey there!!", "Hello"];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<Message> data;
  String? _currentUser = "Me";
  List<Chats>? _messages = [];

  final messageInputController = TextEditingController();

  void _getCurretUserFromParent() async {
    _currentUser = await getCurrentUser();
  }

  List<Chats> _sortMessages(List<Chats> messageList) {
    messageList.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    return messageList;
  }

  void _refreshMessagesFromParent() async {
    List<Chats> tempList = await refreshMessages();
    _messages = _sortMessages(tempList);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    data = MessageGenerator.generate(60, 1337);
    _getCurretUserFromParent();
    _refreshMessagesFromParent();
  }

  @override
  void dispose() {
    messageInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppBar(
            elevation: 10,
            backgroundColor: Colors.black87,
            title: Center(
              child: Text(
                "Chat Screen",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 87,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                reverse: true,
                itemCount: _messages!.length,
                itemBuilder: (context, index) {
                  final Chats message = _messages![index];
                  return MessageBubble(
                    owner: message.name! == _currentUser
                        ? MessageOwner.myself
                        : MessageOwner.other,
                    sender: message.name!,
                    message: message.message!,
                  );
                },
              ),
            ),
            Expanded(
              flex: 13,
              child: Row(
                children: [
                  Expanded(
                    flex: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        style: TextStyle(fontSize: 18),
                        // keyboardType: TextInputType.multiline,
                        // maxLines: null,
                        controller: messageInputController,
                        decoration: InputDecoration(
                          hintText: 'Type here ....',
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () async {
                          await sendMessage(
                            name: _currentUser!,
                            message: messageInputController.text,
                          );
                          messageInputController.clear();
                          _refreshMessagesFromParent();
                        },
                        child: Icon(
                          Icons.send,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
