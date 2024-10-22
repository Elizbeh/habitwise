import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/models/member.dart';


class HabitWiseGroup {
  final String groupId;
  final String groupName;
  final List<Member> members;
  final List<String> habits;
  final String groupType;
  final String? groupPictureUrl;
  final DateTime creationDate;
  final String description;
  final String groupCode;
  int completedGoals;
  List<String> completedGoalIds;
  List<Goal> goals;
  final Map<String, String> groupRoles;
  

  HabitWiseGroup({
    required this.groupId,
    required this.groupName,
    required this.members,
    required this.habits,
    required this.groupType,
    this.groupPictureUrl,
    required this.creationDate,
    required this.description,
    required this.groupCode,
    this.completedGoals = 0,
    this.completedGoalIds = const [],
    this.goals = const [],
    required this.groupRoles,
  });

  factory HabitWiseGroup.fromMap(Map<String, dynamic> map) {
    return HabitWiseGroup(
      groupId: map['groupId'] as String,
      groupName: map['groupName'] as String,
      members: List<Member>.from(map['members']?.map((m) => Member.fromMap(m)) ?? []),
      habits: List<String>.from(map['habits'] ?? []),
      groupType: map['groupType'] as String,
      groupPictureUrl: map['groupPictureUrl'] as String?,
      creationDate: (map['creationDate'] as Timestamp).toDate(),
      description: map['description'] as String,
      groupCode: map['groupCode'] as String,
      completedGoals: map['completedGoals'] ?? 0,
      completedGoalIds: List<String>.from(map['completedGoalIds'] ?? []),
      goals: List<Goal>.from(map['goals']?.map((g) => Goal.fromMap(g)) ?? []),
      groupRoles: Map<String, String>.from(map['groupRoles'] ?? {}).map(
        (key, value) => MapEntry(key, value), // Ensure this is a string
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'members': members.map((member) => member.toMap()).toList(),
      'habits': habits,
      'groupType': groupType,
      'groupPictureUrl': groupPictureUrl,
      'creationDate': Timestamp.fromDate(creationDate),
      'description': description,
      'groupCode': groupCode,
      'completedGoals': completedGoals,
      'completedGoalIds': completedGoalIds,
      'goals': goals.map((goal) => goal.toMap()).toList(),
      'groupRoles': groupRoles,
    };
  }

  HabitWiseGroup copyWith({
    String? groupId,
    String? groupName,
    DateTime? creationDate,
    String? description,
    List<Member>? members,
    List<String>? habits,
    String? groupType,
    String? groupPictureUrl,
    String? groupCode,
    int? completedGoals,
    List<String>? completedGoalsCount,
    List<Goal>? goals,
    Map<String, String>? groupRoles
  }) {
    return HabitWiseGroup(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      members: members ?? this.members,
      habits: habits ?? this.habits,
      groupType: groupType ?? this.groupType,
      groupPictureUrl: groupPictureUrl ?? this.groupPictureUrl,
      creationDate: creationDate ?? this.creationDate,
      description: description ?? this.description,
      groupCode: groupCode ?? this.groupCode,
      completedGoals: completedGoals ?? this.completedGoals,
      completedGoalIds: completedGoalsCount ?? this.completedGoalIds,
      goals: goals ?? this.goals,
      groupRoles: groupRoles ?? this.groupRoles
    );
  }


  // Optional: You can add methods for managing completed goals
  void incrementCompletedGoals() {
    completedGoals +=1;
  }

  void addCompletedGoal(String goalId) {
    completedGoalIds.add(goalId);
  }



  //  a method to get the role of a user in the group
  String getUserRole(String userId, Map<String, String> groupRoles) {
    return groupRoles[userId] ?? 'member'; // Default role is 'member'
  }
}
