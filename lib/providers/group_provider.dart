import 'package:flutter/material.dart';
import 'package:habitwise/models/group.dart';
import '../services/group_db_service.dart';

class GroupProvider extends ChangeNotifier {
  final GroupDBService _groupDBService = GroupDBService();
  List<HabitWiseGroup> _groups = [];

   GroupProvider() {
    fetchGroups();
  }

  List<HabitWiseGroup> get groups => _groups;

  Future<void> fetchGroups() async {
    try {
      List<HabitWiseGroup> fetchedGroups = await _groupDBService.getAllGroups();
      _groups = fetchedGroups;
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error fetching groups: $e');
    }
  }

  Future<void> addGoalToGroup(String groupId, String goal) async {
    try {
      await _groupDBService.addGoalToGroup(groupId, goal);
      await fetchGroups(); //Refreshes groups
    } catch (e) {
      print('Error adding goal: $e');
    }
  }

  Future<void> addHabitToGroup(String groupId, String habit) async {
    try {
      await _groupDBService.addHabitToGroup(groupId, habit);
      await fetchGroups();
    }catch (e) {
      print('Error adding habit $e');
    }
  }

Future<void> createGroup(HabitWiseGroup group) async {
  try {
    String groupId = await _groupDBService.createGroup(group);
    group = HabitWiseGroup(
      groupId: groupId,
      groupName: group.groupName,
      members: group.members,
      goals: group.goals,
      habits: group.habits,
      groupType: group.groupType,
      groupPictureUrl: group.groupPictureUrl,
      groupCreator: group.groupCreator,
      creationDate: group.creationDate,
      description: group.description,
    );
    await fetchGroups(); // Fetch the latest groups after creating a new group
    notifyListeners();
  } catch (e) {
    print('Error creating group: $e');
  }
}

  Future<void> joinGroup(String groupId, String userId) async {
    try {
      await _groupDBService.joinGroup(groupId, userId);
      // Update the local list of groups to reflect the change
      _groups.forEach((group) {
        if (group.groupId == groupId) {
          group.members.add(userId);
        }
      });
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error joining group: $e');
    }
  }

  Future<void> leaveGroup(String groupId, String userId) async {
    try {
      await _groupDBService.leaveGroup(groupId, userId);
      // Update the local list of groups to reflect the change
      _groups.forEach((group) {
        if (group.groupId == groupId) {
          group.members.remove(userId);
        }
      });
      notifyListeners();
    } catch (e) {
      // Handle error
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
}
