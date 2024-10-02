import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/member.dart';

class HabitWiseUser {
  final String uid;
  final String email;
  final String username;
  final List<String> goals;
  final List<String> habits;
  final Map<String, dynamic> soloStats;
  final List<String> groupIds;
  final Map<String, String> groupRoles;
  String? profilePictureUrl;
  final bool canCreateGroup;
  bool canJoinGroups;
  bool emailVerified;
  

  // Constructor to initialize the HabitWiseUser instance
  HabitWiseUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.goals,
    required this.habits,
    required this.soloStats,
    required this.groupIds,
    required this.groupRoles,
    this.profilePictureUrl,
    this.canCreateGroup = true,
    required this.canJoinGroups,
    required this.emailVerified,
  
  });

  // Factory constructor to create a HabitWiseUser instance from a map
  factory HabitWiseUser.fromMap(Map<String, dynamic> data) {
    return HabitWiseUser(
      uid: data['uid'],
      email: data['email'],
      username: data['username'],
      goals: List<String>.from(data['goals'] ?? []),
      habits: List<String>.from(data['habits'] ?? []),
      soloStats: Map<String, dynamic>.from(data['soloStats'] ?? {}),
      groupIds: List<String>.from(data['groupIds'] ?? []),
      groupRoles: Map<String, String>.from(data['groupRoles'] ?? {}),
      profilePictureUrl: data['profilePictureUrl'],
      canCreateGroup: data['canCreateGroup'] ?? true,
      canJoinGroups: data['canJoinGroups'] ?? false,
      emailVerified: data['emailVerified'] ?? false,
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
      'groupRoles': groupRoles,
      'profilePictureUrl': profilePictureUrl,
      'canCreateGroup': canCreateGroup,
      'canJoinGroups': canJoinGroups,
      'emailVerified': emailVerified,
    };
  }

  // CopyWith function to create a copy of the object with updated fields
  HabitWiseUser copyWith({
    String? uid,
    String? email,
    String? username,
    List<String>? goals,
    List<String>? habits,
    Map<String, dynamic>? soloStats,
    List<String>? groupIds,
    final Map<String, String>? groupRoles,
    String? profilePictureUrl,
    bool? canCreateGroup,
    bool? canJoinGroups,
    bool? emailVerified,
  }) {
    return HabitWiseUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      goals: goals ?? this.goals,
      habits: habits ?? this.habits,
      soloStats: soloStats ?? this.soloStats,
      groupIds: groupIds ?? this.groupIds,
      groupRoles: groupRoles ?? this.groupRoles,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      canCreateGroup: canCreateGroup ?? this.canCreateGroup,
      canJoinGroups: canJoinGroups ?? this.canJoinGroups,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  // Convert HabitWiseUser to Member
  Member toMember() {
    return Member(
      id: uid,
      name: username,
      email: email,
      profilePictureUrl: profilePictureUrl,
      
    );
  }
}
