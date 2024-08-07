import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/group.dart';

class GroupDBService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get groupsCollection => _firestore.collection('groups');

  // Create a new group and return its ID
  Future<String> createGroup(HabitWiseGroup group) async {
    DocumentReference docRef = await groupsCollection.add(group.toMap());
    await docRef.update({'groupId': docRef.id});
    return docRef.id;
  }

  // Fetch all groups
  /*Future<List<HabitWiseGroup>> getAllGroups() async {
  try {
    QuerySnapshot querySnapshot = await groupsCollection.get();
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
}*/
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


  // Get group details by ID
  Future<HabitWiseGroup> getGroupById(String groupId) async {
    DocumentSnapshot doc = await groupsCollection.doc(groupId).get();
    if (doc.exists) {
      return HabitWiseGroup.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      throw Exception('Group not found');
    }
  }

  // Update an existing group
  Future<void> updateGroup(HabitWiseGroup group) async {
    await groupsCollection.doc(group.groupId).update(group.toMap());
  }

  // Join a group
  Future<void> joinGroup(String groupId, String userId) async {
    DocumentReference groupDoc = groupsCollection.doc(groupId);
    await groupDoc.update({
      'members': FieldValue.arrayUnion([userId])
    });
  }

  // Leave a group
  Future<void> leaveGroup(String groupId, String userId) async {
    DocumentReference groupDoc = groupsCollection.doc(groupId);
    await groupDoc.update({
      'members': FieldValue.arrayRemove([userId])
    });
  }

  // Delete a group
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
  } on FirebaseException catch (e) {
    print('FirebaseException while adding goal to group: ${e.message}');
    throw e;
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

  // Update group picture URL
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
}
