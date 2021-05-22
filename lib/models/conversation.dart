import 'app_entity.dart';
import 'base_message.dart';
import 'group.dart';
import 'user.dart';

class Conversation {
  final String conversationId;
  final String conversationType;
  final AppEntity conversationWith;
  final BaseMessage? lastMessage;
  final DateTime updatedAt;
  final int unreadMessageCount;

  Conversation({
    required this.conversationId,
    required this.conversationType,
    required this.conversationWith,
    this.lastMessage,
    required this.updatedAt,
    required this.unreadMessageCount,
  });

  factory Conversation.fromMap(dynamic map) {
    if (map == null)
      throw ArgumentError('The type of conversation map is null');

    // Logger().d(map);

    final appEntity = (map['conversationType'] == 'user')
        ? User.fromMap(map['conversationWith'])
        : Group.fromMap(map['conversationWith']);

    return Conversation(
      conversationId: map['conversationId'],
      conversationType: map['conversationType'],
      conversationWith: appEntity,
      lastMessage: map['lastMessage'] == null
          ? null
          : BaseMessage.fromMap(map['lastMessage']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] * 1000),
      unreadMessageCount: map['unreadMessageCount'],
    );
  }
}
