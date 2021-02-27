import 'dart:convert';

import 'app_entity.dart';

class Group extends AppEntity {
  final String guid;
  final String owner;
  final String name;
  final String icon;
  final String description;
  final Map<String, dynamic> metadata;
  final bool hasJoined;
  final int membersCount;
  final DateTime createdAt;
  final DateTime joinedAt;
  final DateTime updatedAt;
  final List<String> tags;

  Group({
    this.guid,
    this.owner,
    this.name,
    this.icon,
    this.description,
    this.metadata,
    this.hasJoined,
    this.membersCount,
    this.createdAt,
    this.joinedAt,
    this.updatedAt,
    this.tags,
  });

  factory Group.fromMap(dynamic map) {
    if (map == null) return null;

    return Group(
      guid: map['guid'],
      owner: map['owner'],
      name: map['name'],
      icon: map['icon'],
      description: map['description'],
      metadata: Map<String, dynamic>.from(json.decode(map['metadata'] ?? '{}')),
      hasJoined: map['hasJoined'],
      membersCount: map['membersCount'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] * 1000),
      joinedAt: DateTime.fromMillisecondsSinceEpoch(map['joinedAt'] * 1000),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] * 1000),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}
