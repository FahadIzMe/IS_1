import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../config/constants.dart';

/// Dashboard Provider - State management with polling
class DashboardProvider extends ChangeNotifier {
  // State variables
  bool _isLoading = false;
  bool _isMonitoring = false;
  String? _error;
  Timer? _pollingTimer;

  // Statistics
  AttackStatistics _statistics = AttackStatistics.empty();
  List<PredictionResult> _recentResults = [];
  List<ThreatRecord> _recentThreats = [];

  // Connection status
  bool _isConnected = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isMonitoring => _isMonitoring;
  String? get error => _error;
  AttackStatistics get statistics => _statistics;
  List<PredictionResult> get recentResults => _recentResults;
  List<ThreatRecord> get recentThreats => _recentThreats;
  bool get isConnected => _isConnected;

  // Computed properties
  int get totalAnalyzed => _statistics.totalAnalyzed;
  int get benignCount => _statistics.benignCount;
  int get threatCount => _statistics.threatCount;
  double get threatPercentage => _statistics.threatPercentage;

  /// Initialize provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // Check backend health
    _isConnected = await ApiService.healthCheck();

    if (_isConnected) {
      // Load initial statistics
      final stats = await ApiService.getStatistics();
      if (stats != null) {
        _statistics = stats;
      }

      // Load initial threats
      final threats = await ApiService.getRecentThreats(limit: 20);
      _recentThreats = threats;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Start monitoring (2-second polling)
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _error = null;
    notifyListeners();

    // Start polling every 2 seconds
    _pollingTimer = Timer.periodic(ApiConstants.pollingInterval, (_) {
      _fetchAndClassify();
    });

    // Fetch immediately
    _fetchAndClassify();
  }

  /// Stop monitoring
  void stopMonitoring() {
    if (!_isMonitoring) return;

    _isMonitoring = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    notifyListeners();
  }

  /// Fetch and classify data from backend
  Future<void> _fetchAndClassify() async {
    try {
      final response = await ApiService.fetchAndClassify(batchSize: 5);

      if (response['success']) {
        final data = response['data'];

        // Parse results
        final results = (data['results'] as List)
            .map((r) => PredictionResult.fromJson(r))
            .toList();

        // Add to recent results (keep last 50)
        _recentResults.insertAll(0, results);
        if (_recentResults.length > 50) {
          _recentResults = _recentResults.sublist(0, 50);
        }

        // Fetch full statistics to update charts
        final fullStats = await ApiService.getStatistics();
        if (fullStats != null) {
          _statistics = fullStats;
        }

        // Update recent threats (only threats)
        final newThreats = results.where((r) => r.isThreat).toList();
        for (var result in newThreats) {
          _recentThreats.insert(
            0,
            ThreatRecord(
              type: result.prediction,
              timestamp: result.timestamp,
              confidence: result.confidence,
              sourceIp: result.sourceIp,
              destinationPort: result.destinationPort,
              securityImpact: result.securityImpact,
            ),
          );
        }
        if (_recentThreats.length > 100) {
          _recentThreats = _recentThreats.sublist(0, 100);
        }

        _error = null;
        _isConnected = true;
      } else {
        _error = response['error'];
        _isConnected = false;
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isConnected = false;
      notifyListeners();
    }
  }

  /// Manual refresh
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    // Get full statistics
    final stats = await ApiService.getStatistics();
    if (stats != null) {
      _statistics = stats;
    }

    // Get recent threats
    final threats = await ApiService.getRecentThreats(limit: 20);
    _recentThreats = threats;

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
