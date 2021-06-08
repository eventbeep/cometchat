import 'dart:convert';

import 'app_entity.dart';
import 'attachment.dart';
import 'base_message.dart';
import 'group.dart';
import 'user.dart';

class MediaMessage extends BaseMessage {
  final String caption;
  final Attachment? attachment;

  MediaMessage({
    required this.caption,
    required this.attachment,
    required int id,
    required String? muid,
    required User? sender,
    AppEntity? receiver,
    required String receiverUid,
    required String type,
    required String receiverType,
    required String category,
    required DateTime sentAt,
    required DateTime deliveredAt,
    required DateTime readAt,
    required Map<String, dynamic> metadata,
    required DateTime readByMeAt,
    required DateTime deliveredToMeAt,
    required DateTime deletedAt,
    required DateTime editedAt,
    required String? deletedBy,
    required String? editedBy,
    required DateTime updatedAt,
    required String conversationId,
    required int parentMessageId,
    required int replyCount,
  }) : super(
          id: id,
          muid: muid,
          sender: sender,
          receiver: receiver,
          receiverUid: receiverUid,
          type: type,
          receiverType: receiverType,
          category: category,
          sentAt: sentAt,
          deliveredAt: deliveredAt,
          readAt: readAt,
          metadata: metadata,
          readByMeAt: readByMeAt,
          deliveredToMeAt: deliveredToMeAt,
          deletedAt: deletedAt,
          editedAt: editedAt,
          deletedBy: deletedBy,
          editedBy: editedBy,
          updatedAt: updatedAt,
          conversationId: conversationId,
          parentMessageId: parentMessageId,
          replyCount: replyCount,
        );

  factory MediaMessage.fromMap(dynamic map) {
    if (map == null)
      throw ArgumentError('The type of mediamessage map is null');

    final appEntity = (map['receiver'] == null)
        ? null
        : (map['receiverType'] == 'user')
            ? User.fromMap(map['receiver'])
            : Group.fromMap(map['receiver']);

    return MediaMessage(
      caption: map['caption'] ?? '',
      attachment: map['attachment'] == null
          ? null
          : Attachment.fromMap(map['attachment']),
      id: map['id'],
      muid: map['muid'],
      sender: map['sender'] == null ? null : User.fromMap(map['sender']),
      receiver: appEntity,
      receiverUid: map['receiverUid'],
      type: map['type'],
      receiverType: map['receiverType'],
      category: map['category'],
      sentAt: DateTime.fromMillisecondsSinceEpoch(map['sentAt'] * 1000),
      deliveredAt:
          DateTime.fromMillisecondsSinceEpoch(map['deliveredAt'] * 1000),
      readAt: DateTime.fromMillisecondsSinceEpoch(map['readAt'] * 1000),
      metadata: Map<String, dynamic>.from(json.decode(map['metadata'] ?? '{}')),
      readByMeAt: DateTime.fromMillisecondsSinceEpoch(map['readByMeAt'] * 1000),
      deliveredToMeAt:
          DateTime.fromMillisecondsSinceEpoch(map['deliveredToMeAt'] * 1000),
      deletedAt: DateTime.fromMillisecondsSinceEpoch(map['deletedAt'] * 1000),
      editedAt: DateTime.fromMillisecondsSinceEpoch(map['editedAt'] * 1000),
      deletedBy: map['deletedBy'],
      editedBy: map['editedBy'],
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] * 1000),
      conversationId: map['conversationId'],
      parentMessageId: map['parentMessageId'],
      replyCount: map['replyCount'],
    );
  }
}
