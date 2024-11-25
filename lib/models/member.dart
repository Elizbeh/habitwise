enum MemberRole { admin, member }

class Member {
  final String id;
  final String name;
  final MemberRole role; // Keep this as MemberRole type
  final String email;
  final String? profilePictureUrl;
  final DateTime? joinedDate; // New field

  Member({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.profilePictureUrl,
    this.joinedDate,
  });

  factory Member.fromMap(Map<String, dynamic> data) {
    return Member(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      role: _stringToMemberRole(data['role']), // Convert from string to enum
      email: data['email'] ?? '',
      profilePictureUrl: data['profilePictureUrl'],
      joinedDate: data['joinedDate'] != null 
          ? DateTime.parse(data['joinedDate']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role.toString().split('.').last, // Store as string without the enum prefix
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'joinedDate': joinedDate?.toIso8601String(), // Format joinedDate
    };
  }

  // Helper method to convert string to MemberRole
  static MemberRole _stringToMemberRole(String roleString) {
    return MemberRole.values.firstWhere(
      (e) => e.toString().split('.').last == roleString,
      orElse: () => MemberRole.member, // Default to member if no match found
    );
  }

  bool get isAdmin => role == MemberRole.admin; 

}
