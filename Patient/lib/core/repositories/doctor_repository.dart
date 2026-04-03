import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final doctorRepositoryProvider = Provider((ref) => DoctorRepository());

class DoctorRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getDoctors({String filter = 'All'}) async {
    try {
      var query = _supabase.from('doctors').select();
      
      if (filter != 'All') {
        query = query.eq('specialty', filter);
      }
      
      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Fallback mock if database isn't ready/seeded yet so the UI doesn't crash during transition
      if (filter != 'All') {
        return _fallbackDoctors.where((doc) => doc['specialty'] == filter).toList();
      }
      return _fallbackDoctors;
    }
  }

  Future<String?> getAiRecommendedSpecialty() async {
    // Ideally this queries an RPC function or an "ai_health_record" table for latest extracted insights.
    await Future.delayed(const Duration(milliseconds: 400));
    return 'Gastroenterology'; 
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
