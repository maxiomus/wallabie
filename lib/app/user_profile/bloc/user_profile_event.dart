part of 'user_profile_bloc.dart';

/// Base class for user profile events.
@immutable
sealed class UserProfileEvent extends Equatable {
  /// Creates a [UserProfileEvent].
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize user profile loading.
///
/// Loads from cache first, then starts Firestore stream.
final class UserProfileStarted extends UserProfileEvent {
  /// Creates a [UserProfileStarted] event.
  const UserProfileStarted();
}

/// Event when preferences are loaded from Firestore stream.
final class UserProfilePreferenceLoaded extends UserProfileEvent {
  /// The loaded user preferences.
  final UserPreference preference;

  /// Creates a [UserProfilePreferenceLoaded] event.
  const UserProfilePreferenceLoaded(this.preference);

  @override
  List<Object?> get props => [preference];
}

/// Event when user updates profile fields.
final class UserProfilePreferenceUpdated extends UserProfileEvent {
  /// New user name, if changed.
  final String? userName;

  /// New theme mode, if changed.
  final ThemeMode? themeMode;

  /// Creates a [UserProfilePreferenceUpdated] event.
  const UserProfilePreferenceUpdated({
    this.userName,
    this.themeMode,
  });

  @override
  List<Object?> get props => [userName, themeMode];
}

/// Internal event to persist preferences to Firestore.
final class UserProfilePersistRequested extends UserProfileEvent {
  /// The preferences to persist.
  final UserPreference preference;

  /// Creates a [UserProfilePersistRequested] event.
  const UserProfilePersistRequested(this.preference);

  @override
  List<Object?> get props => [preference];
}

/// Event when user changes the theme mode.
final class UserProfileThemeModeChanged extends UserProfileEvent {
  /// The new theme mode.
  final ThemeMode themeMode;

  /// Creates a [UserProfileThemeModeChanged] event.
  const UserProfileThemeModeChanged(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

/// Event to toggle between light and dark theme.
final class UserProfileThemeModeToggled extends UserProfileEvent {
  /// Creates a [UserProfileThemeModeToggled] event.
  const UserProfileThemeModeToggled();

  @override
  List<Object?> get props => [];
}

/// Event when user changes the locale.
final class UserProfileLocaleChanged extends UserProfileEvent {
  /// The new locale tag (e.g., 'en', 'ko').
  final String locale;

  /// Creates a [UserProfileLocaleChanged] event.
  const UserProfileLocaleChanged(this.locale);

  @override
  List<Object?> get props => [locale];
}