/// Model for prediction result from backend
class PredictionResult {
  final String timestamp;
  final String sourceIp;
  final int destinationPort;
  final String prediction;
  final double confidence;
  final bool isThreat;
  final SecurityImpact securityImpact;
  final List<TopPrediction> topPredictions;

  PredictionResult({
    required this.timestamp,
    required this.sourceIp,
    required this.destinationPort,
    required this.prediction,
    required this.confidence,
    required this.isThreat,
    required this.securityImpact,
    required this.topPredictions,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      timestamp: json['timestamp'] ?? '',
      sourceIp: json['source_ip'] ?? 'Unknown',
      destinationPort: json['destination_port'] ?? 0,
      prediction: json['prediction'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0).toDouble(),
      isThreat: json['is_threat'] ?? false,
      securityImpact: SecurityImpact.fromJson(json['security_impact'] ?? {}),
      topPredictions: (json['top_predictions'] as List?)
              ?.map((e) => TopPrediction.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// Model for security impact (CIA+A)
class SecurityImpact {
  final bool confidentiality;
  final bool integrity;
  final bool availability;
  final bool authenticity;
  final String description;

  SecurityImpact({
    required this.confidentiality,
    required this.integrity,
    required this.availability,
    required this.authenticity,
    required this.description,
  });

  factory SecurityImpact.fromJson(Map<String, dynamic> json) {
    return SecurityImpact(
      confidentiality: json['confidentiality'] ?? false,
      integrity: json['integrity'] ?? false,
      availability: json['availability'] ?? false,
      authenticity: json['authenticity'] ?? false,
      description: json['description'] ?? '',
    );
  }

  List<String> getCompromisedProperties() {
    List<String> compromised = [];
    if (confidentiality) compromised.add('Confidentiality');
    if (integrity) compromised.add('Integrity');
    if (availability) compromised.add('Availability');
    if (authenticity) compromised.add('Authenticity');
    return compromised;
  }
}

/// Model for top predictions
class TopPrediction {
  final String attackClass;
  final double confidence;

  TopPrediction({
    required this.attackClass,
    required this.confidence,
  });

  factory TopPrediction.fromJson(Map<String, dynamic> json) {
    return TopPrediction(
      attackClass: json['class'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
    );
  }
}

/// Model for overall statistics
class AttackStatistics {
  final int totalAnalyzed;
  final int benignCount;
  final int threatCount;
  final double threatPercentage;
  final Map<String, int> byClass;
  final Map<String, double> percentages;
  final List<TopAttack> topAttacks;
  final List<TimelinePoint> timeline;

  AttackStatistics({
    required this.totalAnalyzed,
    required this.benignCount,
    required this.threatCount,
    required this.threatPercentage,
    required this.byClass,
    required this.percentages,
    required this.topAttacks,
    required this.timeline,
  });

  factory AttackStatistics.fromJson(Map<String, dynamic> json) {
    return AttackStatistics(
      totalAnalyzed: json['total_analyzed'] ?? 0,
      benignCount: json['benign_count'] ?? 0,
      threatCount: json['threat_count'] ?? 0,
      threatPercentage: (json['threat_percentage'] ?? 0).toDouble(),
      byClass: Map<String, int>.from(json['by_class'] ?? {}),
      percentages: (json['percentages'] as Map?)?.map(
            (key, value) => MapEntry(key as String, (value as num).toDouble()),
          ) ??
          {},
      topAttacks: (json['top_attacks'] as List?)
              ?.map((e) => TopAttack.fromJson(e))
              .toList() ??
          [],
      timeline: (json['timeline'] as List?)
              ?.map((e) => TimelinePoint.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory AttackStatistics.empty() {
    return AttackStatistics(
      totalAnalyzed: 0,
      benignCount: 0,
      threatCount: 0,
      threatPercentage: 0.0,
      byClass: {},
      percentages: {},
      topAttacks: [],
      timeline: [],
    );
  }
}

/// Model for top attack types
class TopAttack {
  final String type;
  final int count;

  TopAttack({
    required this.type,
    required this.count,
  });

  factory TopAttack.fromJson(Map<String, dynamic> json) {
    return TopAttack(
      type: json['type'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

/// Model for timeline data points
class TimelinePoint {
  final String timestamp;
  final int threatCount;
  final int benignCount;

  TimelinePoint({
    required this.timestamp,
    required this.threatCount,
    required this.benignCount,
  });

  factory TimelinePoint.fromJson(Map<String, dynamic> json) {
    return TimelinePoint(
      timestamp: json['timestamp'] ?? '',
      threatCount: json['threat_count'] ?? 0,
      benignCount: json['benign_count'] ?? 0,
    );
  }
}

/// Model for threat record
class ThreatRecord {
  final String type;
  final String timestamp;
  final double confidence;
  final String sourceIp;
  final int destinationPort;
  final SecurityImpact securityImpact;

  ThreatRecord({
    required this.type,
    required this.timestamp,
    required this.confidence,
    required this.sourceIp,
    required this.destinationPort,
    required this.securityImpact,
  });

  factory ThreatRecord.fromJson(Map<String, dynamic> json) {
    return ThreatRecord(
      type: json['type'] ?? '',
      timestamp: json['timestamp'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      sourceIp: json['source_ip'] ?? 'N/A',
      destinationPort: json['destination_port'] ?? 0,
      securityImpact: SecurityImpact.fromJson(json['security_impact'] ?? {}),
    );
  }
}
