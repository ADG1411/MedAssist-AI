import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mock/pharmacy_mock.dart';

final pharmacyProvider = NotifierProvider<PharmacyNotifier, PharmacyState>(PharmacyNotifier.new);

class PharmacyState {
  final List<Map<String, dynamic>> allMedicines;
  final String searchQuery;

  const PharmacyState({
    this.allMedicines = const [],
    this.searchQuery = '',
  });

  List<Map<String, dynamic>> get filteredMedicines {
    if (searchQuery.isEmpty) return allMedicines;
    final q = searchQuery.toLowerCase();
    return allMedicines.where((m) => 
      m['name'].toString().toLowerCase().contains(q) ||
      m['genericName'].toString().toLowerCase().contains(q)
    ).toList();
  }

  PharmacyState copyWith({
    List<Map<String, dynamic>>? allMedicines,
    String? searchQuery,
  }) {
    return PharmacyState(
      allMedicines: allMedicines ?? this.allMedicines,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class PharmacyNotifier extends Notifier<PharmacyState> {
  @override
  PharmacyState build() {
    return PharmacyState(allMedicines: PharmacyMock.medicines);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

