import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/models/member.dart';
import 'package:habitwise/models/user.dart';
import 'package:habitwise/services/group_db_service.dart';

class GroupProvider extends ChangeNotifier {
  final GroupDBService _groupDBService = GroupDBService();
  List<HabitWiseGroup> _groups = [];
  List<Member> _members = [];
  String? _userId;
  HabitWiseUser? _user;

  List<HabitWiseGroup> get groups => _groups;
  List<Member> get members => _members;

  // New getter to retrieve user-specific groups
  List<HabitWiseGroup> get userGroups {
    return _groups.where((group) => group.members.any((member) => member.id == _userId)).toList();
  }

  Future<void> fetchGroups(String userId) async {
  _userId = userId; // Ensure you have a user ID if needed
  try {
    // Fetch groups from the database
    List<HabitWiseGroup> fetchedGroups = await _groupDBService.getAllGroups(userId);
    
    // Assign the fetched groups to _groups
    _groups = fetchedGroups;

    // Notify listeners that the groups have been updated
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
    final querySnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .where('groupCode', isEqualTo: groupCode)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final groupDoc = querySnapshot.docs.first;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        String name = userDoc['name'] ?? 'Unknown';
        String email = userDoc['email'] ?? 'unknown@example.com';

         // Assuming a default role for all new members
        MemberRole role = MemberRole.member;  

        // Create a Member object with role
        Member member = Member(
          id: userId,
          name: name,
          role: role,
          email: email,
        );

        // Join the group and update the database
        await _groupDBService.joinGroup(groupDoc.id, userId, member);
        await fetchGroups(userId);
        return true;
      } else {
        return false; // User document doesn't exist
      }
    } else {
      return false; // Group not found
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

  Future<void> markGroupGoalAsCompleted(String groupId, String goalId) async {
    try {
      // First, mark the goal as completed using the GroupDBService
      await _groupDBService.markGoalAsCompleted(groupId, goalId);

      // Now, update the progress of the goal to 100%
      await _groupDBService.updateGroupGoalProgress(goalId, 100, groupId: groupId);

      // After updating the goal in the database, update the group's local goal data
      HabitWiseGroup group = _groups.firstWhere((g) => g.groupId == groupId);

      // Assuming your HabitWiseGroup now has a list of goals
      int goalIndex = group.goals.indexWhere((g) => g.id == goalId);
      if (goalIndex != -1) {
        // Use copyWith to create a new Goal object with updated progress and isCompleted values
        Goal updatedGoal = group.goals[goalIndex].copyWith(
          progress: 100,  // Set progress to 100%
          isCompleted: true,  // Mark as completed
        );

        // Replace the old goal with the updated one in the group
        group.goals[goalIndex] = updatedGoal;

        // Notify listeners to update the UI
        notifyListeners();
      }
    } catch (error) {
      print("Error marking group goal as completed: $error");
      throw error;  // Rethrow to handle it upstream
    }
  }

  // Method to celebrate achievement
  void celebrateAchievement(String groupId) {
    // Notify all group members of the achievement
    for (var member in _members) {
      showCelebrationNotification(member);
    }
    
    // Optionally, show a celebration dialog or other feedback
    showCelebrationDialog(groupId);
  }

  void showCelebrationNotification(Member member) {
    // Implement your notification logic here
    print('Celebrating achievement with ${member.name}');
  }

  void showCelebrationDialog(String groupId) {
    // Implement a dialog or other UI feedback for celebration
    print('Celebrating goal completion for group: $groupId');
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
