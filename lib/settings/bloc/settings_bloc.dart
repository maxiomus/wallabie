import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// Bloc that manages user settings state.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  /// Creates a [SettingsBloc].
  SettingsBloc() : super(const SettingsState()) {
    on<SettingsStarted>(_onStarted);
    on<NotificationsToggled>(_onNotificationsToggled);
  }

  Future<void> _onStarted(
    SettingsStarted event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));

    // Simulate loading settings
    await Future.delayed(const Duration(milliseconds: 500));

    emit(state.copyWith(
      status: SettingsStatus.loaded,
      notificationsEnabled: true,
    ));
  }

  void _onNotificationsToggled(
    NotificationsToggled event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(
      notificationsEnabled: !state.notificationsEnabled,
    ));
  }
}
