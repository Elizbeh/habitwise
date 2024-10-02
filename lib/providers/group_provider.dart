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

   // New getter to retrieve user-specific groups
  List<HabitWiseGroup> get userGroups {
    return _groups.where((group) => group.members.any((member) => member.id == _userId)).toList();
  }

  String? _userId; // You might want to set this from the UserProvider or wherever you're managing user state

  Future<void> fetchGroups(String userId) async {
    _userId = userId; // Store the userId for reference
    try {
      print('Fetching groups for userId: $userId'); // Debugging
      List<HabitWiseGroup> fetchedGroups = await _groupDBService.getAllGroups(userId);
      print('Fetched groups: $fetchedGroups'); // Debugging
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

  Future<bool> joinGroup(String groupCode, String userId) async { // Pass userId as a parameter
    try {
      final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupCode).get();
      if (groupDoc.exists) {
        // Add user to the group members
        await FirebaseFirestore.instance.collection('groups').doc(groupCode).update({
          'members': FieldValue.arrayUnion([userId]) // Use userId parameter
        });
        
        // Refresh the list of groups
        await fetchGroups(userId); // Call fetchGroups here to update the group list
        return true;
      }
      return false;
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

  // New method to check if the user is the admin of the group
  bool isAdmin(String groupId, String userId) {
    final group = _groups.firstWhere((g) => g.groupId == groupId);
    return group.groupCreator == userId; // Returns true if the user is the creator
  }

    // Define this method to fetch groups again
  Future<void> _fetchGroups(String userId) async {
    await fetchGroups(userId); // Refreshes the groups based on user ID
  }

  Future<HabitWiseGroup?> getGroupByCode(String groupCode) async {
    try {
      return await _groupDBService.getGroupByCode(groupCode);
    } catch (e) {
      print('Error fetching group by code: $e');
      return null;
    }
  }


  // Update join group to use group code
  Future<bool> joinGroupByCode(String groupCode, String userId) async {
  try {
    HabitWiseGroup? group = await getGroupByCode(groupCode);
    if (group != null) {
      await joinGroup(group.groupId, userId);
      await fetchGroups(userId); // Refresh user's groups
      return true;
    } else {
      print("Group not found with code: $groupCode");
      return false; // Group not found
    }
  } catch (e) {
    print("Error joining group: $e");
    return false; // Ensure false is returned on error
  }
}

 // Method to add a new member and update state
  Future<void> addMember(String groupId, Member newMember) async {
    await _groupDBService.addMemberToGroup(groupId, newMember);
    _members.add(newMember); // Add to local list
    notifyListeners();       // Notify listeners to update the UI
  }

   // Fetch group members from Firestore and update _members list
  Future<void> fetchMembers(String groupId) async {
    try {
      // Reference to the group document in Firestore
      final groupRef = FirebaseFirestore.instance.collection('groups').doc(groupId);

      // Get the group document snapshot
      final groupSnapshot = await groupRef.get();

      if (groupSnapshot.exists) {
        // Get the members field from the document
        List<dynamic> membersData = groupSnapshot.data()?['members'] ?? [];

        // Clear the current members list
        _members.clear();

        // Convert each member map to a Member object and add to the _members list
        _members = membersData.map((memberData) => Member.fromMap(memberData)).toList();

        // Notify listeners to update the UI
        notifyListeners();
      } else {
        // Handle case when group does not exist
        print('Group not found');
      }
    } catch (e) {
      print('Error fetching group members: $e');
    }
  }

  void clearUserGroups() {
  _groups.clear(); // Clear the groups list
  notifyListeners(); // Notify listeners to update the UI
}

void clearMembers() {
  _members.clear(); // Clear the members list
  notifyListeners(); // Notify listeners to update the UI
}


}