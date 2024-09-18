import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/member.dart';

class HabitWiseGroup {
  final String groupId;
  final String groupName;
  final List<Member> members;
  final List<String> habits;  // Keep this if you're still using it for habits
  final String groupType;
  final String? groupPictureUrl;
  final String groupCreator;
  final DateTime creationDate;
  final String description;

  HabitWiseGroup({
    required this.groupId,
    required this.groupName,
    required this.members,
    required this.habits,
    required this.groupType,
    this.groupPictureUrl,
    required this.groupCreator,
    required this.creationDate,
    required this.description,
  });

  factory HabitWiseGroup.fromMap(Map<String, dynamic> map) {
    return HabitWiseGroup(
      groupId: map['groupId'] as String,
      groupName: map['groupName'] as String,
      members: List<Member>.from(map['members']?.map((m) => Member.fromMap(m)) ?? []),
      habits: List<String>.from(map['habits'] ?? []),
      groupType: map['groupType'] as String,
      groupPictureUrl: map['groupPictureUrl'] as String?,
      groupCreator: map['groupCreator'] as String,
      creationDate: (map['creationDate'] as Timestamp).toDate(),
      description: map['description'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'members': members.map((member) => member.toMap()).toList(), // Convert each Member to a map
      'habits': habits,
      'groupType': groupType,
      'groupPictureUrl': groupPictureUrl,
      'groupCreator': groupCreator,
      'creationDate': Timestamp.fromDate(creationDate),
      'description': description,
    };
  }

  HabitWiseGroup copyWith({
    String? groupId,
    String? groupName,
    String? groupCreator,
    DateTime? creationDate,
    String? description,
    List<Member>? members,
    List<String>? habits,
    String? groupType,
    String? groupPictureUrl,
  }) {
    return HabitWiseGroup(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      members: members ?? this.members,
      habits: habits ?? this.habits,
      groupType: groupType ?? this.groupType,
      groupPictureUrl: groupPictureUrl ?? this.groupPictureUrl,
      groupCreator: groupCreator ?? this.groupCreator, 
      creationDate: creationDate ?? this.creationDate, 
      description: description ?? this.description,
    );
  }
}
