import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/mock/user_mock.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authProvider = NotifierProvider<AuthNotifier, Map<String, dynamic>?>(AuthNotifier.new);

class AuthNotifier extends Notifier<Map<String, dynamic>?> {
  StreamSubscription<AuthState>? _authStateSubscription;
  late final AuthRepository _repo;

  @override
  Map<String, dynamic>? build() {
    _repo = ref.read(authRepositoryProvider);
    
    if (_repo.useMock) {
      return null;
    }

    // Native session stream!
    _authStateSubscription = SupabaseService.client.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      if (user != null) {
        state = {
          'id': user.id,
          'email': user.email,
          'name': user.userMetadata?['full_name'] ?? 'User',
        };
      } else {
        state = null;
      }
    });

    ref.onDispose(() => _authStateSubscription?.cancel());

    return null;
  }

  Future<bool> login(String email, String password) async {
    final success = await _repo.signInWithEmail(email, password);
    if (_repo.useMock && success) {
      state = UserMock.currentUser;
    }
    return success;
  }

  Future<bool> signUp(String email, String password, Map<String, dynamic> metadata) async {
    final success = await _repo.signUpWithEmail(email, password, metadata);
    if (_repo.useMock && success) {
      state = {
        'id': 'mocked_uuid',
        'email': email,
        'name': metadata['full_name'],
      };
    }
    return success;
  }

  Future<void> logout() async {
    await _repo.logout();
    if (_repo.useMock) {
      state = null;
    }
  }
}

