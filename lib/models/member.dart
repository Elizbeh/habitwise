class Member {
  final String id;
  final String name;
  final String email;
  final String? profilePictureUrl;
  final DateTime? joinedDate; // New field

  Member({
    required this.id,
    required this.name,
    required this.email,
    this.profilePictureUrl,
    this.joinedDate, // Include in constructor
  });

  factory Member.fromMap(Map<String, dynamic> data) {
    return Member(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePictureUrl: data['profilePictureUrl'],
      joinedDate: data['joinedDate'] != null ? DateTime.parse(data['joinDate']) : null, // Parse joinDate
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'joinedDate': joinedDate?.toIso8601String(), // Format joinDate
    };
  }
}
