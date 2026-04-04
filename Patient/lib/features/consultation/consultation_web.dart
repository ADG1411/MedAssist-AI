// Web-specific Jitsi implementation using iframe.
// Stubs match the native API so consultation_screen.dart compiles on all platforms.
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

final Set<String> _registeredViews = {};

// Called from ConsultationScreen.initState — registers the iframe factory
void registerJitsiView(String roomId) {
  final viewType = 'jitsi-iframe-$roomId';
  if (_registeredViews.contains(viewType)) return;

  ui_web.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) {
      final iframe = html.IFrameElement()
        ..src =
            'https://meet.jit.si/$roomId'
            '#config.startWithAudioMuted=false'
            '&config.startWithVideoMuted=false'
            '&config.prejoinPageEnabled=false'
            '&userInfo.displayName=MedAssist%20Patient'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'camera; microphone; fullscreen; display-capture; autoplay; clipboard-write';
      return iframe;
    },
  );
  _registeredViews.add(viewType);
}

// Returns the HtmlElementView containing the Jitsi iframe
Widget buildJitsiView(String roomId) {
  final viewType = 'jitsi-iframe-$roomId';
  return HtmlElementView(viewType: viewType);
}

// Stub — on web the iframe handles everything; no native SDK call needed.
// Signature MUST match consultation_native.dart so the conditional import resolves.
Future<void> launchJitsiMeeting({
  required String roomId,
  String displayName = 'MedAssist Patient',
  String email = '',
  bool audioMuted = false,
  bool videoMuted = false,
  void Function()? onConferenceTerminated,
}) async {
  // No-op on web — iframe auto-joins via the src URL registered above.
}
