import 'dart:async';

import 'package:cometchat/models/conversation.dart';
import 'package:cometchat/models/group.dart';
import 'package:cometchat/models/group_member.dart';
import 'package:flutter/services.dart';

import 'models/base_message.dart';
import 'models/media_message.dart';
import 'models/text_message.dart';
import 'models/user.dart';

class CometChat {
  final String appId;
  final String authKey;
  final String region;

  CometChat(
    this.appId,
    this.authKey, {
    this.region,
  });

  MethodChannel _channel = const MethodChannel('cometchat');
  EventChannel _messageStream = const EventChannel('cometchat_message_stream');
  // EventChannel _receiptStream = const EventChannel('cometchat_receipt_stream');
  // EventChannel _typingStream = const EventChannel('cometchat_typing_stream');

  Future<void> init() async {
    try {
      final arguments = {
        'appId': appId,
        'region': region,
      };
      arguments.removeWhere((key, value) => value == null || value.isEmpty);
      await _channel.invokeMethod('init', arguments);
    } catch (e) {
      throw e;
    }
  }

  Future<User> createUser(String uid, String name, String avatar) async {
    try {
      final result = await _channel.invokeMethod('createUser', {
        'apiKey': authKey, // TODO: Test key
        'uid': uid,
        'name': name,
        'avatar': avatar,
      });
      final user = User.fromMap(result);
      return user;
    } catch (e) {
      throw e;
    }
  }

  Future<User> loginWithApiKey(String uid) async {
    try {
      final result = await _channel.invokeMethod('loginWithApiKey', {
        'uid': uid,
        'apiKey': authKey,
      });
      final user = User.fromMap(result);
      return user;
    } catch (e) {
      throw e;
    }
  }

  Future<User> loginWithAuthToken(String authToken) async {
    try {
      final result = await _channel.invokeMethod('loginWithAuthToken', {
        'authToken': authToken,
      });
      final user = User.fromMap(result);
      return user;
    } catch (e) {
      throw e;
    }
  }

  Future<void> logout() async {
    try {
      await _channel.invokeMethod('logout');
    } catch (e) {
      throw e;
    }
  }

  Future<User> getLoggedInUser() async {
    try {
      final result = await _channel.invokeMethod('getLoggedInUser');
      final user = User.fromMap(result);
      return user;
    } catch (e) {
      throw e;
    }
  }

  Future<TextMessage> sendMessage(
      String messageText, String receiverId, String receiverType) async {
    try {
      final result = await _channel.invokeMethod('sendMessage', {
        'receiverId': receiverId,
        'receiverType': receiverType,
        'messageText': messageText,
      });
      final textMessage = TextMessage.fromMap(result);
      return textMessage;
    } catch (e) {
      throw e;
    }
  }

  Future<MediaMessage> sendMediaMessage(
    String filePath,
    String messageType,
    String receiverId,
    String receiverType, {
    String caption,
  }) async {
    final result = await _channel.invokeMethod('sendMediaMessage', {
      'receiverId': receiverId,
      'receiverType': receiverType,
      'filePath': filePath,
      'messageType': messageType,
      'caption': caption,
    });
    final mediaMessage = MediaMessage.fromMap(result);
    return mediaMessage;
  }

  // Future<CustomMessage> sendCustomMessage(
  //     CustomMessage message) async {
  //   final result = await _channel.invokeMethod('sendCustomMessage', {
  //     'receiverId': message.receiverId,
  //     'receiverType': message.receiverType,
  //     'customType': message.customType,
  //     'customData': message.customData,
  //   });
  //   final customMessage = CustomMessage.fromJson(result);
  //   return customMessage;
  // }

  Stream<BaseMessage> onMessageReceived() {
    return _messageStream.receiveBroadcastStream().map<BaseMessage>((e) {
      print(e);
      return BaseMessage.fromMap(e);
    });
  }

  Future<List<BaseMessage>> fetchPreviousMessages({
    String uid,
    String guid,
    String searchTerm,
    int afterMessageId,
    int limit,
  }) async {
    try {
      final result = await _channel.invokeMethod('fetchPreviousMessages', {
        'uid': uid,
        'guid': guid,
        'searchTerm': searchTerm,
        'messageId': afterMessageId,
        'limit': limit,
      });
      return result.map<BaseMessage>((e) => BaseMessage.fromMap(e)).toList();
    } catch (e) {
      throw e;
    }
  }

  Future<List<Conversation>> fetchNextConversations({
    String conversationType,
    int limit,
  }) async {
    try {
      final result = await _channel.invokeMethod('fetchNextConversations', {
        'limit': limit,
        'type': conversationType,
      });
      return result.map<Conversation>((e) => Conversation.fromMap(e)).toList();
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteMessage(int messageId) async {
    try {
      await _channel.invokeMethod('deleteMessage', {
        'messageId': messageId,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<Group> createGroup(
    String guid,
    String groupName,
    String groupType, {
    String password = '',
  }) async {
    try {
      final result = await _channel.invokeMethod('createGroup', {
        'guid': guid,
        'groupName': groupName,
        'groupType': groupType,
        'password': password,
      });
      return Group.fromMap(result);
    } catch (e) {
      throw e;
    }
  }

  Future<Group> joinGroup(
    String guid,
    String groupType, {
    String password = '',
  }) async {
    try {
      final result = await _channel.invokeMethod('joinGroup', {
        'guid': guid,
        'groupType': groupType,
        'password': password,
      });
      return Group.fromMap(result);
    } catch (e) {
      throw e;
    }
  }

  Future<void> leaveGroup(String guid) async {
    try {
      final result = await _channel.invokeMethod('leaveGroup', {
        'guid': guid,
      });
      return Group.fromMap(result);
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteGroup(String guid) async {
    try {
      final result = await _channel.invokeMethod('deleteGroup', {
        'guid': guid,
      });
      return Group.fromMap(result);
    } catch (e) {
      throw e;
    }
  }

  Future<List<Group>> fetchNextGroups({
    int limit,
    String searchTerm,
  }) async {
    try {
      final result = await _channel.invokeMethod('fetchNextGroups', {
        'searchTerm': searchTerm,
        'limit': limit,
      });
      return result.map<Group>((e) => Group.fromMap(e)).toList();
    } catch (e) {
      throw e;
    }
  }

  Future<List<GroupMember>> fetchNextGroupMembers(
    String guid, {
    int limit,
  }) async {
    try {
      final result = await _channel.invokeMethod('fetchNextGroupMembers', {
        'guid': guid,
        'limit': limit,
      });
      return result.map<GroupMember>((e) => GroupMember.fromMap(e)).toList();
    } catch (e) {
      throw e;
    }
  }

  Future<void> registerTokenForPushNotification(String token) async {
    try {
      await _channel.invokeMethod('registerTokenForPushNotification', {
        'token': token,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<Map<String, Map<String, int>>> getUnreadMessageCount() async {
    try {
      final count = await _channel.invokeMethod('getUnreadMessageCount');
      final countMap = Map<String, dynamic>.from(count);
      return countMap.map((k, v) => MapEntry(k, Map<String, int>.from(v)));
    } catch (e) {
      throw e;
    }
  }

  Future<void> markAsRead(
    int messageId,
    String senderId,
    String receiverType,
  ) async {
    try {
      await _channel.invokeMethod('markAsRead', {
        'messageId': messageId,
        'senderId': senderId,
        'receiverType': receiverType,
      });
    } catch (e) {
      throw e;
    }
  }
}
