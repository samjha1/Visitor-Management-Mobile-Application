import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/visitor_providers.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/visitor_card.dart';
import '../../visitors/screens/visitor_details_screen.dart';
import '../../visitors/screens/visitor_form_screen.dart';
import '../widgets/metric_card.dart';
import '../widgets/quick_actions.dart';

/// Redesigned Staff Dashboard displaying live visitor metrics, operational shortcuts,
/// and recent front-desk activity with responsive enterprise layout.
class DashboardScreen extends ConsumerWidget {
  final VoidCallback onNavigateToDirectory;
  final VoidCallback onNavigateToScanner;

  const DashboardScreen({
    super.key,
    required this.onNavigateToDirectory,
    required this.onNavigateToScanner,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitorsState = ref.watch(visitorListProvider);
    final metrics = ref.watch(dashboardMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.accentTeal.withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.domain_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Visitor Management',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    'Security & Front Desk Portal',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Data',
            onPressed: () => ref.read(visitorListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: visitorsState.when(
        loading: () =>
            const LoadingView(message: 'Loading live visitor metrics...'),
        error: (err, _) => ErrorStateView(
          message: err.toString(),
          onRetry: () => ref.read(visitorListProvider.notifier).refresh(),
        ),
        data: (visitors) {
          return RefreshIndicator(
            onRefresh: () => ref.read(visitorListProvider.notifier).refresh(),
            color: AppColors.primaryNavy,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppTheme.maxContentWidth,
                ),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Configuration banner if placeholder MockAPI URL is active
                      if (AppConfig.isPlaceholderUrl) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warningLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.warningBorder),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.warningOrange,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Using placeholder MockAPI URL. Set API_BASE_URL in your .env file to persist live data.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Operational Welcome Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Overview',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                'Today\'s activity summary',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 13,
                                  color: AppColors.accentTeal,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormatter.formatDate(DateTime.now()),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Metric 1: Total Visitors Today
                      DashboardStatCard(
                        title: 'Total Visitors Today',
                        count: metrics.totalToday,
                        subtitle: 'Registered on today\'s local date',
                        icon: Icons.groups_rounded,
                        accentColor: AppColors.primaryNavy,
                        iconBgColor: AppColors.surfaceMuted,
                        onTap: onNavigateToDirectory,
                      ),
                      const SizedBox(height: 8),

                      // Metric 2: Currently Checked In
                      DashboardStatCard(
                        title: 'Currently Checked In',
                        count: metrics.currentlyCheckedIn,
                        subtitle: 'Active on premises right now',
                        icon: Icons.login_rounded,
                        accentColor: AppColors.statusCheckedInText,
                        iconBgColor: AppColors.statusCheckedInBg,
                        onTap: onNavigateToDirectory,
                      ),
                      const SizedBox(height: 8),

                      // Metric 3: Checked Out Today
                      DashboardStatCard(
                        title: 'Checked Out Today',
                        count: metrics.checkedOutToday,
                        subtitle: 'Completed visits today',
                        icon: Icons.logout_rounded,
                        accentColor: AppColors.statusCheckedOutText,
                        iconBgColor: AppColors.statusCheckedOutBg,
                        onTap: onNavigateToDirectory,
                      ),
                      const SizedBox(height: 16),

                      // Staff Operations / Quick Actions
                      QuickActions(
                        onRegister: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const VisitorFormScreen(),
                            ),
                          );
                        },
                        onDirectory: onNavigateToDirectory,
                        onScan: onNavigateToScanner,
                      ),
                      const SizedBox(height: 16),

                      // Recent Visitors Section
                      SectionHeader(
                        title: 'Recent Activity',
                        subtitle: 'Latest registered visitor records',
                        actionLabel: visitors.isNotEmpty ? 'View All' : null,
                        onAction: visitors.isNotEmpty
                            ? onNavigateToDirectory
                            : null,
                      ),
                      const SizedBox(height: 4),

                      // Recent Visitors List or Empty state
                      if (visitors.isEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 28,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.badge_outlined,
                                  size: 32,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No visitor records yet',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Tap "Register Visitor" above to create the first pass.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        ...visitors.take(4).map((visitor) {
                          return VisitorCard(
                            visitor: visitor,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => VisitorDetailsScreen(
                                    initialVisitor: visitor,
                                  ),
                                ),
                              );
                            },
                            onEdit: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      VisitorFormScreen(visitorToEdit: visitor),
                                ),
                              );
                            },
                            onDelete: () async {
                              await ref
                                  .read(visitorListProvider.notifier)
                                  .deleteVisitor(visitor.id);
                            },
                          );
                        }),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
