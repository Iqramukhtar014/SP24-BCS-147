// lib/services/submission_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/submission_model.dart';
import '../utils/app_constants.dart';

class SubmissionService {
  static final SubmissionService _instance = SubmissionService._internal();
  factory SubmissionService() => _instance;
  SubmissionService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // CREATE
  // ---------------------------------------------------------------------------
  /// Inserts a new submission into Supabase and returns the created record.
  Future<Submission> createSubmission(Submission submission) async {
    try {
      final response = await _client
          .from(AppConstants.submissionsTable)
          .insert(submission.toMap())
          .select()
          .single();

      return Submission.fromMap(response);
    } on PostgrestException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Failed to create submission: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // READ ALL
  // ---------------------------------------------------------------------------
  /// Fetches all submissions ordered by id descending (newest first).
  Future<List<Submission>> getAllSubmissions() async {
    try {
      final response = await _client
          .from(AppConstants.submissionsTable)
          .select()
          .order('id', ascending: false);

      return (response as List<dynamic>)
          .map((row) => Submission.fromMap(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Failed to fetch submissions: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // READ SINGLE
  // ---------------------------------------------------------------------------
  /// Fetches a single submission by ID.
  Future<Submission> getSubmissionById(int id) async {
    try {
      final response = await _client
          .from(AppConstants.submissionsTable)
          .select()
          .eq('id', id)
          .single();

      return Submission.fromMap(response);
    } on PostgrestException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Failed to fetch submission: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE
  // ---------------------------------------------------------------------------
  /// Updates an existing submission and returns the updated record.
  Future<Submission> updateSubmission(Submission submission) async {
    if (submission.id == null) {
      throw Exception('Cannot update a submission without an ID');
    }
    try {
      final response = await _client
          .from(AppConstants.submissionsTable)
          .update(submission.toMap())
          .eq('id', submission.id!)
          .select()
          .single();

      return Submission.fromMap(response);
    } on PostgrestException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Failed to update submission: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------------------------
  /// Deletes a submission by ID.
  Future<void> deleteSubmission(int id) async {
    try {
      await _client
          .from(AppConstants.submissionsTable)
          .delete()
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Failed to delete submission: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------------------------
  /// Searches submissions by name, email, or phone (client-side filter).
  Future<List<Submission>> searchSubmissions(String query) async {
    try {
      final all = await getAllSubmissions();
      if (query.trim().isEmpty) return all;
      final lower = query.toLowerCase();
      return all.where((s) {
        return s.fullName.toLowerCase().contains(lower) ||
            s.email.toLowerCase().contains(lower) ||
            s.phone.contains(lower);
      }).toList();
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // HELPER
  // ---------------------------------------------------------------------------
  Exception _handleError(PostgrestException e) {
    switch (e.code) {
      case '23505':
        return Exception('A record with this information already exists.');
      case '23502':
        return Exception('Please fill in all required fields.');
      case '42501':
        return Exception('You do not have permission to perform this action.');
      default:
        return Exception(e.message.isNotEmpty ? e.message : 'Database error occurred.');
    }
  }
}
