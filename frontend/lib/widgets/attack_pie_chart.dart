import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/constants.dart';

/// Attack Distribution Pie Chart Widget
class AttackPieChart extends StatelessWidget {
  final Map<String, int> distribution;

  const AttackPieChart({
    super.key,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    if (distribution.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    // Sort by count and show all entries with at least 1% or top 8
    final sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final grandTotal = sortedEntries.fold<int>(0, (sum, e) => sum + e.value);
    
    // Filter to show entries with at least 1% or top 8, whichever is more
    final significantEntries = sortedEntries.where((e) => 
      (e.value / grandTotal * 100) >= 1.0
    ).toList();
    
    final topEntries = significantEntries.length > 8 
      ? significantEntries.take(8).toList() 
      : significantEntries;
    
    final total = topEntries.fold<int>(0, (sum, e) => sum + e.value);

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              sections: _generateSections(topEntries, total),
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildLegend(topEntries, total),
      ],
    );
  }

  List<PieChartSectionData> _generateSections(
    List<MapEntry<String, int>> entries,
    int total,
  ) {
    final colors = [
      AppColors.danger,
      AppColors.warning,
      Colors.deepOrange,
      Colors.purple,
      Colors.pink,
    ];

    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final percentage = (data.value / total * 100).toStringAsFixed(1);

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: data.value.toDouble(),
        title: '$percentage%',
        radius: 80,
        titleStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(List<MapEntry<String, int>> entries, int total) {
    final colors = [
      AppColors.danger,
      AppColors.warning,
      Colors.deepOrange,
      Colors.purple,
      Colors.pink,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: entries.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        final color = colors[index % colors.length];

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${data.key} (${data.value})',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
