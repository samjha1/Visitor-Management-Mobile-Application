import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/visitor.dart';
import '../../../providers/visitor_providers.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/visitor_card.dart';
import 'visitor_details_screen.dart';
import 'visitor_form_screen.dart';

/// Screen displaying the searchable and filterable directory of visitors.
class VisitorListScreen extends ConsumerStatefulWidget {
  const VisitorListScreen({super.key});

  @override
  ConsumerState<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends ConsumerState<VisitorListScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _statusFilters = [
    'All',
    AppConstants.statusRegistered,
    AppConstants.statusCheckedIn,
    AppConstants.statusCheckedOut,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(visitorSearchQueryProvider.notifier).setQuery(value);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(visitorSearchQueryProvider.notifier).clear();
  }

  void _resetAllFilters() {
    _clearSearch();
    ref.read(visitorStatusFilterProvider.notifier).reset();
  }

  Future<void> _handleDelete(Visitor visitor) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Visitor',
      message:
          'Are you sure you want to delete ${visitor.name}? This will remove the record from the server.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (!confirmed || !mounted) return;

    try {
      await ref.read(visitorListProvider.notifier).deleteVisitor(visitor.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${visitor.name} was deleted successfully.'),
            backgroundColor: AppColors.primaryNavy,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredState = ref.watch(filteredVisitorsProvider);
    final currentQuery = ref.watch(visitorSearchQueryProvider);
    final activeStatusFilter = ref.watch(visitorStatusFilterProvider);
    final allVisitorsCount = ref.watch(visitorListProvider).value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Visitor Directory'),
            Text(
              '$allVisitorsCount total records in system',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.read(visitorListProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const VisitorFormScreen()));
        },
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          'Register',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
          child: Column(
            children: [
              // 1. Search Bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                color: Colors.white,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by name, mobile, or project...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    suffixIcon: currentQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: _clearSearch,
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceMuted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.accentTeal,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Status Filter Chips Row
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _statusFilters.map((filter) {
                      final isSelected = activeStatusFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(filter),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                          backgroundColor: AppColors.surfaceMuted,
                          selectedColor: AppColors.primaryNavy,
                          checkmarkColor: Colors.white,
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primaryNavy
                                  : AppColors.borderLight,
                            ),
                          ),
                          onSelected: (_) {
                            ref
                                .read(visitorStatusFilterProvider.notifier)
                                .setFilter(filter);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const Divider(height: 1),

              // 3. Visitor List / Feedback States
              Expanded(
                child: filteredState.when(
                  data: (visitors) {
                    if (visitors.isEmpty) {
                      if (currentQuery.isNotEmpty ||
                          activeStatusFilter != 'All') {
                        return EmptyStateView(
                          icon: Icons.search_off_rounded,
                          title: 'No Matching Visitors',
                          message:
                              'No visitor records found matching the active search or status filters.',
                          actionLabel: 'Reset Filters',
                          onAction: _resetAllFilters,
                        );
                      }
                      return EmptyStateView(
                        icon: Icons.group_outlined,
                        title: 'No Visitors Registered Yet',
                        message:
                            'Register a new visitor at the front desk to generate their QR pass and start tracking.',
                        actionLabel: 'Register First Visitor',
                        onAction: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const VisitorFormScreen(),
                            ),
                          );
                        },
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () =>
                          ref.read(visitorListProvider.notifier).refresh(),
                      color: AppColors.primaryNavy,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: visitors.length,
                        itemBuilder: (context, index) {
                          final visitor = visitors[index];
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
                            onDelete: () => _handleDelete(visitor),
                          );
                        },
                      ),
                    );
                  },
                  loading: () =>
                      const LoadingView(message: 'Loading visitor records...'),
                  error: (err, _) => ErrorStateView(
                    message: err.toString(),
                    onRetry: () =>
                        ref.read(visitorListProvider.notifier).refresh(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
