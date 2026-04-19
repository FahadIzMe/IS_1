import 'package:flutter/material.dart';

/// API Configuration
class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8080/api';
  static const String fetchAndClassify = '$baseUrl/fetch-and-classify/';
  static const String statistics = '$baseUrl/statistics/';
  static const String recentThreats = '$baseUrl/recent-threats/';
  static const String health = '$baseUrl/health/';
  
  // Polling interval (2 seconds as specified)
  static const Duration pollingInterval = Duration(seconds: 2);
}

/// App Color Scheme - Cybersecurity themed dark mode
class AppColors {
  static const Color primary = Color(0xFF1E3A5F);
  static const Color accent = Color(0xFF4ECDC4);
  static const Color danger = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color success = Color(0xFF27AE60);
  static const Color background = Color(0xFF0A1628);
  static const Color cardBg = Color(0xFF152238);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8899A6);
  static const Color benign = Color(0xFF27AE60);
  static const Color threat = Color(0xFFE74C3C);
}

/// Attack severity levels
enum ThreatLevel {
  benign,
  low,
  medium,
  high,
  critical,
}

/// Get threat level based on attack type
ThreatLevel getThreatLevel(String attackType) {
  if (attackType == 'BENIGN') return ThreatLevel.benign;
  
  // Critical threats
  if (attackType.contains('DDoS') || 
      attackType.contains('DoS') ||
      attackType.contains('Infiltration')) {
    return ThreatLevel.critical;
  }
  
  // High threats
  if (attackType.contains('Brute Force') ||
      attackType.contains('SQL Injection') ||
      attackType.contains('Bot')) {
    return ThreatLevel.high;
  }
  
  // Medium threats
  if (attackType.contains('PortScan') ||
      attackType.contains('Patator')) {
    return ThreatLevel.medium;
  }
  
  return ThreatLevel.low;
}

/// Get color for threat level
Color getThreatColor(ThreatLevel level) {
  switch (level) {
    case ThreatLevel.benign:
      return AppColors.benign;
    case ThreatLevel.low:
      return Colors.yellow;
    case ThreatLevel.medium:
      return AppColors.warning;
    case ThreatLevel.high:
      return Colors.deepOrange;
    case ThreatLevel.critical:
      return AppColors.danger;
  }
}
