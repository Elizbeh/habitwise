import 'package:flutter/material.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/models/member.dart';
import '../services/group_db_service.dart';
import '../services/member_db_service.dart';

class GroupProvider extends ChangeNotifier {
  final GroupDBService _groupDBService = GroupDBService();
  final MemberDBService _memberDBService = MemberDBService(); // Added MemberDBService
  List<HabitWiseGroup> _groups = [];

  List<HabitWiseGroup> get groups => _groups;

  Future<void> fetchGroups(String userId) async {
    try {
      List<HabitWiseGroup> fetchedGroups = await _groupDBService.getAllGroups(userId);
      _groups = fetchedGroups;
      notifyListeners();
    } catch (e) {
      print('Error fetching groups: $e');
    }
  }

  Future<void> addGoalToGroup(String groupId, String goal, String userId) async {
    try {
      await _groupDBService.addGoalToGroup(groupId, goal);
      await fetchGroups(userId); // Refreshes groups
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
      rethrow; // Optional: propagate the exception if needed
    }
  }

  Future<void> joinGroup(String groupId, String userId) async {
    try {
      // Fetch the Member object corresponding to the userId
      final newMember = await _memberDBService.getMemberById(userId);  // Fetch the member by ID

      // Call the service to join the group in the database
      await _groupDBService.joinGroup(groupId, userId);

      // Update the group in local state
      _groups.forEach((group) {
        if (group.groupId == groupId) {
          group.members.add(newMember);  // Add the Member object to the group's members list
        }
      });

      // Notify listeners to update the UI
      notifyListeners();
    } catch (e) {
      print('Error joining group: $e');
    }
  }

  Future<void> leaveGroup(String groupId, String userId) async {
    try {
      await _groupDBService.leaveGroup(groupId, userId);
      // Update the local list of groups to reflect the change
      _groups.forEach((group) {
        if (group.groupId == groupId) {
          group.members.removeWhere((member) => member.id == userId); // Remove the Member object
        }
      });
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

  void removeGroup(String groupId) {
    _groups.removeWhere((group) => group.groupId == groupId);
    notifyListeners();
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

  
}
