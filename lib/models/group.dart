import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/models/member.dart';

class HabitWiseGroup {
  final String groupId;
  final String groupName;
  final List<Member> members;
  final List<String> memberIds; // New field for member IDs
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
  final String creatorId;

  HabitWiseGroup({
    required this.groupId,
    required this.groupName,
    required this.members,
    required this.memberIds,  // Initialize member IDs
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
    required this.creatorId,
  });

  // Create an instance from a Firestore map
  factory HabitWiseGroup.fromMap(Map<String, dynamic> map) {
    return HabitWiseGroup(
      groupId: map['groupId'] as String,
      groupName: map['groupName'] as String,
      members: List<Member>.from((map['members'] as List).map((m) {
        if (m is Map<String, dynamic>) {
          return Member.fromMap(m);
        } else {
          print("Invalid member data found: $m");
          return null;
        }
      }).where((member) => member != null)),  // Remove null members
      memberIds: List<String>.from(map['memberIds'] ?? []),  // Get member IDs
      habits: List<String>.from(map['habits'] ?? []),
      groupType: map['groupType'] as String,
      groupPictureUrl: map['groupPictureUrl'] as String?,
      creationDate: (map['creationDate'] as Timestamp).toDate(),
      description: map['description'] as String,
      groupCode: map['groupCode'] as String,
      completedGoals: map['completedGoals'] ?? 0,
      completedGoalIds: List<String>.from(map['completedGoalIds'] ?? []),
      groupRoles: Map<String, String>.from(map['groupRoles'] ?? {}),
      goals: List<Goal>.from((map['goals'] as List?)?.map((g) {
        if (g is Map<String, dynamic>) {
          return Goal.fromMap(g);
        } else {
          print("Invalid goal data found: $g");
          return null;
        }
      }) ?? []),
      creatorId: map['creatorId'] as String,
    );
  }

  // Convert the instance to a Firestore map
  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'members': members.map((member) => member.toMap()).toList(),
      'memberIds': memberIds,  // Add member IDs for querying
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
      'creatorId': creatorId,
    };
  }

  // Copy method to create a modified instance
  HabitWiseGroup copyWith({
    String? groupId,
    String? groupName,
    DateTime? creationDate,
    String? description,
    List<Member>? members,
    List<String>? memberIds,  // Allow updating memberIds
    List<String>? habits,
    String? groupType,
    String? groupPictureUrl,
    String? groupCode,
    int? completedGoals,
    List<String>? completedGoalsCount,
    List<Goal>? goals,
    Map<String, String>? groupRoles,
    String? creatorId,
  }) {
    return HabitWiseGroup(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      members: members ?? this.members,
      memberIds: memberIds ?? this.memberIds,  // Copy member IDs
      habits: habits ?? this.habits,
      groupType: groupType ?? this.groupType,
      groupPictureUrl: groupPictureUrl ?? this.groupPictureUrl,
      creationDate: creationDate ?? this.creationDate,
      description: description ?? this.description,
      groupCode: groupCode ?? this.groupCode,
      completedGoals: completedGoals ?? this.completedGoals,
      completedGoalIds: completedGoalsCount ?? this.completedGoalIds,
      goals: goals ?? this.goals,
      groupRoles: groupRoles ?? this.groupRoles,
      creatorId: creatorId ?? this.creatorId,
    );
  }

  // Optional: Methods for managing completed goals
  void incrementCompletedGoals() {
    completedGoals += 1;
  }

  void addCompletedGoal(String goalId) {
    completedGoalIds.add(goalId);
  }

  // Method to get the role of a user in the group
  String getUserRole(String userId) {
    return groupRoles[userId] ?? 'member';  // Default role is 'member'
  }
}
