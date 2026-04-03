import 'package:flutter_riverpod/flutter_riverpod.dart';

final symptomCheckProvider = NotifierProvider<SymptomCheckNotifier, SymptomCheckState>(SymptomCheckNotifier.new);

class SymptomCheckState {
  final String? selectedRegion;
  final Set<String> selectedSymptoms;
  final bool isFrontView;
  final String additionalNotes;
  final String duration;

  const SymptomCheckState({
    this.selectedRegion,
    this.selectedSymptoms = const {},
    this.isFrontView = true,
    this.additionalNotes = '',
    this.duration = '',
  });

  SymptomCheckState copyWith({
    String? selectedRegion,
    Set<String>? selectedSymptoms,
    bool? isFrontView,
    String? additionalNotes,
    String? duration,
  }) {
    return SymptomCheckState(
      selectedRegion: selectedRegion ?? this.selectedRegion,
      selectedSymptoms: selectedSymptoms ?? this.selectedSymptoms,
      isFrontView: isFrontView ?? this.isFrontView,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      duration: duration ?? this.duration,
    );
  }
  
  bool get canContinue => selectedRegion != null && selectedSymptoms.isNotEmpty;

  /// Build a complete symptom summary string for AI analysis
  String get fullSummary {
    final buffer = StringBuffer();
    buffer.writeln('Body Region: ${selectedRegion ?? "Not selected"}');
    buffer.writeln('Pain Type: ${selectedSymptoms.join(", ")}');
    if (duration.isNotEmpty) {
      buffer.writeln('Duration: $duration');
    }
    if (additionalNotes.isNotEmpty) {
      buffer.writeln('Additional Details: $additionalNotes');
    }
    return buffer.toString();
  }
}

class SymptomCheckNotifier extends Notifier<SymptomCheckState> {
  @override
  SymptomCheckState build() => const SymptomCheckState();

  void toggleView() {
    state = state.copyWith(isFrontView: !state.isFrontView, selectedRegion: null);
  }

  void selectRegion(String region) {
    state = state.copyWith(selectedRegion: region);
  }

  void toggleSymptom(String symptom) {
    final updated = Set<String>.from(state.selectedSymptoms);
    if (updated.contains(symptom)) {
      updated.remove(symptom);
    } else {
      updated.add(symptom);
    }
    state = state.copyWith(selectedSymptoms: updated);
  }

  void setDuration(String duration) {
    state = state.copyWith(duration: duration);
  }

  void setAdditionalNotes(String notes) {
    state = state.copyWith(additionalNotes: notes);
  }
}
