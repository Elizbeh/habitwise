import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/models/member.dart';
import '../services/group_db_service.dart';
import '../services/member_db_service.dart';

class GroupProvider extends ChangeNotifier {
  final GroupDBService _groupDBService = GroupDBService();
  final MemberDBService _memberDBService = MemberDBService();
  List<HabitWiseGroup> _groups = [];
  List<Member> _members = [];

  List<HabitWiseGroup> get groups => _groups;
  List<Member> get members => _members;

  String? _userId;

  // New getter to retrieve user-specific groups
  List<HabitWiseGroup> get userGroups {
    return _groups.where((group) => group.members.any((member) => member.id == _userId)).toList();
  }

  // Refactored fetchGroups method to query Firestore directly
  Future<void> fetchGroups(String userId) async {
    _userId = userId;
    try {
      // Query to fetch groups where the user is a member
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .where('members', arrayContains: userId)
          .get();

      List<HabitWiseGroup> fetchedGroups = querySnapshot.docs.map((doc) {
        return HabitWiseGroup.fromMap(doc as Map<String, dynamic>);
      }).toList();

      _groups = fetchedGroups;
      notifyListeners();
    } catch (e) {
      print('Error fetching groups: $e');
    }
  }

  Future<void> addGoalToGroup(String groupId, String goalId, String userId) async {
    try {
      await _groupDBService.addGoalToGroup(groupId, goalId);
      await fetchGroups(userId);
    } catch (e) {
      print('Error adding goal: $e');
    }
  }

  Future<String> createGroup(HabitWiseGroup group) async {
    try {
      String groupId = await _groupDBService.createGroup(group);
      group = group.copyWith(groupId: groupId);
      _groups.add(group);
      notifyListeners();
      return groupId;
    } catch (e) {
      print('Error creating group: $e');
      rethrow;
    }
  }

  Future<bool> joinGroup(String groupCode, String userId) async {
  try {
    // Query Firestore by the groupCode field, not doc ID
    final querySnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .where('groupCode', isEqualTo: groupCode)
        .limit(1)
        .get();
    
    if (querySnapshot.docs.isNotEmpty) {
      final groupDoc = querySnapshot.docs.first;
      
      // Now check if the user exists
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        String name = userDoc['name'] ?? 'Unknown';
        String email = userDoc['email'] ?? 'unknown@example.com';

        // Create the new member
        Member member = Member(id: userId, name: name, email: email);

        // Use the groupId from the queried document
        await _groupDBService.joinGroup(groupDoc.id, userId, member);
        await fetchGroups(userId);
        return true;
      } else {
        return false; // User document doesn't exist
      }
    } else {
      return false; // Group with the given groupCode not found
    }
  } catch (e) {
    print("Error joining group: $e");
    return false;
  }
}

  Future<void> leaveGroup(String groupId, String userId) async {
    try {
      await _groupDBService.leaveGroup(groupId, userId);
      HabitWiseGroup group = _groups.firstWhere((g) => g.groupId == groupId);
      group.members.removeWhere((member) => member.id == userId);
      notifyListeners();
    } catch (e) {
      print('Error leaving group: $e');
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await _groupDBService.deleteGroup(groupId);
      _groups.removeWhere((group) => group.groupId == groupId);
      notifyListeners();
    } catch (e) {
      print('Error deleting group: $e');
    }
  }

  Future<List<String>> fetchGroupGoals(String groupId) async {
    try {
      List<String> goals = await _groupDBService.getGroupGoals(groupId);
      return goals;
    } catch (e) {
      print('Error fetching group goals: $e');
      throw e;
    }
  }

  Future<void> updateGroup(HabitWiseGroup group) async {
    try {
      await _groupDBService.updateGroup(group);
      int index = _groups.indexWhere((g) => g.groupId == group.groupId);
      if (index != -1) {
        _groups[index] = group;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating group: $e');
    }
  }

  bool isAdmin(String groupId, String userId) {
    final group = _groups.firstWhere((g) => g.groupId == groupId);
    return group.groupCreator == userId;
  }

  Future<void> fetchMembers(String groupId) async {
    try {
      List<Member> membersList = await _groupDBService.getGroupMembers(groupId);
      _members = membersList;
      notifyListeners();
    } catch (e) {
      print('Error fetching group members: $e');
    }
  }

  void clearUserGroups() {
    _groups.clear();
    notifyListeners();
  }

  void clearMembers() {
    _members.clear();
    notifyListeners();
  }
}
