import 'package:flutter/material.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/dashboard/home_screen.dart';
import '../screens/members/member_list_screen.dart';
import '../screens/members/add_member_screen.dart';
import '../screens/members/member_details_screen.dart';
import '../screens/attendance/attendance_screen.dart';
import '../screens/payments/payments_screen.dart';
import '../screens/payments/plans_screen.dart';
import '../screens/payments/payment_reminder_screen.dart';
import '../screens/trainers/trainer_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../models/member_model.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/splash':
        return _page(const SplashScreen());

      case '/login':
        return _page(const LoginScreen());

      case '/forgot-password':
        return _page(const ForgotPasswordScreen());

      case '/dashboard':
        return _page(const HomeScreen());

      case '/members':
        return _page(const MemberListScreen());

      case '/add-member':
        // Can receive a MemberModel for editing or {'edit': MemberModel}
        final args = settings.arguments;
        if (args is MemberModel) {
          return _page(AddMemberScreen(member: args));
        }
        if (args is Map && args['edit'] is MemberModel) {
          return _page(AddMemberScreen(member: args['edit'] as MemberModel));
        }
        return _page(const AddMemberScreen());

      case '/member-details':
        final member = settings.arguments as MemberModel;
        return _page(MemberDetailsScreen(member: member));

      case '/attendance':
        return _page(const AttendanceScreen());

      case '/payments':
        return _page(const PaymentsScreen());

      case '/plans':
        return _page(const PlansScreen());

      case '/payment-reminders':
        return _page(const PaymentReminderScreen());

      case '/trainers':
        return _page(const TrainerScreen());

      case '/reports':
        return _page(const ReportsScreen());

      case '/notifications':
        return _page(const NotificationsScreen());

      case '/settings':
        return _page(const SettingsScreen());

      default:
        return _page(const Scaffold(
          body: Center(child: Text('Page not found')),
        ));
    }
  }

  static PageRoute _page(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => widget,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
