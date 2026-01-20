part of 'user_profile_bloc.dart';

@immutable
sealed class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

// Load preferences from Firestore
final class UserProfileStarted extends UserProfileEvent {
  //final String userId;

  const UserProfileStarted();  
}

final class UserProfilePreferenceLoaded  extends UserProfileEvent {
  final UserPreference preference;

  const UserProfilePreferenceLoaded (this.preference);

  @override
  List<Object?> get props => [preference];
}

final class UserProfilePreferenceUpdated extends UserProfileEvent {
  final String? userName;
  final ThemeMode? themeMode;

  const UserProfilePreferenceUpdated({
    this.userName,
    this.themeMode,
  });

  @override  
  List<Object?> get props => [userName, themeMode];
}

final class UserProfilePersistRequested extends UserProfileEvent {
  final UserPreference preference;

  const UserProfilePersistRequested(this.preference);

  @override
  List<Object?> get props => [preference];
}

final class UserProfileThemeModeChanged  extends UserProfileEvent {
  //final String userId;
  final ThemeMode themeMode;

  const UserProfileThemeModeChanged (this.themeMode);

  @override  
  List<Object?> get props => [themeMode];
}

final class UserProfileThemeModeToggled  extends UserProfileEvent {
  const UserProfileThemeModeToggled ();

  @override
  List<Object?> get props => [];
}

final class UserProfileLocaleChanged  extends UserProfileEvent {
  final String locale;
  
  const UserProfileLocaleChanged (this.locale);

  @override
  List<Object?> get props => [locale];
}