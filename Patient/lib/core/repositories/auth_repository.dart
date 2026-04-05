import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/supabase_service.dart';

class AuthRepository {
  bool get useMock => false; // dotenv.env['USE_MOCK'] == 'true';

  Future<bool> signInWithEmail(String email, String password) async {
    if (useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }
    
    final res = await SupabaseService.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return res.user != null;
  }

  Future<bool> signUpWithEmail(
    String email, 
    String password, 
    Map<String, dynamic> metadata
  ) async {
    if (useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    final res = await SupabaseService.client.auth.signUp(
      email: email,
      password: password,
      data: metadata, // Maps natively to raw_user_meta_data
    );
    return res.user != null;
  }

  Future<void> logout() async {
    if (useMock) return;
    await SupabaseService.client.auth.signOut();
  }
}

