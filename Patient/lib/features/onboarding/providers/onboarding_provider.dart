import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/cache/boxes/profile_cache_box.dart';
import '../../../core/cache/boxes/emergency_cache_box.dart';
import '../../../core/audit/audit_service.dart';
import '../../../core/audit/audit_constants.dart';

/// Complete onboarding state for the 5-step medical profile wizard.
class OnboardingState {
  final int currentStep;
  final bool isSubmitting;

  // Step 1: Basic Info
  final String fullName;
  final DateTime? dateOfBirth;
  final String gender;
  final String heightCm;
  final String weightKg;
  final String bloodGroup;

  // Step 2: Medical History
  final List<String> allergies;
  final List<String> chronicConditions;
  final List<String> currentMedications;
  final List<String> pastSurgeries;

  // Step 3: Lifestyle
  final String smokingStatus;
  final String alcoholFrequency;
  final double sleepHoursAvg;
  final String stressLevel;
  final String activityLevel;
  final String dietType;

  // Step 4: Emergency
  final List<Map<String, String>> emergencyContacts;
  final List<Map<String, String>> preferredHospitals;
  final String insuranceProvider;
  final String insuranceId;

  // Step 5: Permissions
  final bool wearablePermission;
  final bool notificationPermission;
  final bool locationPermission;

  const OnboardingState({
    this.currentStep = 0,
    this.isSubmitting = false,
    this.fullName = '',
    this.dateOfBirth,
    this.gender = '',
    this.heightCm = '',
    this.weightKg = '',
    this.bloodGroup = 'Unknown',
    this.allergies = const [],
    this.chronicConditions = const [],
    this.currentMedications = const [],
    this.pastSurgeries = const [],
    this.smokingStatus = 'Never',
    this.alcoholFrequency = 'None',
    this.sleepHoursAvg = 7.0,
    this.stressLevel = 'Moderate',
    this.activityLevel = 'Moderate',
    this.dietType = 'Regular',
    this.emergencyContacts = const [],
    this.preferredHospitals = const [],
    this.insuranceProvider = '',
    this.insuranceId = '',
    this.wearablePermission = false,
    this.notificationPermission = true,
    this.locationPermission = true,
  });

  OnboardingState copyWith({
    int? currentStep,
    bool? isSubmitting,
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? heightCm,
    String? weightKg,
    String? bloodGroup,
    List<String>? allergies,
    List<String>? chronicConditions,
    List<String>? currentMedications,
    List<String>? pastSurgeries,
    String? smokingStatus,
    String? alcoholFrequency,
    double? sleepHoursAvg,
    String? stressLevel,
    String? activityLevel,
    String? dietType,
    List<Map<String, String>>? emergencyContacts,
    List<Map<String, String>>? preferredHospitals,
    String? insuranceProvider,
    String? insuranceId,
    bool? wearablePermission,
    bool? notificationPermission,
    bool? locationPermission,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      currentMedications: currentMedications ?? this.currentMedications,
      pastSurgeries: pastSurgeries ?? this.pastSurgeries,
      smokingStatus: smokingStatus ?? this.smokingStatus,
      alcoholFrequency: alcoholFrequency ?? this.alcoholFrequency,
      sleepHoursAvg: sleepHoursAvg ?? this.sleepHoursAvg,
      stressLevel: stressLevel ?? this.stressLevel,
      activityLevel: activityLevel ?? this.activityLevel,
      dietType: dietType ?? this.dietType,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      preferredHospitals: preferredHospitals ?? this.preferredHospitals,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insuranceId: insuranceId ?? this.insuranceId,
      wearablePermission: wearablePermission ?? this.wearablePermission,
      notificationPermission: notificationPermission ?? this.notificationPermission,
      locationPermission: locationPermission ?? this.locationPermission,
    );
  }

