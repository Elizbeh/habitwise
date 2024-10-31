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
  String? _userId; // Assume you set this somewhere in your app
  HabitWiseUser? _user;

  List<HabitWiseGroup> get groups => _groups;
  List<Member> get members => _members;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // New getter to retrieve user-specific groups
  List<HabitWiseGroup> get userGroups {
  if (_userId == null) return []; // Ensure userId is set
  // Filter groups where the current user is a member
  return _groups.where((group) => group.memberIds.contains(_userId)).toList();
}


  Future<void> fetchGroups(String userId) async {
  print('Fetching groups for user: $userId');
  _isLoading = true;
  notifyListeners();

  try {
    // Fetch groups where the user is a member
    QuerySnapshot memberGroupsSnapshot = await _groupDBService.groupsCollection
        .where('memberIds', arrayContains: userId) // Query using memberIds
        .get();

    // Fetch groups created by the user
    QuerySnapshot createdGroupsSnapshot = await _groupDBService.groupsCollection
        .where('creatorId', isEqualTo: userId) // Fetch groups created by the user
        .get();

    // Create a Set to track unique group IDs and avoid duplicates
    Set<String> uniqueGroupIds = Set<String>();

    // Fetch and combine joined groups
    List<HabitWiseGroup> fetchedGroups = [];
    for (var doc in memberGroupsSnapshot.docs) {
      HabitWiseGroup group = HabitWiseGroup.fromMap(doc.data() as Map<String, dynamic>);
      if (uniqueGroupIds.add(group.groupId)) { // Add group ID to the set
        fetchedGroups.add(group);
      }
    }

    // Fetch and combine created groups
    for (var doc in createdGroupsSnapshot.docs) {
      HabitWiseGroup group = HabitWiseGroup.fromMap(doc.data() as Map<String, dynamic>);
      if (uniqueGroupIds.add(group.groupId)) { // Only add if it's not already in the set
        fetchedGroups.add(group);
      }
    }

    // Assign the unique groups to _groups
    _groups = fetchedGroups;

    _isLoading = false;
    notifyListeners();
  } catch (e) {
    print("Error fetching groups: $e");
    _isLoading = false;
    notifyListeners();
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

  Future<bool> joinGroup(String groupCode, String userId, BuildContext context) async {
  try {
    // Check if the group exists using the group code
    QuerySnapshot<Object?> groupSnapshot = await _groupDBService.groupsCollection
        .where('groupCode', isEqualTo: groupCode)
        .limit(1)
        .get();

    // Check if any groups were found
    if (groupSnapshot.docs.isEmpty) {
      throw Exception('Group not found with the provided code.');
    }

    // Get the group document reference
    QueryDocumentSnapshot<Object?> groupDoc = groupSnapshot.docs.first;
    String groupId = groupDoc.id;

    // Retrieve user details for the `Member` object
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!userSnapshot.exists) {
      throw Exception('User not found.');
    }
    
    
    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
    String userName = userData['username'] ?? 'Unknown';
    String userEmail = userData['email'] ?? '';

    // Create the new member with the fetched details
    Member newMember = Member(
      id: userId,
      name: userName,  // Make sure name is correctly populated
      email: userEmail,
      profilePictureUrl: userData['profilePictureUrl'],
      role: MemberRole.member,
      joinedDate: DateTime.now(),
    );

    // Add user to the group members and memberIds
    await _groupDBService.groupsCollection.doc(groupId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
      'members': FieldValue.arrayUnion([newMember.toMap()]),
    });

    // Fetch updated groups for the user
    await fetchGroups(userId); // Refresh the groups after joining
    return true;
  } catch (e) {
    print('Error joining group: $e');
    return false;
  }
}



  Future<HabitWiseGroup?> fetchGroup(String groupId) async {
    try {
      HabitWiseGroup? group = await _groupDBService.getGroupById(groupId);
      return group;
    } catch (e) {
      print('Error fetching group: $e');
      return null; // Return null if there was an error
    }
  }

 Future<void> leaveGroup(String groupId, String userId) async {
  try {
    // Call the database service to leave the group
    await _groupDBService.leaveGroup(groupId, userId);
    
    // Remove user from group in the UI
    final groupToRemove = _groups.firstWhere((g) => g.groupId == groupId);
    groupToRemove.members.removeWhere((member) => member.id == userId);
    
    //Remove userId from the memberIds list
    groupToRemove.memberIds.remove(userId); // Update this line

    // O. remove the group itself if it no longer has members
    //if (groupToRemove.members.isEmpty) {
      //_groups.remove(groupToRemove);
    //}

    notifyListeners();
  } catch (e) {
    print('Error leaving group: $e');
  }
}


Future<void> deleteGroup(String groupId, String creatorId, String currentUserId) async {
  if (creatorId == currentUserId) {
    // Only the creator can delete the group
    try {
      await _groupDBService.deleteGroup(groupId);
      _groups.removeWhere((group) => group.groupId == groupId);
      notifyListeners();
    } catch (e) {
      print('Error deleting group: $e');
    }
  }
}

  Future<List<Goal>> fetchGroupGoals(String groupId) async {
    try {
      List<String> goalIds = await _groupDBService.getGroupGoals(groupId);
      List<Goal> goals = await _groupDBService.fetchGoalsByIds(goalIds);

      HabitWiseGroup group = _groups.firstWhere((g) => g.groupId == groupId);
      group.goals = goals; // Update the group's goals
      notifyListeners();
      return goals;
    } catch (e) {
      print('Error fetching group goals: $e');
      throw e;
    }
  }

  Future<void> markGroupGoalAsCompleted(String groupId, String goalId) async {
    try {
      await _groupDBService.markGoalAsCompleted(groupId, goalId);
      await _groupDBService.updateGroupGoalProgress(goalId, 100, groupId: groupId);

      HabitWiseGroup group = _groups.firstWhere((g) => g.groupId == groupId);
      int goalIndex = group.goals.indexWhere((g) => g.id == goalId);
      if (goalIndex != -1) {
        Goal updatedGoal = group.goals[goalIndex].copyWith(
          progress: 100,
          isCompleted: true,
        );

        group.goals[goalIndex] = updatedGoal;
        notifyListeners();
      }
    } catch (error) {
      print("Error marking group goal as completed: $error");
      throw error;
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

  Future<void> fetchMembers(String groupId) async {
    try {
      List<Member> membersList = await _groupDBService.getGroupMembers(groupId);
      _members = membersList;
      notifyListeners();
    } catch (e) {
      print('Error fetching group members: $e');
    }
  }


  Future<void> addGoalToGroup(String groupId, String goalId, String userId) async {
    try {
      await _groupDBService.addGoalToGroup(groupId, goalId);
      await fetchGroups(userId); // Refresh groups after adding goal
    } catch (e) {
      print('Error adding goal: $e');
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
