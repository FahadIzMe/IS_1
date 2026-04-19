import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../config/constants.dart';

/// Live Feed Widget - Shows recent detections
class LiveFeedWidget extends StatelessWidget {
  final List<ThreatRecord> threats;

  const LiveFeedWidget({
    super.key,
    required this.threats,
  });

  @override
  Widget build(BuildContext context) {
    if (threats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppColors.success,
            ),
            const SizedBox(height: 12),
            Text(
              'No threats detected yet',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: threats.length,
      itemBuilder: (context, index) {
        final threat = threats[index];
        return _ThreatTile(threat: threat);
      },
    );
  }
}

class _ThreatTile extends StatelessWidget {
  final ThreatRecord threat;

  const _ThreatTile({required this.threat});

  @override
  Widget build(BuildContext context) {
    final level = getThreatLevel(threat.type);
    final color = getThreatColor(level);
    final timeAgo = _getTimeAgo(threat.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Threat indicator
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          
          // Threat info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  threat.type,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      Icons.computer,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    Text(
                      threat.sourceIp,
                      style: GoogleFonts.jetBrainsMono(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '→',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      ':${threat.destinationPort}',
                      style: GoogleFonts.jetBrainsMono(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Security Impact Badges
                Wrap(
                  spacing: 4,
                  children: [
                    if (threat.securityImpact.confidentiality)
                      _SecurityBadge(
                        label: 'C',
                        tooltip: 'Confidentiality',
                        color: color,
                      ),
                    if (threat.securityImpact.integrity)
                      _SecurityBadge(
                        label: 'I',
                        tooltip: 'Integrity',
                        color: color,
                      ),
                    if (threat.securityImpact.availability)
                      _SecurityBadge(
                        label: 'A',
                        tooltip: 'Availability',
                        color: color,
                      ),
                    if (threat.securityImpact.authenticity)
                      _SecurityBadge(
                        label: 'Au',
                        tooltip: 'Authenticity',
                        color: color,
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Time and confidence
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeAgo,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${(threat.confidence * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return '${difference.inSeconds}s ago';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return DateFormat('MMM d, HH:mm').format(dateTime);
      }
    } catch (e) {
      return 'Just now';
    }
  }
}

/// Security impact badge widget
class _SecurityBadge extends StatelessWidget {
  final String label;
  final String tooltip;
  final Color color;

  const _SecurityBadge({
    required this.label,
    required this.tooltip,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$tooltip compromised',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: color.withOpacity(0.5), width: 0.5),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
