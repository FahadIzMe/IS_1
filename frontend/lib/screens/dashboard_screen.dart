import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/constants.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/statistics_card.dart';
import '../widgets/attack_pie_chart.dart';
import '../widgets/live_feed_widget.dart';

/// Main Dashboard Screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            slivers: [
              // App Bar
              _buildAppBar(provider),
              
              // Main Content
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Connection status
                    if (!provider.isConnected) _buildConnectionWarning(),
                    
                    const SizedBox(height: 20),
                    
                    // Statistics Cards
                    _buildStatisticsCards(provider),
                    
                    const SizedBox(height: 24),
                    
                    // Charts and Feed Row
                    _buildChartsAndFeed(provider),
                    
                    const SizedBox(height: 24),
                    
                    // Control Button
                    _buildControlButton(provider),
                    
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(DashboardProvider provider) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final isExpanded = constraints.maxHeight > 80;
          final width = MediaQuery.of(context).size.width;
          final fontSize = width < 600 ? 18.0 : (width < 900 ? 20.0 : 24.0);
          final iconSize = width < 600 ? 20.0 : 28.0;
          
          return FlexibleSpaceBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shield,
                  color: AppColors.accent,
                  size: iconSize,
                ),
                const SizedBox(width: 8),
                Text(
                  'IS Dashboard',
                  style: GoogleFonts.orbitron(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            centerTitle: true,
          );
        },
      ),
      actions: [
        // Status indicator
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: provider.isMonitoring
                      ? Colors.green
                      : Colors.grey,
                  shape: BoxShape.circle,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(duration: 500.ms)
                  .fadeOut(duration: 500.ms),
              const SizedBox(width: 8),
              Text(
                provider.isMonitoring ? 'ACTIVE' : 'IDLE',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: provider.isMonitoring
                      ? Colors.green
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: AppColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Backend connection unavailable. Please ensure the server is running.',
              style: GoogleFonts.inter(
                color: AppColors.danger,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(DashboardProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive columns: 1 for mobile, 2 for tablet, 4 for desktop
        final width = constraints.maxWidth;
        final columns = width < 600 ? 1 : (width < 900 ? 2 : 4);
        final cardWidth = (constraints.maxWidth - (16 * (columns - 1))) / columns;
        
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: cardWidth,
              child: StatisticsCard(
                title: 'Total Analyzed',
                value: provider.totalAnalyzed.toString(),
                icon: Icons.analytics,
                color: AppColors.accent,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatisticsCard(
                title: 'Benign Traffic',
                value: provider.benignCount.toString(),
                icon: Icons.check_circle,
                color: AppColors.success,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatisticsCard(
                title: 'Threats Detected',
                value: provider.threatCount.toString(),
                icon: Icons.warning,
                color: AppColors.danger,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatisticsCard(
                title: 'Threat Rate',
                value: '${provider.threatPercentage.toStringAsFixed(1)}%',
                icon: Icons.trending_up,
                color: AppColors.warning,
                subtitle: provider.threatPercentage > 20 ? 'HIGH' : 'NORMAL',
              ),
            ),
          ],
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0);
      },
    );
  }

  Widget _buildChartsAndFeed(DashboardProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;
        
        if (isMobile) {
          // Stack vertically on mobile
          return Column(
            children: [
              // Attack Distribution Chart
              Container(
                height: 400,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attack Distribution',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: provider.statistics.byClass.isEmpty
                          ? Center(
                              child: Text(
                                'No data yet. Start monitoring to see distribution.',
                                style: GoogleFonts.inter(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : AttackPieChart(
                              distribution: provider.statistics.byClass,
                            ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              
              const SizedBox(height: 16),
              
              // Recent Threats Feed
              Container(
                height: 400,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.danger.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Recent Threats',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (provider.recentThreats.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${provider.recentThreats.length}',
                              style: GoogleFonts.inter(
                                color: AppColors.danger,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: LiveFeedWidget(threats: provider.recentThreats),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
            ],
          );
        }
        
        // Side by side on desktop/tablet
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Attack Distribution Chart
            Expanded(
              flex: 2,
              child: Container(
                height: 400,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attack Distribution',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: provider.statistics.byClass.isEmpty
                          ? Center(
                              child: Text(
                                'No data yet. Start monitoring to see distribution.',
                                style: GoogleFonts.inter(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : AttackPieChart(
                              distribution: provider.statistics.byClass,
                            ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
            ),
            
            const SizedBox(width: 16),
            
            // Recent Threats Feed
            Expanded(
              flex: 2,
              child: Container(
                height: 400,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.danger.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Recent Threats',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (provider.recentThreats.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${provider.recentThreats.length}',
                              style: GoogleFonts.inter(
                                color: AppColors.danger,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: LiveFeedWidget(threats: provider.recentThreats),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlButton(DashboardProvider provider) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: provider.isMonitoring
            ? () => provider.stopMonitoring()
            : () => provider.startMonitoring(),
        icon: Icon(
          provider.isMonitoring ? Icons.pause : Icons.play_arrow,
          size: 28,
        ),
        label: Text(
          provider.isMonitoring ? 'STOP MONITORING' : 'START MONITORING',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: provider.isMonitoring
              ? AppColors.danger
              : AppColors.success,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
        ),
      ).animate(onPlay: (controller) => controller.repeat())
          .shimmer(delay: 2000.ms, duration: 1000.ms),
    );
  }
}
