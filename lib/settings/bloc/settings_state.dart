part of 'settings_bloc.dart';

/// Status of the settings loading process.
enum SettingsStatus {
  /// Initial state, no action taken.
  idle,

  /// Settings are being loaded.
  loading,

  /// Settings loaded successfully.
  loaded,

  /// Failed to load settings.
  failure,
}

/// State of the settings screen.
class SettingsState extends Equatable {
  /// Creates a [SettingsState] with optional parameters.
  const SettingsState({
    this.status = SettingsStatus.idle,
    this.notificationsEnabled = false,
    this.errorMessage,
  });

  /// Current loading status.
  final SettingsStatus status;

  /// Whether notifications are enabled.
  final bool notificationsEnabled;

  /// Error message if loading failed.
  final String? errorMessage;

  /// Creates a copy of this state with the given fields replaced.
  SettingsState copyWith({
    SettingsStatus? status,
    bool? notificationsEnabled,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notificationsEnabled, errorMessage];
}
