import 'package:cloud_firestore/cloud_firestore.dart';

class HabitWiseUser {
  final String uid;
  final String email;
  final String username;
  final List<String> goals;
  final List<String> habits;
  final Map<String, dynamic> soloStats;
  final String familyId;
  final List<String> groupIds;
  final String? profilePictureUrl;

  HabitWiseUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.goals,
    required this.habits,
    required this.soloStats,
    required this.familyId,
    required this.groupIds,
    this.profilePictureUrl,
  });

  factory HabitWiseUser.fromMap(Map<String, dynamic> data) {
    return HabitWiseUser(
      uid: data['uid'],
      email: data['email'],
      username: data['username'],
      goals: List<String>.from(data['goals']),
      habits: List<String>.from(data['habits']),
      soloStats: Map<String, dynamic>.from(data['soloStats']),
      familyId: data['familyId'],
      groupIds: List<String>.from(data['groupIds']),
      profilePictureUrl: data['profilePictureUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'goals': goals,
      'habits': habits,
      'soloStats': soloStats,
      'familyId': familyId,
      'groupIds': groupIds,
      'profilePictureUrl': 'profilePictureUrl',
    };
  }
}
