import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DashboardStatus {
  loading,
  empty,
  error,
  loaded,
}

class DashboardData {
  final String connectedDevice;
  final String listeningDurationText;
  final String ambientLevelLabel;
  final String currentSessionDurationText;
  final String lastScreeningDateText;
  final String screeningResponseProfileSummary;

  const DashboardData({
    this.connectedDevice = 'Wireless Headphones',
    this.listeningDurationText = '2h 15m',
    this.ambientLevelLabel = 'Moderate (Level 2 of 5)',
    this.currentSessionDurationText = '45m',
    this.lastScreeningDateText = '3 days ago',
    this.screeningResponseProfileSummary =
        'Consistent relative sound response across speech frequencies (Levels 1–13).',
  });
}

class DashboardState {
  final DashboardStatus status;
  final DashboardData? data;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.loaded,
    this.data = const DashboardData(),
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardData? data,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier({DashboardStatus initialStatus = DashboardStatus.loaded})
      : super(DashboardState(
          status: initialStatus,
          data: initialStatus == DashboardStatus.loaded ? const DashboardData() : null,
        ));

  void loadDashboard() {
    state = state.copyWith(status: DashboardStatus.loading);
    state = const DashboardState(
      status: DashboardStatus.loaded,
      data: DashboardData(),
    );
  }

  void setStatus(DashboardStatus status) {
    if (status == DashboardStatus.loaded) {
      state = const DashboardState(status: DashboardStatus.loaded, data: DashboardData());
    } else if (status == DashboardStatus.error) {
      state = const DashboardState(
        status: DashboardStatus.error,
        errorMessage: 'Unable to sync recent listening metrics. Local sensor stream unavailable.',
      );
    } else if (status == DashboardStatus.empty) {
      state = const DashboardState(status: DashboardStatus.empty, data: null);
    } else {
      state = const DashboardState(status: DashboardStatus.loading, data: null);
    }
  }

  void retry() {
    loadDashboard();
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});
