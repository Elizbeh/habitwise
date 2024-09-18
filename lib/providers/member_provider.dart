import 'package:flutter/material.dart';
import 'package:habitwise/models/member.dart';
import '../services/member_db_service.dart';

class MemberProvider extends ChangeNotifier {
  final MemberDBService _memberDBService = MemberDBService();
  List<Member> _members = [];

  List<Member> get members => _members;

  Future<void> fetchMembers(String groupId) async {
    try {
      List<Member> fetchedMembers = await _memberDBService.getGroupMembers(groupId);
      _members = fetchedMembers;
      notifyListeners();
    } catch (e) {
      print('Error fetching members: $e');
    }
  }

  Future<void> addMember(String groupId, Member member) async {
    try {
      await _memberDBService.addMemberToGroup(groupId, member);
      _members.add(member);  // Add locally to maintain state
      notifyListeners();
    } catch (e) {
      print('Error adding member: $e');
    }
  }

  Future<void> removeMember(String groupId, String memberId) async {
    try {
      await _memberDBService.removeMemberFromGroup(groupId, memberId);
      _members.removeWhere((member) => member.id == memberId); // Remove locally
      notifyListeners();
    } catch (e) {
      print('Error removing member: $e');
    }
  }

  Future<void> updateMember(Member member) async {
    try {
      // Assuming there is an update method in MemberDBService
      await _memberDBService.updateMember(member);
      // Update locally if needed
      notifyListeners();
    } catch (e) {
      print('Error updating member: $e');
    }
  }
}
