import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isEmailVerified => _user?.emailConfirmedAt != null;

  bool get isAdmin => _role == 'admin';
  String _role = 'user';

  AuthProvider() {
    _user = _supabase.auth.currentUser;
    _fetchUserRole();
    _supabase.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;

      if (_user != null) {
        _fetchUserRole();
      } else {
        _role = 'user';
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserRole() async {
    if (_user == null) return;
    try {
      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', _user!.id)
          .single();
      _role = response['role'] as String? ?? 'user';
    } catch (e) {
      // Profile might not exist yet or error, default to user
      _role = 'user';
    }
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _supabase.auth.signUp(email: email, password: password);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _role = 'user';
    notifyListeners();
  }

  Future<void> refreshSession() async {
    try {
      final response = await _supabase.auth.refreshSession();
      _user = response.session?.user ?? _supabase.auth.currentUser;
      if (_user != null) await _fetchUserRole();
      notifyListeners();
    } catch (e) {
      _user = _supabase.auth.currentUser;
      notifyListeners();
    }
  }
}
