import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/group.dart';
import 'package:habitwise/services/member_db_service.dart'; // Make sure this import is correct

class GroupDBService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MemberDBService _memberDBService = MemberDBService();

  CollectionReference get groupsCollection => _firestore.collection('groups');

  Future<String> createGroup(HabitWiseGroup group) async {
  try {
    // Convert the group to a map and add it to Firestore
    DocumentReference docRef = await groupsCollection.add(group.toMap());

    // Update the document with the groupId
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

  Future<HabitWiseGroup> getGroupById(String groupId) async {
    try {
      DocumentSnapshot doc = await groupsCollection.doc(groupId).get();
      if (doc.exists) {
        return HabitWiseGroup.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        throw Exception('Group not found');
      }
    } catch (e) {
      print('Error fetching group by ID: $e');
      throw e;
    }
  }

  Future<void> updateGroup(HabitWiseGroup group) async {
    await groupsCollection.doc(group.groupId).update(group.toMap());
  }

  Future<void> joinGroup(String groupId, String userId) async {
    await groupsCollection.doc(groupId).update({
      'members': FieldValue.arrayUnion([userId])
    });
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

  Future<void> addHabitToGroup(String groupId, String habit) async {
    try {
      await groupsCollection.doc(groupId).update({
        'habits': FieldValue.arrayUnion([habit]),
      });
    } catch (e) {
      print('Error adding habit to group: $e');
      throw e;
    }
  }

  Future<void> updateGroupPicture(String groupId, String imageUrl) async {
    try {
      await groupsCollection.doc(groupId).update({
        'groupPictureUrl': imageUrl,
      });
    } catch (e) {
      print('Error updating group picture URL: $e');
      throw e;
    }
  }

Future<List<String>> getGroupGoals(String groupId) async {
  try {
    DocumentSnapshot doc = await groupsCollection.doc(groupId).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      print('Group goals data: ${data['goals']}');  // Add this line to debug
      return List<String>.from(data['goals'] ?? []);
    } else {
      throw Exception('Group not found');
    }
  } catch (e) {
    print('Error fetching group goals: $e');
    throw e;
  }
}

  
}
