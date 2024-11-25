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
  int createdGroups;
  int joinedGroups;
  

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
    required this.canCreateGroup,
    required this.canJoinGroups,
    required this.emailVerified,
    this.createdGroups = 0,
    this.joinedGroups = 0,
  
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
      canCreateGroup: data['canCreateGroup'] ?? false,
      canJoinGroups: data['canJoinGroups'] ?? false,
      emailVerified: data['emailVerified'] ?? false,
       createdGroups: data['createdGroups'] ?? 0, // Handle null values
      joinedGroups: data['joinedGroups'] ?? 0,  
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
      'createdGroups': createdGroups,
      'joinedGroups': joinedGroups,
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
    int? createdGroups,
    int? joinedGroups,
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
      createdGroups: createdGroups ?? this.createdGroups,
      joinedGroups: joinedGroups ?? this.joinedGroups,
    );
  }
  //Convert HabitWiseUser to Member
  Member toMember({MemberRole role = MemberRole.member}) {
    return Member(
      id: uid,
      name: username,
      role: role,  // Now passing a MemberRole instead of String
      email: email,
      profilePictureUrl: profilePictureUrl,
      joinedDate: DateTime.now(),  // Assuming the user just joined
    );
  }
}