  /// Convert to a flat map for Supabase upsert
  Map<String, dynamic> toProfileMap() {
    return {
      'name': fullName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'height_cm': double.tryParse(heightCm),
      'weight_kg': double.tryParse(weightKg),
      'blood_group': bloodGroup,
      'allergies': allergies,
      'chronic_conditions': chronicConditions,
      'current_medications': currentMedications,
      'past_surgeries': pastSurgeries,
      'smoking_status': smokingStatus,
      'alcohol_frequency': alcoholFrequency,
      'sleep_hours_avg': sleepHoursAvg,
      'stress_level': stressLevel,
      'activity_level': activityLevel,
      'diet_type': dietType,
      'emergency_contacts': emergencyContacts,
      'preferred_hospitals': preferredHospitals,
      'insurance_provider': insuranceProvider,
      'insurance_id': insuranceId,
      'wearable_permission': wearablePermission,
      'notification_permission': notificationPermission,
      'location_permission': locationPermission,
      'onboarding_completed': true,
    };
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void nextStep() {
    if (state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 4) {
      state = state.copyWith(currentStep: step);
    }
  }

  // Step 1 updates
  void updateBasicInfo({
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? heightCm,
    String? weightKg,
    String? bloodGroup,
  }) {
    state = state.copyWith(
      fullName: fullName,
      dateOfBirth: dateOfBirth,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      bloodGroup: bloodGroup,
    );
  }

  // Step 2 updates
  void addAllergy(String allergy) {
    if (allergy.trim().isNotEmpty && !state.allergies.contains(allergy.trim())) {
      state = state.copyWith(allergies: [...state.allergies, allergy.trim()]);
    }
  }

  void removeAllergy(String allergy) {
    state = state.copyWith(allergies: state.allergies.where((a) => a != allergy).toList());
  }

  void addCondition(String condition) {
    if (condition.trim().isNotEmpty && !state.chronicConditions.contains(condition.trim())) {
      state = state.copyWith(chronicConditions: [...state.chronicConditions, condition.trim()]);
    }
  }

  void removeCondition(String condition) {
    state = state.copyWith(chronicConditions: state.chronicConditions.where((c) => c != condition).toList());
  }

  void addMedication(String medication) {
    if (medication.trim().isNotEmpty && !state.currentMedications.contains(medication.trim())) {
      state = state.copyWith(currentMedications: [...state.currentMedications, medication.trim()]);
    }
  }

  void removeMedication(String medication) {
    state = state.copyWith(currentMedications: state.currentMedications.where((m) => m != medication).toList());
  }

  void addSurgery(String surgery) {
    if (surgery.trim().isNotEmpty && !state.pastSurgeries.contains(surgery.trim())) {
      state = state.copyWith(pastSurgeries: [...state.pastSurgeries, surgery.trim()]);
    }
  }

  void removeSurgery(String surgery) {
    state = state.copyWith(pastSurgeries: state.pastSurgeries.where((s) => s != surgery).toList());
  }

  // Step 3 updates
  void updateLifestyle({
    String? smokingStatus,
    String? alcoholFrequency,
    double? sleepHoursAvg,
    String? stressLevel,
    String? activityLevel,
    String? dietType,
  }) {
    state = state.copyWith(
      smokingStatus: smokingStatus,
      alcoholFrequency: alcoholFrequency,
      sleepHoursAvg: sleepHoursAvg,
      stressLevel: stressLevel,
      activityLevel: activityLevel,
      dietType: dietType,
    );
  }

  // Step 4 updates
  void addEmergencyContact(Map<String, String> contact) {
    if (state.emergencyContacts.length < 3) {
      state = state.copyWith(emergencyContacts: [...state.emergencyContacts, contact]);
    }
  }

  void removeEmergencyContact(int index) {
    final contacts = List<Map<String, String>>.from(state.emergencyContacts);
    contacts.removeAt(index);
    state = state.copyWith(emergencyContacts: contacts);
  }

  void addPreferredHospital(Map<String, String> hospital) {
    if (state.preferredHospitals.length < 2) {
      state = state.copyWith(preferredHospitals: [...state.preferredHospitals, hospital]);
    }
  }

  void removePreferredHospital(int index) {
    final hospitals = List<Map<String, String>>.from(state.preferredHospitals);
    hospitals.removeAt(index);
    state = state.copyWith(preferredHospitals: hospitals);
  }

  void updateInsurance({String? provider, String? id}) {
    state = state.copyWith(insuranceProvider: provider, insuranceId: id);
  }

  // Step 5 updates
  void updatePermissions({
    bool? wearable,
    bool? notifications,
    bool? location,
  }) {
    state = state.copyWith(
      wearablePermission: wearable,
      notificationPermission: notifications,
      locationPermission: location,
    );
  }

  /// Submit the complete profile to Supabase + cache locally
  Future<bool> submitProfile() async {
    state = state.copyWith(isSubmitting: true);
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) {
        state = state.copyWith(isSubmitting: false);
        return false;
      }

      final profileData = state.toProfileMap();
      profileData['id'] = userId;

      // Upsert to Supabase
      await SupabaseService.client
          .from('profiles')
          .upsert(profileData, onConflict: 'id');

      // Cache locally
      await ProfileCacheBox.save(profileData);
      await ProfileCacheBox.setOnboardingCompleted(true);

      // Cache emergency data separately
      await EmergencyCacheBox.saveEmergencyPackage({
        'blood_group': state.bloodGroup,
        'allergies': state.allergies,
        'current_medications': state.currentMedications,
        'chronic_conditions': state.chronicConditions,
        'emergency_contacts': state.emergencyContacts,
        'preferred_hospitals': state.preferredHospitals,
        'full_name': state.fullName,
      });

      // Audit log
      await AuditService.log(
        action: AuditAction.onboardingCompleted,
        module: AuditModule.onboarding,
      );

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      return false;
    }
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(OnboardingNotifier.new);
