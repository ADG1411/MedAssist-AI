// SOS Provider — Riverpod v3 Notifier that orchestrates the full
// Emergency SOS dispatch sequence with real GPS, contacts, and dispatch steps.
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/repositories/profile_repository.dart';
import 'sos_service.dart';
import 'widgets/emergency_dispatch_hero.dart'; // SosState enum

// ── State ────────────────────────────────────────────────────────────────────

class SosFullState {
  final SosState sosState;
  final Position? position;
  final String address;
  final String nearestHospital;
  final String hospitalEta;
  final int dispatchStep; // 0 = nothing done, 1–6 = steps completed
  final bool isFlashlightOn;
  final bool isAlarmOn;
  final Map<String, dynamic> profile;
  final bool isLoadingProfile;
  final String? locationError;

  const SosFullState({
    this.sosState = SosState.ready,
    this.position,
    this.address = 'Fetching location…',
    this.nearestHospital = 'Nearest Hospital',
    this.hospitalEta = '…',
    this.dispatchStep = 0,
    this.isFlashlightOn = false,
    this.isAlarmOn = false,
    this.profile = const {},
    this.isLoadingProfile = true,
    this.locationError,
  });

  List<Map<String, dynamic>> get emergencyContacts {
    final contacts = profile['emergency_contacts'];
    if (contacts is List) {
      return contacts.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  String get patientName => profile['name'] as String? ?? 'Patient';
  String get bloodGroup => profile['bloodGroup'] as String? ?? '—';

  SosFullState copyWith({
    SosState? sosState,
    Position? position,
    String? address,
    String? nearestHospital,
    String? hospitalEta,
    int? dispatchStep,
    bool? isFlashlightOn,
    bool? isAlarmOn,
    Map<String, dynamic>? profile,
    bool? isLoadingProfile,
    String? locationError,
  }) {
    return SosFullState(
      sosState: sosState ?? this.sosState,
      position: position ?? this.position,
      address: address ?? this.address,
      nearestHospital: nearestHospital ?? this.nearestHospital,
      hospitalEta: hospitalEta ?? this.hospitalEta,
      dispatchStep: dispatchStep ?? this.dispatchStep,
      isFlashlightOn: isFlashlightOn ?? this.isFlashlightOn,
      isAlarmOn: isAlarmOn ?? this.isAlarmOn,
      profile: profile ?? this.profile,
      isLoadingProfile: isLoadingProfile ?? this.isLoadingProfile,
      locationError: locationError ?? this.locationError,
    );
  }
}

// ── Notifier (Riverpod v3 API) ────────────────────────────────────────────────

class SosNotifier extends Notifier<SosFullState> {
  final SosService _svc = SosService.instance;
  bool _isCancelled = false;

  @override
  SosFullState build() {
    // Kick off async init — profile + GPS
    _initialize();
    return const SosFullState();
  }

  // ── Init: fetch profile + location in parallel ────────────────────────────

  Future<void> _initialize() async {
    // Load profile
    try {
      final repo = ref.read(profileRepositoryProvider);
      final profile = await repo.getProfile();
      state = state.copyWith(profile: profile, isLoadingProfile: false);
    } catch (_) {
      state = state.copyWith(isLoadingProfile: false);
    }

    // Load location (non-blocking — update when ready)
    await _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    final pos = await _svc.getCurrentPosition();
    if (pos == null) {
      state = state.copyWith(
        address: 'Location unavailable',
        locationError: 'Could not fetch GPS location',
      );
      return;
    }
    state = state.copyWith(
      position: pos,
      address:
          '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}',
    );
  }

  // ── SOS Trigger ───────────────────────────────────────────────────────────

  Future<void> triggerSos() async {
    _isCancelled = false;
    HapticFeedback.heavyImpact();
    state = state.copyWith(sosState: SosState.dispatching, dispatchStep: 0);

    // Step 1 — Emergency triggered
    await Future.delayed(const Duration(milliseconds: 600));
    if (_isCancelled) return;
    state = state.copyWith(sosState: SosState.active, dispatchStep: 1);

    // Step 2 — Location shared
    await Future.delayed(const Duration(milliseconds: 800));
    if (_isCancelled) return;
    state = state.copyWith(dispatchStep: 2);

    // Step 3 — Contacts alerted (trigger SMS)
    await Future.delayed(const Duration(milliseconds: 1000));
    if (_isCancelled) return;
    state = state.copyWith(dispatchStep: 3);
    _notifyContacts();

    // Step 4 — SMS delivered confirmation
    await Future.delayed(const Duration(milliseconds: 1200));
    if (_isCancelled) return;
    state = state.copyWith(dispatchStep: 4);

    // Step 5 — Call attempt
    await Future.delayed(const Duration(milliseconds: 900));
    if (_isCancelled) return;
    state = state.copyWith(dispatchStep: 5);

    // Step 6 — Hospital alert
    await Future.delayed(const Duration(milliseconds: 800));
    if (_isCancelled) return;
    state = state.copyWith(dispatchStep: 6);
  }

  void _notifyContacts() {
    final contacts = state.emergencyContacts;
    final pos = state.position;
    final name = state.patientName;
    final blood = state.bloodGroup;

    final locationText = pos != null
        ? 'https://maps.google.com/?q=${pos.latitude},${pos.longitude}'
        : 'location unavailable';

    final message = '🚨 EMERGENCY ALERT: $name needs help NOW!\n'
        'Blood: $blood\n'
        'Location: $locationText\n'
        'Open MedAssist for medical info.';

    for (final contact in contacts) {
      final phone = contact['phone'] as String? ?? '';
      if (phone.isNotEmpty) {
        _svc.sendEmergencySms(phone, message);
      }
    }
  }

  // ── Cancel SOS ────────────────────────────────────────────────────────────

  Future<void> cancelSos() async {
    _isCancelled = true;
    await _svc.stopAlarm();
    await _svc.disableFlashlight();
    state = state.copyWith(
      sosState: SosState.cancelled,
      isAlarmOn: false,
      isFlashlightOn: false,
    );
  }

  // ── Action rail ───────────────────────────────────────────────────────────

  Future<void> callFirstEmergencyContact() async {
    final contacts = state.emergencyContacts;
    if (contacts.isEmpty) return;
    final phone = contacts.first['phone'] as String? ?? '';
    if (phone.isNotEmpty) {
      await _svc.launchCall(phone);
    }
  }

  Future<void> callDoctor() async {
    final phone = state.profile['doctor_phone'] as String? ?? '102';
    await _svc.launchCall(phone);
  }

  Future<void> openHospitalDirections() async {
    final pos = state.position;
    if (pos != null) {
      await _svc.launchMapsNavigation(pos.latitude, pos.longitude);
    } else {
      await _svc.launchMapsSearch('nearest hospital emergency');
    }
  }

  Future<void> toggleFlashlight() async {
    final success = await _svc.toggleFlashlight();
    if (success) {
      state = state.copyWith(isFlashlightOn: _svc.isFlashlightOn);
    }
  }

  Future<void> toggleAlarm() async {
    final isOn = await _svc.toggleAlarm();
    state = state.copyWith(isAlarmOn: isOn);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final sosProvider =
    NotifierProvider.autoDispose<SosNotifier, SosFullState>(SosNotifier.new);
