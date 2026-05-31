import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/member_model.dart';
import '../models/models.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  static const String _members = 'members';
  static const String _trainers = 'trainers';
  static const String _payments = 'payments';
  static const String _attendance = 'attendance';
  static const String _plans = 'plans';
  static const String _notifications = 'notifications';

  // ─── AUTH ───────────────────────────────────────────────
  static Future<UserCredential?> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static User? get currentUser => _auth.currentUser;

  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ─── MEMBERS ────────────────────────────────────────────
  static Future<void> addMember(MemberModel member) async {
    await _db.collection(_members).add(member.toMap());
  }

  static Future<void> updateMember(String id, Map<String, dynamic> data) async {
    await _db.collection(_members).doc(id).update(data);
  }

  static Future<void> deleteMember(String id) async {
    await _db.collection(_members).doc(id).delete();
  }

  static Stream<List<MemberModel>> getMembers() {
    return _db
        .collection(_members)
        .orderBy('joiningDate', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => MemberModel.fromMap(d.data(), d.id))
            .toList());
  }

  static Future<MemberModel?> getMemberById(String id) async {
    final doc = await _db.collection(_members).doc(id).get();
    if (doc.exists) return MemberModel.fromMap(doc.data()!, doc.id);
    return null;
  }

  static Future<int> getMembersCount() async {
    final snap = await _db.collection(_members).count().get();
    return snap.count ?? 0;
  }

  static Future<int> getActiveMembersCount() async {
    final snap = await _db
        .collection(_members)
        .where('status', isEqualTo: 'active')
        .count()
        .get();
    return snap.count ?? 0;
  }

  // ─── TRAINERS ───────────────────────────────────────────
  static Future<void> addTrainer(TrainerModel trainer) async {
    await _db.collection(_trainers).add(trainer.toMap());
  }

  static Future<void> updateTrainer(String id, Map<String, dynamic> data) async {
    await _db.collection(_trainers).doc(id).update(data);
  }

  static Future<void> deleteTrainer(String id) async {
    await _db.collection(_trainers).doc(id).delete();
  }

  static Stream<List<TrainerModel>> getTrainers() {
    return _db.collection(_trainers).snapshots().map((s) =>
        s.docs.map((d) => TrainerModel.fromMap(d.data(), d.id)).toList());
  }

  // ─── PAYMENTS ───────────────────────────────────────────
  static Future<void> addPayment(PaymentModel payment) async {
    await _db.collection(_payments).add(payment.toMap());
  }

  static Future<void> updatePayment(String id, Map<String, dynamic> data) async {
    await _db.collection(_payments).doc(id).update(data);
  }

  static Stream<List<PaymentModel>> getPayments() {
    return _db
        .collection(_payments)
        .orderBy('dueDate', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => PaymentModel.fromMap(d.data(), d.id)).toList());
  }

  static Future<double> getTotalRevenue() async {
    final snap = await _db
        .collection(_payments)
        .where('status', isEqualTo: 'paid')
        .get();
    return snap.docs.fold<double>(
        0, (sum, d) => sum + (d.data()['amount'] as num).toDouble());
  }

  // ─── ATTENDANCE ─────────────────────────────────────────
  static Future<void> markAttendance(AttendanceModel att) async {
    await _db.collection(_attendance).add(att.toMap());
  }

  static Future<void> updateAttendance(String id, Map<String, dynamic> data) async {
    await _db.collection(_attendance).doc(id).update(data);
  }

  static Stream<List<AttendanceModel>> getAttendanceByDate(String date) {
    return _db
        .collection(_attendance)
        .where('date', isEqualTo: date)
        .snapshots()
        .map((s) => s.docs
            .map((d) => AttendanceModel.fromMap(d.data(), d.id))
            .toList());
  }

  static Stream<List<AttendanceModel>> getAllAttendance() {
    return _db
        .collection(_attendance)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => AttendanceModel.fromMap(d.data(), d.id))
            .toList());
  }

  // ─── PLANS ──────────────────────────────────────────────
  static Future<void> addPlan(PlanModel plan) async {
    await _db.collection(_plans).add(plan.toMap());
  }

  static Future<void> updatePlan(String id, Map<String, dynamic> data) async {
    await _db.collection(_plans).doc(id).update(data);
  }

  static Future<void> deletePlan(String id) async {
    await _db.collection(_plans).doc(id).delete();
  }

  static Stream<List<PlanModel>> getPlans() {
    return _db
        .collection(_plans)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => PlanModel.fromMap(d.data(), d.id)).toList());
  }

  // ─── NOTIFICATIONS ──────────────────────────────────────
  static Future<void> addNotification(NotificationModel notif) async {
    await _db.collection(_notifications).add(notif.toMap());
  }

  static Stream<List<NotificationModel>> getNotifications() {
    return _db
        .collection(_notifications)
        .orderBy('time', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs
            .map((d) => NotificationModel.fromMap(d.data(), d.id))
            .toList());
  }

  static Future<void> markNotificationRead(String id) async {
    await _db.collection(_notifications).doc(id).update({'isRead': true});
  }

  // ─── SEED DATA ──────────────────────────────────────────
  static Future<void> seedDummyData() async {
    // Check if already seeded
    final existing = await _db.collection(_members).limit(1).get();
    if (existing.docs.isNotEmpty) return;

    // Seed Plans
    final plans = [
      {
        'name': 'Basic Plan',
        'price': 3000,
        'durationMonths': 1,
        'features': ['Gym Access', 'Basic Equipment', 'Locker Room'],
        'accessLevel': 'basic',
      },
      {
        'name': 'Standard Plan',
        'price': 5000,
        'durationMonths': 1,
        'features': [
          'Gym Access',
          'Basic Equipment',
          'Locker Room',
          'Group Classes'
        ],
        'accessLevel': 'standard',
      },
      {
        'name': 'Premium Plan',
        'price': 8000,
        'durationMonths': 1,
        'features': [
          'All Standard Features',
          'Personal Training',
          'Diet Plan',
          'VIP Access'
        ],
        'accessLevel': 'premium',
      },
    ];
    for (final p in plans) {
      await _db.collection(_plans).add(p);
    }

    // Seed Trainers
    final trainers = [
      {
        'name': 'Umer Farooq',
        'specialization': 'Body Building',
        'experience': 5,
        'phone': '0300-1112222',
        'email': 'umer@gym.com',
        'profilePhoto': '',
        'assignedMembers': [],
        'status': 'active',
      },
      {
        'name': 'Zeeshan Ali',
        'specialization': 'Fitness Trainer',
        'experience': 3,
        'phone': '0300-2223333',
        'email': 'zeeshan@gym.com',
        'profilePhoto': '',
        'assignedMembers': [],
        'status': 'active',
      },
      {
        'name': 'Rizwan Ahmed',
        'specialization': 'Strength Trainer',
        'experience': 4,
        'phone': '0300-3334444',
        'email': 'rizwan@gym.com',
        'profilePhoto': '',
        'assignedMembers': [],
        'status': 'active',
      },
    ];
    for (final t in trainers) {
      await _db.collection(_trainers).add(t);
    }

    // Seed Members
    final members = [
      {
        'fullName': 'Ali Raza',
        'email': 'ali.raza@email.com',
        'phone': '0300-1234567',
        'cnic': '12345-1234567-1',
        'address': 'Lahore, Pakistan',
        'gender': 'Male',
        'dateOfBirth': '1995-05-10',
        'weight': 75.0,
        'height': 5.8,
        'medicalNotes': 'No any medical issue',
        'joiningDate': '2024-01-01',
        'membershipPlan': 'Premium Plan',
        'trainerId': '',
        'trainerName': 'Umer Farooq',
        'profilePhoto': '',
        'status': 'active',
        'memberId': '#MEM1001',
      },
      {
        'fullName': 'Usman Ahmed',
        'email': 'usman@email.com',
        'phone': '0300-2954121',
        'cnic': '12345-2345678-1',
        'address': 'Karachi, Pakistan',
        'gender': 'Male',
        'dateOfBirth': '1998-08-15',
        'weight': 82.0,
        'height': 6.0,
        'medicalNotes': '',
        'joiningDate': '2024-01-15',
        'membershipPlan': 'Standard Plan',
        'trainerId': '',
        'trainerName': 'Zeeshan Ali',
        'profilePhoto': '',
        'status': 'active',
        'memberId': '#MEM1002',
      },
      {
        'fullName': 'Bilal Khan',
        'email': 'bilal@email.com',
        'phone': '0300-1122334',
        'cnic': '12345-3456789-1',
        'address': 'Islamabad, Pakistan',
        'gender': 'Male',
        'dateOfBirth': '2000-03-20',
        'weight': 70.0,
        'height': 5.9,
        'medicalNotes': '',
        'joiningDate': '2024-02-01',
        'membershipPlan': 'Basic Plan',
        'trainerId': '',
        'trainerName': 'Rizwan Ahmed',
        'profilePhoto': '',
        'status': 'active',
        'memberId': '#MEM1003',
      },
      {
        'fullName': 'Hamza Shahid',
        'email': 'hamza@email.com',
        'phone': '0300-2602778',
        'cnic': '12345-4567890-1',
        'address': 'Lahore, Pakistan',
        'gender': 'Male',
        'dateOfBirth': '1997-11-05',
        'weight': 90.0,
        'height': 6.2,
        'medicalNotes': '',
        'joiningDate': '2023-12-01',
        'membershipPlan': 'Premium Plan',
        'trainerId': '',
        'trainerName': 'Umer Farooq',
        'profilePhoto': '',
        'status': 'expired',
        'memberId': '#MEM1004',
      },
      {
        'fullName': 'Sara Khan',
        'email': 'sara@email.com',
        'phone': '0300-6677988',
        'cnic': '12345-5678901-1',
        'address': 'Karachi, Pakistan',
        'gender': 'Female',
        'dateOfBirth': '2001-07-12',
        'weight': 55.0,
        'height': 5.4,
        'medicalNotes': '',
        'joiningDate': '2024-01-20',
        'membershipPlan': 'Standard Plan',
        'trainerId': '',
        'trainerName': 'Zeeshan Ali',
        'profilePhoto': '',
        'status': 'active',
        'memberId': '#MEM1005',
      },
      {
        'fullName': 'Ayesha Malik',
        'email': 'ayesha@email.com',
        'phone': '0300-1060778',
        'cnic': '12345-6789012-1',
        'address': 'Lahore, Pakistan',
        'gender': 'Female',
        'dateOfBirth': '1999-09-25',
        'weight': 60.0,
        'height': 5.5,
        'medicalNotes': '',
        'joiningDate': '2023-11-01',
        'membershipPlan': 'Basic Plan',
        'trainerId': '',
        'trainerName': '',
        'profilePhoto': '',
        'status': 'expired',
        'memberId': '#MEM1006',
      },
    ];
    for (final m in members) {
      await _db.collection(_members).add(m);
    }

    // Seed Payments
    final payments = [
      {
        'memberId': '',
        'memberName': 'Ali Raza',
        'amount': 8000,
        'planName': 'Premium Plan',
        'paymentDate': '2024-05-01',
        'dueDate': '2024-05-01',
        'status': 'paid',
        'month': 'May 2024',
      },
      {
        'memberId': '',
        'memberName': 'Usman Ahmed',
        'amount': 5000,
        'planName': 'Standard Plan',
        'paymentDate': '2024-05-01',
        'dueDate': '2024-05-01',
        'status': 'paid',
        'month': 'May 2024',
      },
      {
        'memberId': '',
        'memberName': 'Bilal Khan',
        'amount': 3000,
        'planName': 'Basic Plan',
        'paymentDate': '',
        'dueDate': '2024-05-01',
        'status': 'unpaid',
        'month': 'May 2024',
      },
      {
        'memberId': '',
        'memberName': 'Hamza Shahid',
        'amount': 8000,
        'planName': 'Premium Plan',
        'paymentDate': '',
        'dueDate': '2024-05-01',
        'status': 'unpaid',
        'month': 'May 2024',
      },
      {
        'memberId': '',
        'memberName': 'Sara Khan',
        'amount': 5000,
        'planName': 'Standard Plan',
        'paymentDate': '2024-05-01',
        'dueDate': '2024-05-01',
        'status': 'paid',
        'month': 'May 2024',
      },
    ];
    for (final p in payments) {
      await _db.collection(_payments).add(p);
    }
  }
}
