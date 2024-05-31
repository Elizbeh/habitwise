import 'package:flutter/material.dart';
import 'package:habitwise/models/group.dart';
import '../services/group_db_service.dart';

class GroupProvider extends ChangeNotifier {
  final GroupDBService _groupDBService = GroupDBService();
  List<HabitWiseGroup> _groups = [];

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
      );
      _groups.add(group);
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
}
