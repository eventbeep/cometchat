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
      '299805850545775',
      authKey: 'af235bbb3e1c01836a30bd8411956a1bd83b22cd',
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
            final list = snapshot.data ?? [];
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                if (list[index].conversationWith is User) {
                  final e = list[index].conversationWith as User;
                  return ListTile(
                    title: Text(e.name),
                    onLongPress: () => cometChat.blockUser([e.uid]),
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
    print('Logged in ${user?.name}');
    if (user == null) {
      await cometChat.loginWithApiKey('gesrpaizituc5c7atmgjrja0xns2');
    }
    print('Logged in ');
    // await cometChat.sendMessage(
    //   'Hello super heroes',
    //   'vji5bpo3avz935floys1ef7dnia3',
    //   CometReceiverType.user,
    // );
    return cometChat.fetchNextConversations();
    // return [];
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
    // final l = widget.conversation.conversationType == CometReceiverType.user
    //     ? await widget.cometChat.fetchPreviousMessages(
    //         uid: (widget.conversation.conversationWith as User).uid)
    //     : await widget.cometChat.fetchPreviousMessages(
    //         guid: (widget.conversation.conversationWith as Group).guid);
    setState(() {
      list = List.from([]);
    });
  }
}
