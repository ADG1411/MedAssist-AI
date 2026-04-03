import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Monitors network connectivity and provides a Riverpod stream.
/// Used to trigger sync queue flush when connectivity is restored.
class ConnectivityMonitor {
  ConnectivityMonitor._();

  static final Connectivity _connectivity = Connectivity();

  /// Stream of connectivity status (true = online)
  static Stream<bool> get isOnline {
    return _connectivity.onConnectivityChanged.map((results) {
      return results.any((r) => r != ConnectivityResult.none);
    });
  }

  /// One-shot check: are we online right now?
  static Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}

/// Riverpod provider that streams connectivity status.
/// Usage: ref.watch(connectivityProvider).when(...)
final connectivityProvider = StreamProvider<bool>((ref) {
  return ConnectivityMonitor.isOnline;
});

/// Riverpod provider for one-shot connectivity check.
final isOnlineProvider = FutureProvider<bool>((ref) {
  return ConnectivityMonitor.checkConnection();
});
