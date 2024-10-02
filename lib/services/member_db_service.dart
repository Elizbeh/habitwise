import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitwise/models/member.dart';

class MemberDBService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  
  Future<List<Member>> getGroupMembers(String groupId) async {
    final snapshot = await _db.collection('groups').doc(groupId).collection('members').get();
    return snapshot.docs.map((doc) => Member.fromMap(doc.data())).toList();
  }

  Future<void> addMemberToGroup(String groupId, Member member) async {
    try {
      DocumentReference groupDoc = _db.collection('groups').doc(groupId);
      Map<String, dynamic> memberData = member.toMap();
      await groupDoc.collection('members').doc(member.id).set(memberData);
    } catch (e) {
      print('Error adding member to group: $e');
      throw e;
    }
  }

  Future<void> removeMemberFromGroup(String groupId, String memberId) async {
    try {
      DocumentReference groupDoc = _db.collection('groups').doc(groupId);
      await groupDoc.collection('members').doc(memberId).delete();
    } catch (e) {
      print('Error removing member from group: $e');
      throw e;
    }
  }

  Future<void> updateMember(Member member) async {
    try {
      DocumentReference memberDoc = _db.collection('members').doc(member.id);
      await memberDoc.update(member.toMap());
    } catch (e) {
      print('Error updating member: $e');
      throw e;
    }
  }

  Future<Member> getMemberById(String memberId) async {
    DocumentSnapshot doc = await _db.collection('members').doc(memberId).get();
    if (doc.exists) {
      return Member.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      throw Exception('Member not found');
    }
  }
}
