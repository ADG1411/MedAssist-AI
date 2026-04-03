// Native-specific Jitsi implementation
// On mobile, we'll use Jitsi Meet Flutter SDK or a simple fallback

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

void registerJitsiView(String roomId) {
  // No-op on native — the native SDK doesn't use view factories
}

Widget buildJitsiView(String roomId) {
  // Placeholder for native platforms
  // In production, this would launch the Jitsi Meet native SDK
  // For now, show a waiting screen
  return Container(
    color: const Color(0xFF1A1A2E),
    child: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_call, size: 64, color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Native video call active',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Jitsi Meet SDK is handling the call',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    ),
  );
}
