import 'dart:convert';

import 'app_entity.dart';

class User extends AppEntity {
  final String uid;
  final String name;
  final String avatar;
  final String link;
  final String role;
  final String status;
  final String statusMessage;
  final DateTime lastActiveAt;
  final List<String> tags;
  final bool hasBlockedMe;
  final bool blockedByMe;
  final Map<String, dynamic> metadata;

  User({
    this.uid,
    this.name,
    this.avatar,
    this.link,
    this.role,
    this.status,
    this.statusMessage,
    this.lastActiveAt,
    this.tags,
    this.metadata,
    this.hasBlockedMe,
    this.blockedByMe,
  });

  factory User.fromMap(dynamic map) {
    if (map == null) return null;

    return User(
      uid: map['uid'],
      name: map['name'],
      avatar: map['avatar'],
      link: map['link'],
      role: map['role'],
      status: map['status'],
      statusMessage: map['statusMessage'],
      lastActiveAt:
          DateTime.fromMillisecondsSinceEpoch(map['lastActiveAt'] * 1000),
      tags: List<String>.from(map['tags'] ?? []),
      hasBlockedMe: map['hasBlockedMe'],
      blockedByMe: map['blockedByMe'],
      metadata: Map<String, dynamic>.from(json.decode(map['metadata'] ?? '{}')),
    );
  }
}
