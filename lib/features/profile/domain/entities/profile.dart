// Domain entity representing a member's profile in EmpowerHER.

class Profile {
  final String uid;
  final String name;
  final String email;
  final String? headline;
  final String? bio;
  final String? location;
  final String? phone;
  final String? photoUrl;
  final List<String> skills;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.uid,
    required this.name,
    required this.email,
    this.headline,
    this.bio,
    this.location,
    this.phone,
    this.photoUrl,
    this.skills = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Starter profile for a new user, from the auth uid/name/email.
  factory Profile.initial({
    required String uid,
    required String name,
    required String email,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return Profile(
      uid: uid,
      name: name,
      email: email,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  Profile copyWith({
    String? name,
    String? email,
    String? headline,
    String? bio,
    String? location,
    String? phone,
    String? photoUrl,
    List<String>? skills,
    DateTime? updatedAt,
  }) {
    return Profile(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      headline: headline ?? this.headline,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      skills: skills ?? this.skills,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Profile &&
        other.uid == uid &&
        other.name == name &&
        other.email == email &&
        other.headline == headline &&
        other.bio == bio &&
        other.location == location &&
        other.phone == phone &&
        other.photoUrl == photoUrl &&
        _listEquals(other.skills, skills) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      uid,
      name,
      email,
      headline,
      bio,
      location,
      phone,
      photoUrl,
      Object.hashAll(skills),
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() => 'Profile(uid: $uid, name: $name, email: $email)';
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
