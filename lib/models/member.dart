class Member {
  final String id;
  final String name;
  final String email;
  final String? profilePictureUrl;

  Member({
    required this.id,
    required this.name,
    required this.email,
    this.profilePictureUrl,
  });

  factory Member.fromMap(Map<String, dynamic> data) {
    return Member(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePictureUrl: data['profilePictureUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}
