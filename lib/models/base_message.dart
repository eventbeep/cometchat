import 'package:cometchat/models/action.dart';
import 'package:cometchat/models/media_message.dart';
import 'package:cometchat/models/text_message.dart';
import 'package:cometchat/models/user.dart';

import 'app_entity.dart';

class BaseMessage {
  final int id;
  final String muid;
  final User sender;
  final AppEntity receiver;
  final String receiverUid;
  final String type;
  final String receiverType;
  final String category;
  final DateTime sentAt;
  final DateTime deliveredAt;
  final DateTime readAt;
  Map<String, dynamic> metadata;
  final DateTime readByMeAt;
  final DateTime deliveredToMeAt;
  final DateTime deletedAt;
  final DateTime editedAt;
  final String deletedBy;
  final String editedBy;
  final DateTime updatedAt;
  final String conversationId;
  final int parentMessageId;
  final int replyCount;

  BaseMessage({
    this.id,
    this.muid,
    this.sender,
    this.receiver,
    this.receiverUid,
    this.type,
    this.receiverType,
    this.category,
    this.sentAt,
    this.deliveredAt,
    this.readAt,
    this.metadata,
    this.readByMeAt,
    this.deliveredToMeAt,
    this.deletedAt,
    this.editedAt,
    this.deletedBy,
    this.editedBy,
    this.updatedAt,
    this.conversationId,
    this.parentMessageId,
    this.replyCount,
  });

  // set metadata(Map<String, dynamic> data) {
  //   return this.metadata = data;
  // }

  factory BaseMessage.fromMap(dynamic map) {
    if (map == null) return null;

    print('Metadata: ${map['metadata']}');

    final String category = map['category'];
    print('Message category : $category');
    if (category == null || category.isEmpty) {
      throw Exception('Category is missing in JSON');
    }
    if (category == 'message') {
      print('Message type: ${map['type']}');
      if (map['type'] == 'text') {
        return TextMessage.fromMap(map);
      } else if (map['type'] == 'media') {
        return MediaMessage.fromMap(map);
      } else {
        // Custom message
        throw UnimplementedError();
      }
    } else if (category == 'action') {
      return Action.fromMap(map);
    } else if (category == 'call') {
      return null;
    } else {
      return null;
    }
  }
}
