import 'dart:convert';

import 'user.dart';

class GroupMember extends User {
  final String scope;
  final DateTime joinedAt;

  GroupMember({
    required this.scope,
    required this.joinedAt,
    required String uid,
    required String name,
    required String avatar,
    required String link,
    required String role,
    required String status,
    required String statusMessage,
    required DateTime lastActiveAt,
    required List<String> tags,
    required Map<String, dynamic> metadata,
    required bool hasBlockedMe,
    required bool blockedByMe,
  }) : super(
          uid: uid,
          name: name,
          avatar: avatar,
          link: link,
          role: role,
          status: status,
          statusMessage: statusMessage,
          lastActiveAt: lastActiveAt,
          tags: tags,
          metadata: metadata,
          hasBlockedMe: hasBlockedMe,
          blockedByMe: blockedByMe,
        );

  factory GroupMember.fromMap(dynamic map) {
    if (map == null) throw ArgumentError('The type of map is null');

    return GroupMember(
      scope: map['scope'] ?? '',
      joinedAt: DateTime.fromMillisecondsSinceEpoch(map['joinedAt'] * 1000),
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
