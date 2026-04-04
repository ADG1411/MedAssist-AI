import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../mock/user_mock.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository());

class ProfileRepository {
  bool get useMock => false // dotenv.env['USE_MOCK'] == 'true';

  Future<Map<String, dynamic>> getProfile() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return UserMock.currentUser;
    }
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final data = await SupabaseService.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return data ?? {};
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    await SupabaseService.client
        .from('profiles')
        .update(updates)
        .eq('id', userId);
  }
}

