import 'package:cometchat/models/action.dart';
import 'package:cometchat/models/media_message.dart';
import 'package:cometchat/models/text_message.dart';
import 'package:cometchat/models/user.dart';

import 'app_entity.dart';

class BaseMessage {
  final int id;
  final String? muid;
  final User? sender;
  final AppEntity? receiver;
  final String receiverUid;
  final String type;
  final String receiverType;
  final String category;
  final DateTime sentAt;
  final DateTime deliveredAt;
  final DateTime readAt;
  final Map<String, dynamic> metadata;
  final DateTime readByMeAt;
  final DateTime deliveredToMeAt;
  final DateTime deletedAt;
  final DateTime editedAt;
  final String? deletedBy;
  final String? editedBy;
  final DateTime updatedAt;
  final String conversationId;
  final int parentMessageId;
  final int replyCount;

  BaseMessage({
    required this.id,
    required this.muid,
    required this.sender,
    this.receiver,
    required this.receiverUid,
    required this.type,
    required this.receiverType,
    required this.category,
    required this.sentAt,
    required this.deliveredAt,
    required this.readAt,
    required this.metadata,
    required this.readByMeAt,
    required this.deliveredToMeAt,
    required this.deletedAt,
    required this.editedAt,
    required this.deletedBy,
    required this.editedBy,
    required this.updatedAt,
    required this.conversationId,
    required this.parentMessageId,
    required this.replyCount,
  });

  factory BaseMessage.fromMap(dynamic map) {
    if (map == null) throw ArgumentError('The type of basemessage map is null');
    // final hashMap = Map.from(map);
    // hashMap.remove('receiver');
    // hashMap.remove('sender');
    // hashMap.remove('metadata');
    // print('Base Message: $hashMap');

    final String category = map['category'] ?? '';

    if (category.isEmpty) {
      throw Exception('Category is missing in JSON');
    }
    if (category == 'message') {
      if (map['type'] == 'text') {
        return TextMessage.fromMap(map);
      } else if (map['type'] == 'file' || map['type'] == 'image') {
        return MediaMessage.fromMap(map);
      } else {
        // Custom message
        throw UnimplementedError();
      }
    } else if (category == 'action') {
      return Action.fromMap(map);
    } else if (category == 'call') {
      throw UnimplementedError();
    } else {
      throw ArgumentError();
    }
  }
}
