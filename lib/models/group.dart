import 'package:cloud_firestore/cloud_firestore.dart';

class HabitWiseGroup {
  final String groupId;
  final String groupName;
  final List<String> members;
  final List<String> goals;
  final List<String> habits;
  final String groupType;
  final String? groupPictureUrl;
  final String groupCreator;
  final DateTime creationDate;
  final String description;

  HabitWiseGroup({
    required this.groupId,
    required this.groupName,
    required this.members,
    required this.goals,
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
      members: List<String>.from(map['members'] ?? []),
      goals: List<String>.from(map['goals'] ?? []),
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
      'members': members,
      'goals': goals,
      'habits': habits,
      'groupType': groupType,
      'groupPictureUrl': groupPictureUrl,
      'groupCreator': groupCreator,
      'creationDate': creationDate,
      'description': description,
    };
  }

  HabitWiseGroup copyWith({
    String? groupId,
    String? groupName,
    String? groupCreator,
    DateTime? creationDate,
    String? description,
    List<String>? members,
    List<String>? goals,
    List<String>? habits,
    String? groupType,
    String? groupPictureUrl,
  }) {
    return HabitWiseGroup(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      members: members ?? this.members,
      goals: goals ?? this.goals,
      habits: habits ?? this.habits,
      groupType: groupType ?? this.groupType,
      groupPictureUrl: groupPictureUrl ?? this.groupPictureUrl,
      groupCreator: groupCreator ?? this.groupCreator, 
      creationDate: creationDate ?? this.creationDate, 
      description: description ?? this.description,
    );
  }
}
