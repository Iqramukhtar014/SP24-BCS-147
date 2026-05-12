// lib/models/submission_model.dart

class Submission {
  final int? id;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String gender;

  const Submission({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.gender,
  });

  /// Creates a Submission from a Supabase row (Map)
  factory Submission.fromMap(Map<String, dynamic> map) {
    return Submission(
      id: map['id'] as int?,
      fullName: map['full_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      gender: map['gender'] as String? ?? '',
    );
  }

  /// Converts Submission to a Map for Supabase insert/update
  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'gender': gender,
    };
  }

  /// Creates a copy of Submission with optional overrides
  Submission copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? gender,
  }) {
    return Submission(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
    );
  }

  /// Returns initials from the full name (e.g. "Ahmad Raza" → "AR")
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  String toString() {
    return 'Submission(id: $id, fullName: $fullName, email: $email, '
        'phone: $phone, address: $address, gender: $gender)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Submission && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
