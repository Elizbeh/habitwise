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
      await docRef.update({'groupId': docRef.id});
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
      throw Exception('Error fetching groups: $e');
    }
  }

  Future<void> joinGroup(String groupId, String userId, Member newMember) async {
  try {
    await groupsCollection.doc(groupId).update({
      'members': FieldValue.arrayUnion([newMember.toMap()]) // Add serialized Member object
    });
    await _memberDBService.addMemberToGroup(groupId, newMember);
  } catch (e) {
    print('Error joining group: $e');
    throw e;
  }
}


  Future<void> leaveGroup(String groupId, String userId) async {
    await groupsCollection.doc(groupId).update({
      'members': FieldValue.arrayRemove([userId])
    });
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await groupsCollection.doc(groupId).delete();
    } catch (e) {
      throw Exception('Error deleting group: $e');
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
      // Ensure doc.data() is cast to a Map<String, dynamic>
      Map<String, dynamic> data = Map<String, dynamic>.from(doc.data() as Map);
      
      // Now safely extract 'members' as a list
      List<dynamic> membersData = List.from(data['members'] ?? []);
      return membersData
          .map((memberData) => Member.fromMap(Map<String, dynamic>.from(memberData))) // Safely cast each member to Map<String, dynamic>
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
      await _firestore.collection('groups').doc(group.groupId).update(group.toMap());
    } catch (e) {
      print("Error updating group: $e");
      rethrow;
    }
  }
}
