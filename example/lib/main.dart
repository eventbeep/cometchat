import 'package:cometchat/cometchat.dart';
import 'package:cometchat/models/base_message.dart';
import 'package:cometchat/models/conversation.dart';
import 'package:cometchat/models/group.dart';
import 'package:cometchat/models/text_message.dart';
import 'package:cometchat/models/action.dart' as c;
import 'package:cometchat/models/user.dart';
import 'package:cometchat/utils/constants.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CometChat cometChat;

  @override
  void initState() {
    super.initState();
    cometChat = CometChat(
      '',
      authKey: '',
      region: 'eu',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: FutureBuilder<List<Conversation>>(
          future: _initAndGetConvos(),
          builder: (BuildContext context,
              AsyncSnapshot<List<Conversation>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            final list = snapshot.data;
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                if (list[index].conversationWith is User) {
                  final e = list[index].conversationWith as User;
                  return ListTile(
                    title: Text(e.name),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          cometChat: cometChat,
                          conversation: list[index],
                        ),
                      ),
                    ),
                  );
                } else {
                  final e = list[index].conversationWith as Group;
                  return ListTile(
                    title: Text(e.name),
                    trailing: Text(e.owner),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          cometChat: cometChat,
                          conversation: list[index],
                        ),
                      ),
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  Future<List<Conversation>> _initAndGetConvos() async {
    await cometChat.init();
    final user = await cometChat.getLoggedInUser();
    if (user == null) {
      await cometChat.loginWithApiKey('superhero2');
    }
    // await cometChat.sendMessage(TextMessage(
    //     'supergroup', CometReceiverType.group, 'Hello super heroes'));
    return cometChat.fetchNextConversations();
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({Key key, this.conversation, this.cometChat})
      : super(key: key);

  final Conversation conversation;
  final CometChat cometChat;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String messageText;
  List<BaseMessage> list;

  @override
  void initState() {
    super.initState();
    list = [];
    // widget.cometChat.onMessageReceived().listen((e) {
    //   list.add(e);
    //   setState(() {});
    // });
    initStuff();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, index) {
                var text;
                if (list[index] is TextMessage) {
                  text = (list[index] as TextMessage).text;
                } else if (list[index] is c.Action) {
                  text = (list[index] as c.Action).message;
                }
                return ListTile(
                  title: Text(text ?? 'Empty'),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (text) => setState(() => messageText = text),
                ),
              ),
              FloatingActionButton(
                child: Icon(Icons.send),
                onPressed: () => widget.cometChat.sendMessage(
                  messageText,
                  (widget.conversation.conversationWith as User).uid,
                  CometReceiverType.user,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> initStuff() async {
    final l = widget.conversation.conversationType == CometReceiverType.user
        ? await widget.cometChat.fetchPreviousMessages(
            uid: (widget.conversation.conversationWith as User).uid)
        : await widget.cometChat.fetchPreviousMessages(
            guid: (widget.conversation.conversationWith as Group).guid);
    setState(() {
      list = List.from(l);
    });
  }
}
