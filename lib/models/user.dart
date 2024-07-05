import 'package:cloud_firestore/cloud_firestore.dart';

class HabitWiseUser {
  final String uid;
  final String email;
  final String username;
  final List<String> goals;
  final List<String> habits;
  final Map<String, dynamic> soloStats;
  final List<String> groupIds;
  String? profilePictureUrl;
  final bool canCreateGroup;
  final bool canJoinGroups;

  // Constructor to initialize the HabitWiseUser instance
  HabitWiseUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.goals,
    required this.habits,
    required this.soloStats,
    required this.groupIds,
    this.profilePictureUrl,
    required this.canCreateGroup,
    required this.canJoinGroups, required String id,
  });

  // Factory constructor to create a HabitWiseUser instance from a map
  factory HabitWiseUser.fromMap(Map<String, dynamic> data) {
    return HabitWiseUser(
      uid: data['uid'],
      email: data['email'],
      username: data['username'],
      goals: List<String>.from(data['goals']),
      habits: List<String>.from(data['habits']),
      soloStats: Map<String, dynamic>.from(data['soloStats']),
      groupIds: List<String>.from(data['groupIds']),
      profilePictureUrl: data['profilePictureUrl'],
      canCreateGroup: data['canCreateGroup'] ?? false,
      canJoinGroups: data['canJoinGroup'] ?? false, id: '',
    );
  }

  // Method to convert a HabitWiseUser instance to a map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'goals': goals,
      'habits': habits,
      'soloStats': soloStats,
      'groupIds': groupIds,
      'profilePictureUrl': profilePictureUrl,
      'canCreateGroup': canCreateGroup,
      'canJoinGroup': canJoinGroups,
    };
  }
}
