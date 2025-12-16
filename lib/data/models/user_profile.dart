class UserProfile {
  final int? id; // SQLite usually uses int for primary key
  final String name;
  final String email;
  final String? profileImage;
  final String? password;

  const UserProfile({
    this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.password,
  });

  // Default empty/placeholder user
  static const empty = UserProfile(name: 'User', email: 'user@example.com');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'password': password,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      profileImage: map['profileImage'] as String?,
      password: map['password'] as String?,
    );
  }

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? profileImage,
    String? password,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      password: password ?? this.password,
    );
  }
}
