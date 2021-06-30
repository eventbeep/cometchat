import 'dart:convert';

import 'app_entity.dart';

class User extends AppEntity {
  final String? uid;
  final String? name;
  final String? avatar;
  final String? link;
  final String? role;
  final String? status;
  final String? statusMessage;
  final DateTime? lastActiveAt;
  final List<String>? tags;
  final bool? hasBlockedMe;
  final bool? blockedByMe;
  final Map<String, dynamic>? metadata;

  User({
    required this.uid,
    required this.name,
    required this.avatar,
    this.link = '',
    this.role = 'default',
    this.status = 'offline',
    this.statusMessage = '',
    required this.lastActiveAt,
    this.tags = const [],
    this.metadata = const {},
    this.hasBlockedMe = false,
    this.blockedByMe = false,
  });

  factory User.fromMap(dynamic map) {
    if (map == null) throw ArgumentError('The type of user map is null');

    // Logger().d('User: $map');
    return User(
      uid: map['uid'],
      name: map['name'] ?? '',
      avatar: map['avatar'] ?? '',
      link: map['link'] ?? '',
      role: map['role'] ?? 'default',
      status: map['status'] ?? 'offline',
      statusMessage: map['statusMessage'] ?? '',
      lastActiveAt: DateTime.fromMillisecondsSinceEpoch(
          map['lastActiveAt'].toInt() * 1000),
      tags: List<String>.from(map['tags'] ?? []),
      hasBlockedMe: map['hasBlockedMe'] ?? false,
      blockedByMe: map['blockedByMe'] ?? false,
      metadata: Map<String, dynamic>.from(json.decode(map['metadata'] ?? '{}')),
    );
  }
}
