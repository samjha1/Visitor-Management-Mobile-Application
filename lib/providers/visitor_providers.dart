import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/date_formatter.dart';
import '../data/visitor_repository.dart';
import '../models/visitor.dart';

/// Provider for the VisitorRepository instance.
final visitorRepositoryProvider = Provider<VisitorRepository>((ref) {
  return VisitorRepository();
});

/// Notifier managing search query state for filtering visitors in the visitor list.
class VisitorSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
  void clear() => state = '';
}

/// Search query provider for filtering visitors in the directory.
final visitorSearchQueryProvider =
    NotifierProvider<VisitorSearchQueryNotifier, String>(
      VisitorSearchQueryNotifier.new,
    );

/// Notifier managing status filter ('All', 'Registered', 'Checked In', 'Checked Out').
class VisitorStatusFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void setFilter(String filter) => state = filter;
  void reset() => state = 'All';
}

/// Status filter provider for directory screen.
final visitorStatusFilterProvider =
    NotifierProvider<VisitorStatusFilterNotifier, String>(
      VisitorStatusFilterNotifier.new,
    );

/// Model representing the calculated dashboard metrics.
class DashboardMetrics {
  final int totalToday;
  final int currentlyCheckedIn;
  final int checkedOutToday;
  final int totalAllTime;

  const DashboardMetrics({
    required this.totalToday,
    required this.currentlyCheckedIn,
    required this.checkedOutToday,
    required this.totalAllTime,
  });

  factory DashboardMetrics.empty() {
    return const DashboardMetrics(
      totalToday: 0,
      currentlyCheckedIn: 0,
      checkedOutToday: 0,
      totalAllTime: 0,
    );
  }
}

/// State notifier managing the synchronized collection of visitors.
class VisitorListNotifier extends AsyncNotifier<List<Visitor>> {
  @override
  Future<List<Visitor>> build() async {
    final repository = ref.read(visitorRepositoryProvider);
    return await repository.getAllVisitors();
  }

  /// Manually refresh visitors list from the REST API.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(visitorRepositoryProvider);
      return await repository.getAllVisitors();
    });
  }

  /// Perform check-in and update shared application state upon API success.
  Future<Visitor> checkIn(Visitor visitor) async {
    final repository = ref.read(visitorRepositoryProvider);
    final updated = await repository.checkIn(visitor);

    // Update list state with confirmed API record
    state = state.whenData((list) {
      final index = list.indexWhere((v) => v.id == updated.id);
      if (index != -1) {
        final newList = List<Visitor>.from(list);
        newList[index] = updated;
        return newList;
      }
      return [updated, ...list];
    });

    return updated;
  }

  /// Perform check-out and update shared application state upon API success.
  Future<Visitor> checkOut(Visitor visitor) async {
    final repository = ref.read(visitorRepositoryProvider);
    final updated = await repository.checkOut(visitor);

    // Update list state with confirmed API record
    state = state.whenData((list) {
      final index = list.indexWhere((v) => v.id == updated.id);
      if (index != -1) {
        final newList = List<Visitor>.from(list);
        newList[index] = updated;
        return newList;
      }
      return [updated, ...list];
    });

    return updated;
  }

  /// Register visitor and prepend to list upon API confirmation.
  Future<Visitor> registerVisitor({
    required String name,
    required String mobile,
    String? email,
    required String visitorType,
    required String project,
    required String purpose,
  }) async {
    final repository = ref.read(visitorRepositoryProvider);
    final created = await repository.registerVisitor(
      name: name,
      mobile: mobile,
      email: email,
      visitorType: visitorType,
      project: project,
      purpose: purpose,
    );

    // Update state with newly created visitor
    state = state.whenData((list) => [created, ...list]);

    return created;
  }

  /// Edit visitor details and update list upon API confirmation.
  Future<Visitor> updateVisitorProfile({
    required String id,
    required String name,
    required String mobile,
    String? email,
    required String visitorType,
    required String project,
    required String purpose,
    required Visitor originalVisitor,
  }) async {
    final repository = ref.read(visitorRepositoryProvider);
    final updated = await repository.updateVisitorProfile(
      id: id,
      name: name,
      mobile: mobile,
      email: email,
      visitorType: visitorType,
      project: project,
      purpose: purpose,
      originalVisitor: originalVisitor,
    );

    state = state.whenData((list) {
      final index = list.indexWhere((v) => v.id == id);
      if (index != -1) {
        final newList = List<Visitor>.from(list);
        newList[index] = updated;
        return newList;
      }
      return [updated, ...list];
    });

    return updated;
  }

  /// Delete visitor and remove from state upon API confirmation.
  Future<void> deleteVisitor(String id) async {
    final repository = ref.read(visitorRepositoryProvider);
    await repository.deleteVisitor(id);

    state = state.whenData((list) => list.where((v) => v.id != id).toList());
  }

  /// Directly fetch latest data for a single visitor and sync into list.
  Future<Visitor> fetchAndSyncVisitor(String id) async {
    final repository = ref.read(visitorRepositoryProvider);
    final visitor = await repository.getVisitorById(id);

    state = state.whenData((list) {
      final index = list.indexWhere((v) => v.id == id);
      if (index != -1) {
        final newList = List<Visitor>.from(list);
        newList[index] = visitor;
        return newList;
      }
      return [visitor, ...list];
    });

    return visitor;
  }
}

