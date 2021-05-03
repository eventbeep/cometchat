import 'package:cometchat/models/app_entity.dart';
import 'package:cometchat/models/base_message.dart';
import 'package:cometchat/models/group.dart';
import 'package:cometchat/models/user.dart';

class Conversation {
  final String conversationId;
  final String conversationType;
  final AppEntity conversationWith;
  final BaseMessage lastMessage;
  final DateTime updatedAt;
  final int unreadMessageCount;

  Conversation({
    this.conversationId,
    this.conversationType,
    this.conversationWith,
    this.lastMessage,
    this.updatedAt,
    this.unreadMessageCount,
  });

  factory Conversation.fromMap(dynamic map) {
    if (map == null) return null;

    final appEntity = (map['conversationType'] == 'user')
        ? User.fromMap(map['conversationWith'])
        : Group.fromMap(map['conversationWith']);

    return Conversation(
      conversationId: map['conversationId'],
      conversationType: map['conversationType'],
      conversationWith: appEntity,
      lastMessage: BaseMessage.fromMap(map['lastMessage']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] * 1000),
      unreadMessageCount: map['unreadMessageCount'],
    );
  }
}
