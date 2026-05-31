// Trainer Model
class TrainerModel {
  final String id;
  final String name;
  final String specialization;
  final int experience;
  final String phone;
  final String email;
  final String profilePhoto;
  final List<String> assignedMembers;
  final String status;

  TrainerModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.phone,
    required this.email,
    required this.profilePhoto,
    required this.assignedMembers,
    required this.status,
  });

  factory TrainerModel.fromMap(Map<String, dynamic> map, String id) {
    return TrainerModel(
      id: id,
      name: map['name'] ?? '',
      specialization: map['specialization'] ?? '',
      experience: map['experience'] ?? 0,
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
      assignedMembers: List<String>.from(map['assignedMembers'] ?? []),
      status: map['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialization': specialization,
      'experience': experience,
      'phone': phone,
      'email': email,
      'profilePhoto': profilePhoto,
      'assignedMembers': assignedMembers,
      'status': status,
    };
  }
}

// Payment Model
class PaymentModel {
  final String id;
  final String memberId;
  final String memberName;
  final double amount;
  final String planName;
  final String paymentDate;
  final String dueDate;
  final String status; // paid, unpaid, overdue
  final String month;

  PaymentModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.planName,
    required this.paymentDate,
    required this.dueDate,
    required this.status,
    required this.month,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map, String id) {
    return PaymentModel(
      id: id,
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      planName: map['planName'] ?? '',
      paymentDate: map['paymentDate'] ?? '',
      dueDate: map['dueDate'] ?? '',
      status: map['status'] ?? 'unpaid',
      month: map['month'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'amount': amount,
      'planName': planName,
      'paymentDate': paymentDate,
      'dueDate': dueDate,
      'status': status,
      'month': month,
    };
  }
}

// Attendance Model
class AttendanceModel {
  final String id;
  final String memberId;
  final String memberName;
  final String date;
  final String checkIn;
  final String checkOut;
  final String status; // present, absent

  AttendanceModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceModel(
      id: id,
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      date: map['date'] ?? '',
      checkIn: map['checkIn'] ?? '',
      checkOut: map['checkOut'] ?? '',
      status: map['status'] ?? 'present',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'date': date,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'status': status,
    };
  }
}

// Membership Plan Model
class PlanModel {
  final String id;
  final String name;
  final double price;
  final int durationMonths;
  final List<String> features;
  final String accessLevel;

  PlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMonths,
    required this.features,
    required this.accessLevel,
  });

  factory PlanModel.fromMap(Map<String, dynamic> map, String id) {
    return PlanModel(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      durationMonths: map['durationMonths'] ?? 1,
      features: List<String>.from(map['features'] ?? []),
      accessLevel: map['accessLevel'] ?? 'basic',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'durationMonths': durationMonths,
      'features': features,
      'accessLevel': accessLevel,
    };
  }
}

// Notification Model
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final String time;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.time,
    this.isRead = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'info',
      time: map['time'] ?? '',
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'time': time,
      'isRead': isRead,
    };
  }
}
