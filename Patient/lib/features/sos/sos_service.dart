// SOS Service — wraps all real-world integrations for Emergency SOS.
// GPS via geolocator, calls/sms/maps via url_launcher,
// flashlight via torch_light, alarm via audioplayers.
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:torch_light/torch_light.dart';
import 'package:audioplayers/audioplayers.dart';

class SosService {
  SosService._();
  static final SosService instance = SosService._();

  final AudioPlayer _alarmPlayer = AudioPlayer();
  bool _isAlarmPlaying = false;

  // ── GPS ──────────────────────────────────────────────────────────────────

  /// Request permission then return current position.
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return null;
    }
    if (perm == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      // Fall back to last known position
      return await Geolocator.getLastKnownPosition();
    }
  }

  // ── Phone Call ────────────────────────────────────────────────────────────

  Future<void> launchCall(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // ── SMS ───────────────────────────────────────────────────────────────────

  Future<void> launchSms(String phone, String message) async {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(
      scheme: 'sms',
      path: cleaned,
      queryParameters: {'body': message},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Send silent SMS (no UI) — uses url_launcher fallback
  Future<void> sendEmergencySms(String phone, String message) async {
    // url_launcher opens SMS app with pre-filled message
    await launchSms(phone, message);
  }

  // ── Maps Navigation ──────────────────────────────────────────────────────

  Future<void> launchMapsNavigation(double lat, double lng) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> launchMapsSearch(String query) async {
    final encoded = Uri.encodeComponent(query);
    final uri = Uri.parse(
        'https://www.google.com/maps/search/$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Flashlight ───────────────────────────────────────────────────────────

  bool _isFlashlightOn = false;
  bool get isFlashlightOn => _isFlashlightOn;

  Future<bool> toggleFlashlight() async {
    try {
      final hasTorch = await TorchLight.isTorchAvailable();
      if (!hasTorch) return false;
      if (_isFlashlightOn) {
        await TorchLight.disableTorch();
        _isFlashlightOn = false;
      } else {
        await TorchLight.enableTorch();
        _isFlashlightOn = true;
      }
      HapticFeedback.lightImpact();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> disableFlashlight() async {
    if (_isFlashlightOn) {
      try {
        await TorchLight.disableTorch();
        _isFlashlightOn = false;
      } catch (_) {}
    }
  }

  // ── Alarm ────────────────────────────────────────────────────────────────

  bool get isAlarmPlaying => _isAlarmPlaying;

  Future<void> startAlarm() async {
    if (_isAlarmPlaying) return;
    try {
      await _alarmPlayer.setReleaseMode(ReleaseMode.loop);
      await _alarmPlayer.setVolume(1.0);
      await _alarmPlayer.play(AssetSource('sounds/alarm.mp3'));
      _isAlarmPlaying = true;
      HapticFeedback.heavyImpact();
    } catch (_) {
      // Asset might not exist on first run — ignore silently
    }
  }

  Future<void> stopAlarm() async {
    if (!_isAlarmPlaying) return;
    try {
      await _alarmPlayer.stop();
      _isAlarmPlaying = false;
    } catch (_) {}
  }

  Future<bool> toggleAlarm() async {
    if (_isAlarmPlaying) {
      await stopAlarm();
      return false;
    } else {
      await startAlarm();
      return true;
    }
  }

  // ── Cleanup ──────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    await stopAlarm();
    await disableFlashlight();
    await _alarmPlayer.dispose();
  }
}
