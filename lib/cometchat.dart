import 'dart:async';
import 'dart:convert';

import 'package:cometchat/models/app_entity.dart';
import 'package:cometchat/models/conversation.dart';
import 'package:cometchat/models/group.dart';
import 'package:cometchat/models/group_member.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import 'models/base_message.dart';
import 'models/media_message.dart';
import 'models/text_message.dart';
import 'models/user.dart';

class CometChat {
  final String appId;

  /// Use this only for testing purpose
  final String? authKey;
  final String region;

  CometChat(
    this.appId, {
    @deprecated this.authKey,
    this.region = 'us',
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
      arguments.removeWhere((key, value) => value.isEmpty);
      await _channel.invokeMethod('init', arguments);
    } catch (e) {
      throw e;
    }
  }

  Future<User> createUser(String uid, String name, String avatar) async {
    try {
      final result = await _channel.invokeMethod('createUser', {
        'apiKey': authKey,
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

  /// Use this function only for testing purpose. For production, use [loginWithAuthToken]
  @deprecated
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

  Future<User?> getUser(String uid) async {
    try {
      final result = await _channel.invokeMethod('getUser', {'uid': uid});

      final user = User.fromMap(result);
      return user;
    } catch (e) {
      throw e;
    }
  }

  Future<User?> getLoggedInUser() async {
    try {
      final result = await _channel.invokeMethod('getLoggedInUser');
      if (result == null) return null;
      final user = User.fromMap(result);
      return user;
    } catch (e) {
      throw e;
    }
  }

  Future<TextMessage> sendMessage(
    String messageText,
    AppEntity receiver,
    String receiverType, {
    int? parentMessageId,
  }) async {
    try {
      final result = await _channel.invokeMethod('sendMessage', {
        'receiverId': (receiverType == 'user')
            ? (receiver as User).uid
            : (receiver as Group).guid,
        'receiverType': receiverType,
        'messageText': messageText,
        'parentMessageId': parentMessageId,
      });

      final textMessage = TextMessage.fromMap(result, receiver: receiver);
      return textMessage;
    } catch (e) {
      Logger().e(e);
      throw e;
    }
  }

  Future<MediaMessage> sendMediaMessage(
    String filePath,
    String messageType,
    AppEntity receiver,
    String receiverType, {
    String? caption,
    int? parentMessageId,
  }) async {
    try {
      Logger().d(filePath);
      final result = await _channel.invokeMethod('sendMediaMessage', {
        'receiverId': (receiverType == 'user')
            ? (receiver as User).uid
            : (receiver as Group).guid,
        'receiverType': receiverType,
        'filePath': filePath,
        'messageType': messageType,
        'caption': caption,
        'parentMessageId': parentMessageId,
      });
      Logger().d(result);
      final mediaMessage = MediaMessage.fromMap(result, receiver: receiver);
      return mediaMessage;
    } catch (e) {
      Logger().e(e);
      throw e;
    }
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
    return _messageStream
        .receiveBroadcastStream()
        .map<BaseMessage>((e) => BaseMessage.fromMap(e));
  }

  Future<List<BaseMessage>?> fetchPreviousMessages({
    String? uid,
    String? guid,
    String? searchTerm,
    int? afterMessageId,
    int? limit,
  }) async {
    try {
      final result = await _channel.invokeMethod('fetchPreviousMessages', {
        'uid': uid,
        'guid': guid,
        'searchTerm': searchTerm,
        'messageId': afterMessageId,
        'limit': limit,
      }) as List;
      final List<BaseMessage?> list = result
          .map<BaseMessage?>((e) => e == null ? null : BaseMessage.fromMap(e))
          .where((e) => e != null)
          .toList();

      return list.map<BaseMessage>((e) => e!).toList();
    } catch (e) {
      throw e;
    }
  }

  Future<List<Conversation>> fetchNextConversations({
    String? conversationType,
    int? limit,
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

  Future<Conversation> getConversation(
    String conversationWith,
    String conversationType,
  ) async {
    try {
      final result = await _channel.invokeMethod('getConversation', {
        'conversationWith': conversationWith,
        'conversationType': conversationType,
      });
      return Conversation.fromMap(result);
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
      await _channel.invokeMethod('leaveGroup', {
        'guid': guid,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteGroup(String guid) async {
    try {
      await _channel.invokeMethod('deleteGroup', {
        'guid': guid,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<List<Group>?> fetchNextGroups({
    int? limit,
    String? searchTerm,
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

  Future<List<GroupMember>> fetchNextGroupMembers(String guid,
      {int? limit, String? keyword}) async {
    print("$guid,$keyword ");
    try {
      final result = await _channel.invokeMethod('fetchNextGroupMembers',
          {'guid': guid, 'limit': limit, 'keyword': keyword});
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
      final result =
          countMap.map((k, v) => MapEntry(k, Map<String, int>.from(v)));
      if (!result.containsKey('group')) result['group'] = {};
      if (!result.containsKey('user')) result['user'] = {};
      return result;
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

  Future<Map<String, dynamic>> callExtension(
    String slug,
    String requestType,
    String endPoint,
    Map<String, dynamic>? body,
  ) async {
    try {
      final result = await _channel.invokeMethod('callExtension', {
        'slug': slug,
        'requestType': requestType,
        'endPoint': endPoint,
        'body': body,
      });
      final map = json.decode(result);
      return Map<String, dynamic>.from(map);
    } catch (e) {
      throw e;
    }
  }

  Future<Map<String, dynamic>> blockUser(List<String>? uids) async {
    try {
      final result = await _channel.invokeMethod('blockUsers', {'uids': uids});
      return Map<String, dynamic>.from(result);
    } catch (e) {
      throw e;
    }
  }

  Future<Map<String, dynamic>> unblockUser(List<String>? uids) async {
    try {
      final result =
          await _channel.invokeMethod('unblockUsers', {'uids': uids});
      return Map<String, dynamic>.from(result);
    } catch (e) {
      throw e;
    }
  }

  Future<List<User>?> fetchBlockedUsers() async {
    try {
      final result = await _channel.invokeMethod('fetchBlockedUsers');
      print(result);
      return result.map<User>((e) => User.fromMap(e)).toList();
    } catch (e) {
      throw e;
    }
  }
}
