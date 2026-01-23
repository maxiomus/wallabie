part of 'settings_bloc.dart';

/// Base class for settings events.
sealed class SettingsEvent extends Equatable {
  /// Creates a [SettingsEvent].
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

/// Event to load initial settings.
final class SettingsStarted extends SettingsEvent {
  /// Creates a [SettingsStarted] event.
  const SettingsStarted();
}

/// Event to toggle notifications setting.
final class NotificationsToggled extends SettingsEvent {
  /// Creates a [NotificationsToggled] event.
  const NotificationsToggled();
}
