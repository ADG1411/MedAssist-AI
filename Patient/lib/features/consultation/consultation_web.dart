// Web-specific Jitsi implementation using iframe
// This file is only imported when running on Flutter Web (dart:html available)

import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

final Set<String> _registeredViews = {};

void registerJitsiView(String roomId) {
  final viewType = 'jitsi-iframe-$roomId';
  if (_registeredViews.contains(viewType)) return;

  ui_web.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) {
      final iframe = html.IFrameElement()
        ..src = 'https://meet.jit.si/$roomId#config.startWithAudioMuted=false&config.startWithVideoMuted=false&userInfo.displayName=MedAssist%20Patient'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'camera; microphone; fullscreen; display-capture; autoplay; clipboard-write';
      return iframe;
    },
  );
  _registeredViews.add(viewType);
}

Widget buildJitsiView(String roomId) {
  final viewType = 'jitsi-iframe-$roomId';
  return HtmlElementView(viewType: viewType);
}