/// Main visitor list provider.
final visitorListProvider =
    AsyncNotifierProvider<VisitorListNotifier, List<Visitor>>(
      VisitorListNotifier.new,
    );

/// Provider for filtered visitor records based on search query (name or mobile) and status filter.
final filteredVisitorsProvider = Provider<AsyncValue<List<Visitor>>>((ref) {
  final asyncVisitors = ref.watch(visitorListProvider);
  final query = ref.watch(visitorSearchQueryProvider).trim().toLowerCase();
  final statusFilter = ref.watch(visitorStatusFilterProvider);

  return asyncVisitors.whenData((visitors) {
    return visitors.where((visitor) {
      if (statusFilter != 'All' && visitor.status != statusFilter) {
        return false;
      }

      if (query.isNotEmpty) {
        final nameMatches = visitor.name.toLowerCase().contains(query);
        final mobileMatches = visitor.mobile.toLowerCase().contains(query);
        final projectMatches = visitor.project.toLowerCase().contains(query);
        return nameMatches || mobileMatches || projectMatches;
      }

      return true;
    }).toList();
  });
});

/// Provider for calculating dashboard metrics based on today's local date.
final dashboardMetricsProvider = Provider<DashboardMetrics>((ref) {
  final asyncVisitors = ref.watch(visitorListProvider);

  return asyncVisitors.when(
    data: (visitors) {
      int totalToday = 0;
      int currentlyCheckedIn = 0;
      int checkedOutToday = 0;

      for (final visitor in visitors) {
        // Metric 1: Total Visitors Today (created_at on today's local date)
        if (DateFormatter.isToday(visitor.createdAt)) {
          totalToday++;
        }

        // Metric 2: Currently Checked In (status == Checked In)
        if (visitor.status == AppConstants.statusCheckedIn) {
          currentlyCheckedIn++;
        }

        // Metric 3: Checked Out Today (check_out_time on today's local date)
        if (visitor.checkOutTime != null &&
            DateFormatter.isToday(visitor.checkOutTime)) {
          checkedOutToday++;
        }
      }

      return DashboardMetrics(
        totalToday: totalToday,
        currentlyCheckedIn: currentlyCheckedIn,
        checkedOutToday: checkedOutToday,
        totalAllTime: visitors.length,
      );
    },
    loading: () => DashboardMetrics.empty(),
    error: (err, stack) => DashboardMetrics.empty(),
  );
});
