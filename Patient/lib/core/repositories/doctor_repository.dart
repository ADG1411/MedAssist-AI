import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final doctorRepositoryProvider = Provider((ref) => DoctorRepository());

class DoctorRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getDoctors({String filter = 'All'}) async {
    try {
      // Try real doctors from doctors_live view (auto-synced from doctor_profiles)
      var query = _supabase.from('doctors_live').select();
      
      if (filter != 'All') {
        query = query.eq('specialty', filter);
      }
      
      final response = await query;
      final liveDoctors = List<Map<String, dynamic>>.from(response);
      
      if (liveDoctors.isNotEmpty) {
        // Merge with fallback to ensure there's always data to show
        // Real doctors come first, then fallback fills in
        final fallback = filter != 'All'
            ? _fallbackDoctors.where((doc) => doc['specialty'] == filter).toList()
            : _fallbackDoctors;
        
        // Deduplicate by name
        final liveNames = liveDoctors.map((d) => d['name']).toSet();
        final uniqueFallback = fallback.where((d) => !liveNames.contains(d['name'])).toList();
        
        return [...liveDoctors, ...uniqueFallback];
      }
      
      // If doctors_live returns empty, try old doctors table
      var legacyQuery = _supabase.from('doctors').select();
      if (filter != 'All') {
        legacyQuery = legacyQuery.eq('specialty', filter);
      }
      final legacyData = await legacyQuery;
      final legacyList = List<Map<String, dynamic>>.from(legacyData);
      
      if (legacyList.isNotEmpty) return legacyList;
      
      // If both empty, return fallback
      if (filter != 'All') {
        return _fallbackDoctors.where((doc) => doc['specialty'] == filter).toList();
      }
      return _fallbackDoctors;
    } catch (e) {
      // Fallback mock if database isn't ready/seeded yet so the UI doesn't crash during transition
      if (filter != 'All') {
        return _fallbackDoctors.where((doc) => doc['specialty'] == filter).toList();
      }
      return _fallbackDoctors;
    }
  }

  /// Get AI-recommended specialty based on patient's latest triage data
  Future<String?> getAiRecommendedSpecialty() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 'Gastroenterology'; // fallback if not logged in

      // Check latest doctor handoff for specialty recommendation
      final handoff = await _supabase
          .from('doctor_handoffs')
          .select('suggested_specialty')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (handoff != null && handoff['suggested_specialty'] != null) {
        return handoff['suggested_specialty'] as String;
      }

      // Fallback: check latest AI results for doctor_handoff recommendation
      final aiResult = await _supabase
          .from('ai_results')
          .select('conditions, doctor_handoff')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (aiResult != null) {
        // Check doctor_handoff field
        final handoffData = aiResult['doctor_handoff'];
        if (handoffData is Map && handoffData['recommended_specialty'] != null) {
          return handoffData['recommended_specialty'] as String;
        }
        
        // Infer from conditions
        final conditions = aiResult['conditions'];
        if (conditions is List && conditions.isNotEmpty) {
          final topCondition = conditions[0];
          if (topCondition is Map && topCondition['name'] != null) {
            return _inferSpecialty(topCondition['name'] as String);
          }
        }
      }

      return 'Gastroenterology'; // default fallback
    } catch (e) {
      return 'Gastroenterology'; // original fallback
    }
  }

  /// Infer specialty from a condition name
  String _inferSpecialty(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('heart') || lower.contains('cardiac') || lower.contains('cardiovascular') || lower.contains('hypertens')) {
      return 'Cardiology';
    }
    if (lower.contains('gastrit') || lower.contains('gerd') || lower.contains('digest') || lower.contains('liver') || lower.contains('ibs')) {
      return 'Gastroenterology';
    }
    if (lower.contains('skin') || lower.contains('rash') || lower.contains('acne') || lower.contains('dermat')) {
      return 'Dermatology';
    }
    if (lower.contains('bone') || lower.contains('joint') || lower.contains('fracture') || lower.contains('arthrit')) {
      return 'Orthopedic';
    }
    if (lower.contains('brain') || lower.contains('neuro') || lower.contains('migraine') || lower.contains('headache')) {
      return 'Neurology';
    }
    return 'General Practice';
  }

  // Fallback map matching migration script for offline local testing
  final _fallbackDoctors = [
    {
      'id': 'd1',
      'name': 'Dr. Sarah Jenkins',
      'specialty': 'Cardiology',
      'experience': 14,
      'rating': 4.9,
      'consultation_fee': 1200,
      'bio': 'Board-certified cardiologist specializing in coronary artery disease and heart failure management.',
      'available_slots': ['Today, 4:00 PM', 'Tomorrow, 10:00 AM', 'Tomorrow, 2:30 PM']
    },
    {
      'id': 'd2',
      'name': 'Dr. Mark Sloan',
      'specialty': 'Gastroenterology',
      'experience': 8,
      'rating': 4.7,
      'consultation_fee': 850,
      'bio': 'Expert in digestive system disorders including GERD, IBS, and chronic liver diseases.',
      'available_slots': ['Today, 2:00 PM', 'Wednesday, 9:00 AM']
    },
    {
      'id': 'd3',
      'name': 'Dr. Emily Chen',
      'specialty': 'General Practice',
      'experience': 5,
      'rating': 4.5,
      'consultation_fee': 500,
      'bio': 'Family medicine practitioner focusing on holistic preventative care.',
      'available_slots': ['Tomorrow, 11:00 AM', 'Tomorrow, 11:30 AM']
    },
    {
      'id': 'd4',
      'name': 'Dr. Robert King',
      'specialty': 'Dermatology',
      'experience': 12,
      'rating': 4.8,
      'consultation_fee': 1000,
      'bio': 'Specialist in skin conditions, early cancer detection, and advanced cosmetic therapeutics.',
      'available_slots': ['Friday, 3:00 PM']
    },
  ];
}
