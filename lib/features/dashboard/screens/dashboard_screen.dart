import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/visitor_providers.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/visitor_card.dart';
import '../../visitors/screens/visitor_details_screen.dart';
import '../../visitors/screens/visitor_form_screen.dart';
import '../widgets/metric_card.dart';
import '../widgets/quick_actions.dart';

/// Staff Dashboard screen displaying live statistics calculated from API records,
/// shortcuts to primary actions, and recent activity.
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visitor Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'Front Desk & Security Portal',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Dashboard',
            onPressed: () => ref.read(visitorListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: visitorsState.when(
        loading: () => const LoadingView(message: 'Loading live visitor metrics...'),
        error: (err, _) => ErrorStateView(
          message: err.toString(),
          onRetry: () => ref.read(visitorListProvider.notifier).refresh(),
        ),
        data: (visitors) {
          return RefreshIndicator(
            onRefresh: () => ref.read(visitorListProvider.notifier).refresh(),
            color: AppColors.primaryNavy,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Configuration reminder banner if placeholder URL is active
                  if (AppConfig.isPlaceholderUrl) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.warningOrange.withValues(alpha: 0.5)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.warningOrange, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Using placeholder MockAPI URL. Configure API_BASE_URL in your .env file.',
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

                  // Header with today's local date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daily Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today, size: 12, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              DateFormatter.formatDate(DateTime.now()),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 1. Metric 1: Total Visitors Today
                  MetricCard(
                    title: 'Total Visitors Today',
                    count: metrics.totalToday,
                    subtitle: 'Registered on today\'s local date',
                    icon: Icons.groups_outlined,
                    accentColor: AppColors.primaryNavy,
                    iconBgColor: AppColors.surfaceMuted,
                    onTap: onNavigateToDirectory,
                  ),
                  const SizedBox(height: 8),

                  // 2. Metric 2: Currently Checked In
                  MetricCard(
                    title: 'Currently Checked In',
                    count: metrics.currentlyCheckedIn,
                    subtitle: 'Active on premises right now',
                    icon: Icons.login,
                    accentColor: AppColors.statusCheckedInText,
                    iconBgColor: AppColors.statusCheckedInBg,
                    onTap: onNavigateToDirectory,
                  ),
                  const SizedBox(height: 8),

                  // 3. Metric 3: Checked Out Today
                  MetricCard(
                    title: 'Checked Out Today',
                    count: metrics.checkedOutToday,
                    subtitle: 'Completed visits today',
                    icon: Icons.logout,
                    accentColor: AppColors.statusCheckedOutText,
                    iconBgColor: AppColors.statusCheckedOutBg,
                    onTap: onNavigateToDirectory,
                  ),
                  const SizedBox(height: 20),

                  // Quick Shortcuts Section
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
                  const SizedBox(height: 24),

                  // Recent Activity Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Visitors',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (visitors.isNotEmpty)
                        TextButton(
                          onPressed: onNavigateToDirectory,
                          child: const Text('View All'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Recent Visitors List
                  if (visitors.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: const Center(
                        child: Text(
                          'No visitor records yet. Use "Register" above to create the first record.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    ...visitors.take(4).map((visitor) {
                      return VisitorCard(
                        visitor: visitor,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  VisitorDetailsScreen(initialVisitor: visitor),
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
          );
        },
      ),
    );
  }
}
