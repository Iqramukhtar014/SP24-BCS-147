class MemberModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String cnic;
  final String address;
  final String gender;
  final String dateOfBirth;
  final double weight;
  final double height;
  final String medicalNotes;
  final String joiningDate;
  final String membershipPlan;
  final String trainerId;
  final String trainerName;
  final String profilePhoto;
  final String status; // active, expired, inactive
  final String memberId;

  MemberModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.cnic,
    required this.address,
    required this.gender,
    required this.dateOfBirth,
    required this.weight,
    required this.height,
    required this.medicalNotes,
    required this.joiningDate,
    required this.membershipPlan,
    required this.trainerId,
    required this.trainerName,
    required this.profilePhoto,
    required this.status,
    required this.memberId,
  });

  factory MemberModel.fromMap(Map<String, dynamic> map, String id) {
    return MemberModel(
      id: id,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      cnic: map['cnic'] ?? '',
      address: map['address'] ?? '',
      gender: map['gender'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      weight: (map['weight'] ?? 0).toDouble(),
      height: (map['height'] ?? 0).toDouble(),
      medicalNotes: map['medicalNotes'] ?? '',
      joiningDate: map['joiningDate'] ?? '',
      membershipPlan: map['membershipPlan'] ?? '',
      trainerId: map['trainerId'] ?? '',
      trainerName: map['trainerName'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
      status: map['status'] ?? 'active',
      memberId: map['memberId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'cnic': cnic,
      'address': address,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'weight': weight,
      'height': height,
      'medicalNotes': medicalNotes,
      'joiningDate': joiningDate,
      'membershipPlan': membershipPlan,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'profilePhoto': profilePhoto,
      'status': status,
      'memberId': memberId,
    };
  }

  MemberModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? status,
    String? membershipPlan,
    String? trainerName,
    String? trainerId,
  }) {
    return MemberModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      cnic: cnic,
      address: address,
      gender: gender,
      dateOfBirth: dateOfBirth,
      weight: weight,
      height: height,
      medicalNotes: medicalNotes,
      joiningDate: joiningDate,
      membershipPlan: membershipPlan ?? this.membershipPlan,
      trainerId: trainerId ?? this.trainerId,
      trainerName: trainerName ?? this.trainerName,
      profilePhoto: profilePhoto,
      status: status ?? this.status,
      memberId: memberId,
    );
  }
}
