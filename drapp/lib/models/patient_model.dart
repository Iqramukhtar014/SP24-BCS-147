class Patient {
  final int? id;
  final String name;
  final String age;
  final String gender;
  final String disease;
  final String phone;
  final String address;
  final String? imagePath;

  Patient({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.disease,
    required this.phone,
    required this.address,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'disease': disease,
      'phone': phone,
      'address': address,
      'imagePath': imagePath,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      gender: map['gender'],
      disease: map['disease'],
      phone: map['phone'],
      address: map['address'],
      imagePath: map['imagePath'],
    );
  }
}