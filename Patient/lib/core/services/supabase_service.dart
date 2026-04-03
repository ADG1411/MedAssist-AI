import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();
  
  static final SupabaseClient client = Supabase.instance.client;
  
  static bool get isAuthenticated => client.auth.currentSession != null;
  static String? get currentUserId => client.auth.currentUser?.id;
}

