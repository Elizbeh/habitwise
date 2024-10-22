import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/models/member.dart';
import 'package:habitwise/services/member_db_service.dart';

class GroupDBService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MemberDBService _memberDBService = MemberDBService();

  CollectionReference get groupsCollection => _firestore.collection('groups');

   Future<String> createGroup(HabitWiseGroup group) async {
    try {
      DocumentReference docRef = await groupsCollection.add(group.toMap());
      await docRef.update({'groupId': docRef.id}); // Update groupId after creation
      return docRef.id;
    } catch (e) {
      print('Error creating group: $e');
      throw e;
    }
}



  Future<List<HabitWiseGroup>> getAllGroups(String userId) async {
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

  Future<void> joinGroup(String groupId, String userId, Member newMember) async {
  DocumentReference groupRef = groupsCollection.doc(groupId);
  DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);

  // Use Firestore transaction for atomicity
  await _firestore.runTransaction((transaction) async {
    // Get the group document
    DocumentSnapshot groupDoc = await transaction.get(groupRef);
    if (!groupDoc.exists) {
      throw Exception('Group not found');
    }

    // Add user to group members array
    transaction.update(groupRef, {
      'members': FieldValue.arrayUnion([newMember.toMap()])
    });

    // Add member to the member collection if needed
    await _memberDBService.addMemberToGroup(groupId, newMember);
  });
}

  Future<void> leaveGroup(String groupId, String userId) async {
    try {
      await groupsCollection.doc(groupId).update({
        'members': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      print('Error leaving group: $e');
      throw e;
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await groupsCollection.doc(groupId).delete();
    } catch (e) {
      print('Error deleting group: $e');
      throw e;
    }
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
    try {
      DocumentSnapshot doc = await groupsCollection.doc(groupId).get();
      if (doc.exists) {
        Map<String, dynamic> data = Map<String, dynamic>.from(doc.data() as Map);
        List<dynamic> membersData = List.from(data['members'] ?? []);
        return membersData
            .map((memberData) => Member.fromMap(Map<String, dynamic>.from(memberData)))
            .toList();
      } else {
        throw Exception('Group not found');
      }
    } catch (e) {
      print('Error fetching group members: $e');
      throw e;
    }
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
