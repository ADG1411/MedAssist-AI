import 'package:flutter/material.dart';

class PhysicalActivityCatalogEntry {
  final String code;
  final String specificActivity;
  final String description;
  final double mets;

  const PhysicalActivityCatalogEntry({
    required this.code,
    required this.specificActivity,
    required this.description,
    required this.mets,
  });

  String get name => specificActivity;

  IconData get icon {
    switch (code) {
      case "12020":
      case "12150":
        return Icons.directions_run;
      case "01015":
      case "01009":
      case "02010":
        return Icons.directions_bike;
      case "18350":
      case "18355":
        return Icons.water;
      case "17160":
      case "17165":
      case "17010":
      case "17080":
        return Icons.directions_walk;
      default:
        return Icons.fitness_center;
    }
  }
}

class ActivityCatalog {
  static const List<PhysicalActivityCatalogEntry> activities = [
    PhysicalActivityCatalogEntry(code: "12020", specificActivity: "Jogging", description: "General jogging", mets: 7.0),
    PhysicalActivityCatalogEntry(code: "12150", specificActivity: "Running", description: "Running, general", mets: 8.0),
    PhysicalActivityCatalogEntry(code: "01015", specificActivity: "Bicycling", description: "Bicycling, general", mets: 7.5),
    PhysicalActivityCatalogEntry(code: "01009", specificActivity: "Mountain Biking", description: "Bicycling, mountain, general", mets: 8.5),
    PhysicalActivityCatalogEntry(code: "02010", specificActivity: "Stationary Cycling", description: "Stationary cycling, general", mets: 7.0),
    PhysicalActivityCatalogEntry(code: "02030", specificActivity: "Calisthenics", description: "Calisthenics, general", mets: 3.8),
    PhysicalActivityCatalogEntry(code: "02050", specificActivity: "Resistance Training", description: "Weight lifting or strength training", mets: 6.0),
    PhysicalActivityCatalogEntry(code: "18350", specificActivity: "Swimming", description: "Swimming laps, freestyle, fast", mets: 9.8),
    PhysicalActivityCatalogEntry(code: "17160", specificActivity: "Walking", description: "Walking for pleasure", mets: 3.5),
    PhysicalActivityCatalogEntry(code: "17165", specificActivity: "Walking the Dog", description: "Walking the dog", mets: 3.0),
    PhysicalActivityCatalogEntry(code: "17010", specificActivity: "Backpacking", description: "Backpacking, general", mets: 7.0),
    PhysicalActivityCatalogEntry(code: "15055", specificActivity: "Basketball", description: "Basketball, general", mets: 6.5),
    PhysicalActivityCatalogEntry(code: "15610", specificActivity: "Soccer", description: "Soccer, general", mets: 7.0),
    PhysicalActivityCatalogEntry(code: "15675", specificActivity: "Tennis", description: "Tennis, general", mets: 7.3),
  ];

  static List<PhysicalActivityCatalogEntry> search(String query) {
    if (query.isEmpty) return activities;
    final q = query.toLowerCase();
    return activities.where((a) => 
      a.specificActivity.toLowerCase().contains(q) || 
      a.description.toLowerCase().contains(q)
    ).toList();
  }
}

