import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/visitor.dart';
import '../../../providers/visitor_providers.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/visitor_card.dart';
import 'visitor_details_screen.dart';
import 'visitor_form_screen.dart';

/// Screen displaying the searchable list of visitors with pull-to-refresh,
/// detail navigation, editing, and deletion.
class VisitorListScreen extends ConsumerStatefulWidget {
  const VisitorListScreen({super.key});

  @override
  ConsumerState<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends ConsumerState<VisitorListScreen> {
  final TextEditingController _searchController = TextEditingController();

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.read(visitorListProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const VisitorFormScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text(
          'Register',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name, mobile, or project...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: currentQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: _clearSearch,
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                filled: true,
                fillColor: AppColors.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primaryNavy, width: 1.5),
                ),
              ),
            ),
          ),
          const Divider(height: 1),

          // Visitor List / State Views
          Expanded(
            child: filteredState.when(
              data: (visitors) {
                if (visitors.isEmpty) {
                  if (currentQuery.isNotEmpty) {
                    return EmptyStateView(
                      icon: Icons.search_off,
                      title: 'No Matching Visitors',
                      message: 'No visitor records found matching "$currentQuery".',
                      actionLabel: 'Clear Search',
                      onAction: _clearSearch,
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
                  onRefresh: () => ref.read(visitorListProvider.notifier).refresh(),
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
                        onDelete: () => _handleDelete(visitor),
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingView(message: 'Loading visitor records...'),
              error: (err, _) => ErrorStateView(
                message: err.toString(),
                onRetry: () => ref.read(visitorListProvider.notifier).refresh(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
