import 'package:cometchat/cometchat.dart';
import 'package:cometchat/models/base_message.dart';
import 'package:cometchat/models/conversation.dart';
import 'package:cometchat/models/group.dart';
import 'package:cometchat/models/group_member.dart';
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
          actions: [
            Builder(
              builder: (context) => IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlockedUsers(
                            cometChat: cometChat,
                          ),
                        ));
                  },
                  icon: Icon(Icons.block)),
            ),
            // PopupMenuButton(
            //   onSelected: (value) {
            //     switch (value) {
            //       case 0:
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => BlockedUsers(),
            //           ),
            //         );

            //         break;
            //       default:
            //         Navigator.pop(context);
            //     }
            //   },
            //   itemBuilder: (context) => [
            //     PopupMenuItem(
            //       child: Text("Blocked Users"),
            //       value: 0,
            //     )
            //   ],
            // )
          ],
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
                    onLongPress: () async {
                await cometChat.blockUser([e.uid]);
                      User user = await cometChat.getUser(e.uid);
                      print("from get user ${user.name}");
                      print(e.name);
                    },
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
      body: SafeArea(
        child: Column(
          children: [
            if (widget.conversation.conversationType == "group")
              TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MembersPage(
                                cometChat: widget.cometChat,
                                conversation: widget.conversation,
                              ))),
                  child: Text("Get members by search")),
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
      list = List.from([]);
    });
  }
}

class MembersPage extends StatefulWidget {
  const MembersPage({Key key, this.conversation, this.cometChat})
      : super(key: key);

  final Conversation conversation;
  final CometChat cometChat;

  @override
  _MembersPageState createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  List<GroupMember> result = [];
  getMembers(String keyword) async {
    result = await widget.cometChat.fetchNextGroupMembers(
        (widget.conversation.conversationWith as Group).guid,
        keyword: keyword ?? "");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          color: Colors.white,
          child: TextField(
            onChanged: (val) async {
              await getMembers(val);
            },
          ),
        ),
      ),
      body: ListView.builder(
          itemCount: result.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.all(8),
              child: Text(result[index].name),
            );
          }),
    );
  }
}

class BlockedUsers extends StatefulWidget {
  const BlockedUsers({Key key, this.cometChat}) : super(key: key);
  final CometChat cometChat;

  @override
  _BlockedUsersState createState() => _BlockedUsersState();
}

class _BlockedUsersState extends State<BlockedUsers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<User>>(
        future: _fetchBlockedUsers(),
        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Center(child: CircularProgressIndicator());
          // }
          print(snapshot.data);
          final list = snapshot.data ?? [];
          return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final e = list[index];
                return ListTile(
                  title: Text(e.name),
                  onLongPress: () => widget.cometChat.unblockUser([e.uid]),
                );
              });
        },
      ),
    );
  }

  Future<List<User>> _fetchBlockedUsers() async {
    final cometChat = widget.cometChat;
    final blocked = await cometChat.fetchBlockedUsers();
    print(blocked);
    return blocked;
  }
}
