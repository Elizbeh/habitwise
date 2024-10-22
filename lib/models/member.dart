enum MemberRole { admin, member, moderator }


class Member {
  final String id;
  final String name;
  final MemberRole role;
  final String email;
  final String? profilePictureUrl;
  final DateTime? joinedDate; // New field

  Member({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.profilePictureUrl,
    this.joinedDate, // Include in constructor
  });

  factory Member.fromMap(Map<String, dynamic> data) {
  return Member(
    id: data['id'] ?? '',
    name: data['name'] ?? '',
    role: MemberRole.values.firstWhere((e) => e.toString() == data['role'], orElse: () => MemberRole.member), // default role
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
      'role': role.toString(),
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'joinedDate': joinedDate?.toIso8601String(), // Format joinDate
    };
  }


  bool get isAdmin => role == MemberRole.admin; 
}
