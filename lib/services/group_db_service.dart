import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/goal.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/models/member.dart';
import 'package:habitwise/services/member_db_service.dart';

class GroupDBService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MemberDBService _memberDBService = MemberDBService();

  CollectionReference get groupsCollection => _firestore.collection('groups');

  Future<String> createGroup(HabitWiseGroup group) async {
  try {
    List<Map<String, dynamic>> membersMap = group.members.map((member) => member.toMap()).toList();

    DocumentReference docRef = await groupsCollection.add({
      ...group.toMap(),
      'members': membersMap,
      'memberIds': group.members.map((member) => member.id).toList(), // Add this line
      'creatorId': group.creatorId,
    });

    await docRef.update({'groupId': docRef.id});
    
   // Update createdGroups count for the user in Firestore
    await FirebaseFirestore.instance.collection('users').doc(group.creatorId).update({
      'createdGroups': FieldValue.increment(1),
    });

    return docRef.id;
  } catch (e) {
    print('Error creating group: $e');
    throw e;
  }
}

  Future<void> joinGroup(String groupId, String userId, String userName, String userEmail) async {
  // Create a Member instance using the provided details
  Member member = Member(
    id: userId,
    name: userName,
    role: MemberRole.member, // Set the default role
    email: userEmail,
  );

  // Debugging statement to check the member details
  print('Joining group: $groupId with member: ${member.toMap()}');

  // Now use the member object to add it to the group
  await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
    'members': FieldValue.arrayUnion([member.toMap()]), // Convert the member to a map
    'memberIds': FieldValue.arrayUnion([userId]), // Add the user ID to the memberIds field
  });
  
}


  Future<List<HabitWiseGroup>> getAllGroups(String userId) async {
    print('Querying groups where members contain: $userId');
    try {
      QuerySnapshot querySnapshot = await groupsCollection.where('members', arrayContains: userId).get();
      List<HabitWiseGroup> groups = [];
      for (var doc in querySnapshot.docs) {
        try {
          groups.add(HabitWiseGroup.fromMap(doc.data() as Map<String, dynamic>));
        } catch (e) {
          print('Error parsing group data: ${doc.id} - $e');
        }
      }
      return groups;
    } catch (e) {
      print('Error fetching groups: $e');
      throw e;
    }
  }

  // Method to join a group by groupId and userId
 
  Future<List<HabitWiseGroup>> fetchGroups(String userId) async {
  print('Fetching groups for user: $userId');
  try {
    QuerySnapshot querySnapshot = await _firestore
        .collection('groups')
        .where('members', arrayContains: userId) // Query the memberIds array
        .get();

    if (querySnapshot.docs.isEmpty) {
      print("No groups found for user: $userId");
      return [];
    }

    List<HabitWiseGroup> groups = querySnapshot.docs.map((doc) {
      return HabitWiseGroup.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    return groups;
  } catch (e) {
    print("Error fetching groups for user $userId: $e");
    throw e;
  }
}

Future<void> deleteGroup(String groupId) async {
  try {
    // Delete the group document in Firestore
    await groupsCollection.doc(groupId).delete();
  } catch (e) {
    print('Error deleting group: $e');
    throw e;
  }
}

// Fetch groups where a specific user is a member
Future<List<HabitWiseGroup>> fetchGroupsByUserId(String userId) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('groups')
      .where('memberIds', arrayContains: userId)
      .get();

  return querySnapshot.docs.map((doc) {
    return HabitWiseGroup.fromMap(doc.data() as Map<String, dynamic>);
  }).toList();
}

Future<void> leaveGroup(String groupId, String userId) async {
  DocumentReference groupRef = groupsCollection.doc(groupId);

  await _firestore.runTransaction((transaction) async {
    DocumentSnapshot groupDoc = await transaction.get(groupRef);
    if (!groupDoc.exists) {
      throw Exception('Group not found');
    }

    Map<String, dynamic> data = groupDoc.data() as Map<String, dynamic>;
    List<dynamic> membersData = data['members'] ?? [];

    List<dynamic> updatedMembers = membersData.where((member) {
      return (member as Map<String, dynamic>)['id'] != userId;
    }).toList();

    transaction.update(groupRef, {
      'members': updatedMembers,
    });

    await _memberDBService.removeMemberFromGroup(groupId, userId);
  });
}


  // Method to get a specific group by ID
  Future<HabitWiseGroup?> getGroupById(String groupId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('groups').doc(groupId).get();

      if (doc.exists) {
        // Assuming your HabitWiseGroup model has a fromMap constructor
        return HabitWiseGroup.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        print('Group not found');
        return null;
      }
    } catch (e) {
      print('Error getting group by ID: $e');
      return null;
    }
  }

  Future<List<Goal>> fetchGoalsByIds(List<String> goalIds) async {
    List<Goal> goals = [];
    try {
      for (String goalId in goalIds) {
        DocumentSnapshot goalDoc = await _firestore.collection('goals').doc(goalId).get();
        if (goalDoc.exists) {
          // Call fromMap with only the map data
          goals.add(Goal.fromMap(goalDoc.data() as Map<String, dynamic>));
        } else {
          print('Goal not found: $goalId');
        }
      }
    } catch (e) {
      print('Error fetching goals: $e');
    }
    return goals;
  }

  Future<void> addGoalToGroup(String groupId, String goalId) async {
    try {
      await groupsCollection.doc(groupId).update({
        'goals': FieldValue.arrayUnion([goalId]),
      });
    } catch (e) {
      print('Error adding goal to group: $e');
      throw e;
    }
  }

  Future<List<String>> getGroupGoals(String groupId) async {
    try {
      DocumentSnapshot doc = await groupsCollection.doc(groupId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return List<String>.from(data['goals'] ?? []);
      } else {
        throw Exception('Group not found');
      }
    } catch (e) {
      print('Error fetching group goals: $e');
      throw e;
    }
  }

  Future<List<Member>> getGroupMembers(String groupId) async {
  final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
  final List<dynamic> membersData = groupDoc.data()?['members'] ?? [];
  return membersData.map((data) => Member.fromMap(data)).toList();  // Ensure you have a fromMap method
}

  Future<void> updateGroup(HabitWiseGroup group) async {
    try {
      await groupsCollection.doc(group.groupId).update(group.toMap());
    } catch (e) {
      print("Error updating group: $e");
      throw e;
    }
  }

  Future<void> markGoalAsCompleted(String groupId, String goalId) async {
    try {
      await groupsCollection.doc(groupId).update({
        'goals': FieldValue.arrayRemove([goalId]), // Remove the goal from active goals
        'completedGoals': FieldValue.arrayUnion([goalId]), // Optionally keep track of completed goals
      });
    } catch (e) {
      print('Error marking goal as completed: $e');
      throw e;
    }
  }

  // Method to update group goal progress in Firestore
  Future<void> updateGroupGoalProgress(String goalId, int progress, {required String groupId}) async {
    try {
      // Reference to the specific group goal document in Firestore
      DocumentReference goalRef = FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('goals')
          .doc(goalId);

      // Update the progress field of the group goal
      await goalRef.update({
        'progress': progress,
      });
    } catch (error) {
      print("Error updating group goal progress: $error");
      throw error; // Rethrow the error for further handling if needed
    }
  }
}
