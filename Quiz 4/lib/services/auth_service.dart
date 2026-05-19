import 'package:supabase_flutter/supabase_flutter.dart';

/// AuthService wraps all Supabase authentication calls in one place.
/// Every method returns an [AuthResult] so screens can check
/// success / failure without dealing with exceptions directly.
class AuthService {
  // Singleton pattern – a single instance reused everywhere
  AuthService._internal();
  static final AuthService instance = AuthService._internal();
  factory AuthService() => instance;

  // Reference to the Supabase client
  final SupabaseClient _client = Supabase.instance.client;

  // ──────────────────────────────────────────
  //  SIGN UP
  // ──────────────────────────────────────────
  /// Registers a new user with [email] and [password].
  /// Supabase sends a confirmation e-mail automatically
  /// (if enabled in the dashboard).
  Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return AuthResult.success(
          message:
              'Registration successful! Please check your email to confirm your account.',
          user: response.user,
        );
      } else {
        return AuthResult.failure(
          message: 'Registration failed. Please try again.',
        );
      }
    } on AuthException catch (e) {
      // Supabase-specific errors (e.g. "User already registered")
      return AuthResult.failure(message: e.message);
    } catch (e) {
      return AuthResult.failure(message: 'Unexpected error: ${e.toString()}');
    }
  }

  // ──────────────────────────────────────────
  //  SIGN IN
  // ──────────────────────────────────────────
  /// Signs in an existing user with [email] and [password].
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response =
          await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return AuthResult.success(
          message: 'Login successful! Welcome back.',
          user: response.user,
        );
      } else {
        return AuthResult.failure(
          message: 'Login failed. Please check your credentials.',
        );
      }
    } on AuthException catch (e) {
      return AuthResult.failure(message: e.message);
    } catch (e) {
      return AuthResult.failure(message: 'Unexpected error: ${e.toString()}');
    }
  }

  // ──────────────────────────────────────────
  //  SIGN OUT
  // ──────────────────────────────────────────
  /// Signs the current user out and clears the local session.
  Future<AuthResult> signOut() async {
    try {
      await _client.auth.signOut();
      return AuthResult.success(message: 'Logged out successfully.');
    } on AuthException catch (e) {
      return AuthResult.failure(message: e.message);
    } catch (e) {
      return AuthResult.failure(message: 'Logout error: ${e.toString()}');
    }
  }

  // ──────────────────────────────────────────
  //  CURRENT USER
  // ──────────────────────────────────────────
  /// Returns the currently authenticated [User], or null if not logged in.
  User? get currentUser => _client.auth.currentUser;

  /// Returns true if a user is currently signed in.
  bool get isLoggedIn => currentUser != null;
}

// ──────────────────────────────────────────────
//  AuthResult  – a simple result wrapper
// ──────────────────────────────────────────────
class AuthResult {
  final bool success;
  final String message;
  final User? user;

  const AuthResult._({
    required this.success,
    required this.message,
    this.user,
  });

  factory AuthResult.success({required String message, User? user}) =>
      AuthResult._(success: true, message: message, user: user);

  factory AuthResult.failure({required String message}) =>
      AuthResult._(success: false, message: message);
}
