import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final doctorsProvider = NotifierProvider<DoctorsNotifier, DoctorsState>(DoctorsNotifier.new);

class DoctorsState {
  final List<Map<String, dynamic>> allDoctors;
  final String activeSpecialty;
  final String searchQuery;

  const DoctorsState({
    this.allDoctors = const [],
    this.activeSpecialty = 'All',
    this.searchQuery = '',
  });

  List<Map<String, dynamic>> get filteredDoctors {
    var result = allDoctors;
    
    if (activeSpecialty != 'All') {
      result = result.where((d) => d['specialty'] == activeSpecialty).toList();
    }
    
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((d) => 
        d['name'].toString().toLowerCase().contains(q) || 
        d['specialty'].toString().toLowerCase().contains(q)
      ).toList();
    }
    
    return result;
  }

  DoctorsState copyWith({
    List<Map<String, dynamic>>? allDoctors,
    String? activeSpecialty,
    String? searchQuery,
  }) {
    return DoctorsState(
      allDoctors: allDoctors ?? this.allDoctors,
      activeSpecialty: activeSpecialty ?? this.activeSpecialty,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class DoctorsNotifier extends Notifier<DoctorsState> {
  @override
  DoctorsState build() {
    _loadDoctors();
    return const DoctorsState();
  }

  Future<void> _loadDoctors() async {
    try {
      final data = await Supabase.instance.client.from('doctors').select();
      state = state.copyWith(allDoctors: List<Map<String, dynamic>>.from(data));
    } catch (e) {
      // Fallback if DB not ready
      state = state.copyWith(allDoctors: _fallback);
    }
  }

  void setSpecialty(String specialty) {
    state = state.copyWith(activeSpecialty: specialty);
  }
  
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  static const _fallback = [
    {'id': 'd1', 'name': 'Dr. Sarah Jenkins', 'specialty': 'Cardiology', 'experience': 14, 'rating': 4.9, 'consultation_fee': 1200, 'bio': 'Board-certified cardiologist.', 'available_slots': ['Today, 4:00 PM']},
    {'id': 'd2', 'name': 'Dr. Mark Sloan', 'specialty': 'Gastroenterology', 'experience': 8, 'rating': 4.7, 'consultation_fee': 850, 'bio': 'Expert in digestive disorders.', 'available_slots': ['Today, 2:00 PM']},
  ];
}
