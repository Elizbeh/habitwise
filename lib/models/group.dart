import 'package:cloud_firestore/cloud_firestore.dart';


class HabitWiseGroup {
  final String groupId;
  final String groupName;
  final List<String> members;
  final List<String> goals;
  final List<String> habits;
  final String groupType;
  final String? groupPictureUrl;

  HabitWiseGroup({
    required this.groupId,
    required this.groupName,
    required this.members,
    required this.goals,
    required this.habits,
    required this.groupType,
    this.groupPictureUrl,
  });

  factory HabitWiseGroup.fromMap(Map<String, dynamic> data) {
    return HabitWiseGroup(
      groupId:  data['groudId'],
      groupName:  data['groupName'],
      members: List<String>.from(data['members']),
      goals: List<String>.from(data['goals']),
      habits: List<String>.from(data['habits']),
      groupType: data['groupType'],
      groupPictureUrl: data['groupPictureUrl'],
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
    };
  }
}