import 'package:flutter/material.dart';

enum AiMode { fast, deep }

class AppState {
  final bool isFirstLaunch;
  final AiMode selectedAiMode;
  final ThemeMode themeMode;
  final String? activeTicketId;
  final String? lastSelectedBodyPart;

  const AppState({
    this.isFirstLaunch = true,
    this.selectedAiMode = AiMode.fast,
    this.themeMode = ThemeMode.system,
    this.activeTicketId,
    this.lastSelectedBodyPart,
  });

  // Restoration-ready copying
  AppState copyWith({
    bool? isFirstLaunch,
    AiMode? selectedAiMode,
    ThemeMode? themeMode,
    String? activeTicketId,
    String? lastSelectedBodyPart,
  }) {
    return AppState(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      selectedAiMode: selectedAiMode ?? this.selectedAiMode,
      themeMode: themeMode ?? this.themeMode,
      activeTicketId: activeTicketId ?? this.activeTicketId,
      lastSelectedBodyPart: lastSelectedBodyPart ?? this.lastSelectedBodyPart,
    );
  }

  // To/From JSON for preferences backup/restore plug-in later
  Map<String, dynamic> toJson() {
    return {
      'isFirstLaunch': isFirstLaunch,
      'selectedAiMode': selectedAiMode.name,
      'themeMode': themeMode.name,
      'activeTicketId': activeTicketId,
      'lastSelectedBodyPart': lastSelectedBodyPart,
    };
  }

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      isFirstLaunch: json['isFirstLaunch'] ?? true,
      selectedAiMode: AiMode.values.firstWhere(
        (e) => e.name == json['selectedAiMode'],
        orElse: () => AiMode.fast,
      ),
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      activeTicketId: json['activeTicketId'],
      lastSelectedBodyPart: json['lastSelectedBodyPart'],
    );
  }
}

