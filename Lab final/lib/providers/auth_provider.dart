import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _rememberMe = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _user = FirebaseService.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    _rememberMe = prefs.getBool('rememberMe') ?? false;
    notifyListeners();
  }

  Future<bool> login(String email, String password, bool rememberMe) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await FirebaseService.login(email, password);
      if (cred != null) {
        _user = cred.user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('rememberMe', rememberMe);
        if (rememberMe) {
          await prefs.setString('savedEmail', email);
        }
        // Seed dummy data on first login
        await FirebaseService.seedDummyData();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _error = _authErrorMessage(e.code);
    } catch (e) {
      _error = 'An error occurred. Please try again.';
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await FirebaseService.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await FirebaseService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to send reset email.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Login failed. Please check your credentials.';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
