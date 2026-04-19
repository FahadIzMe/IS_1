import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/models.dart';

/// API Service for backend communication
class ApiService {
  /// Fetch and classify data from backend
  static Future<Map<String, dynamic>> fetchAndClassify({int batchSize = 5}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.fetchAndClassify}?batch_size=$batchSize'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Server returned ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get statistics from backend
  static Future<AttackStatistics?> getStatistics() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.statistics),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AttackStatistics.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting statistics: $e');
      return null;
    }
  }

  /// Get recent threats from backend
  static Future<List<ThreatRecord>> getRecentThreats({int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.recentThreats}?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final threats = data['threats'] as List;
        return threats.map((t) => ThreatRecord.fromJson(t)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting recent threats: $e');
      return [];
    }
  }

  /// Health check
  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.health),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }
}
