part of 'user_profile_bloc.dart';

/// Status of preference loading from Firestore/cache.
enum UserProfileLoadStatus {
  /// Initial state, loading not started.
  idle,

  /// Preferences are being loaded.
  loading,

  /// Preferences loaded successfully.
  loaded,

  /// Failed to load preferences.
  failure,
}

/// Status of preference saving to Firestore.
enum UserProfileSaveStatus {
  /// No save in progress.
  idle,

  /// Save is in progress.
  saving,

  /// Save completed successfully.
  saved,

  /// Save failed.
  failure,
}

/// State of the user profile with preferences and sync status.
final class UserProfileState extends Equatable {
  /// Creates a [UserProfileState] with required fields.
  const UserProfileState({
    required this.userId,
    required this.preference,
    this.loadStatus = UserProfileLoadStatus.idle,
    this.saveStatus = UserProfileSaveStatus.idle,
    this.errorMessage,
    this.lastSyncedAt,
    this.isFromCache = false,
  });

  /// Auth user ID from Firebase Auth.
  final String userId;

  /// Current user preferences.
  final UserPreference preference;

  /// Current loading status.
  final UserProfileLoadStatus loadStatus;

  /// Current save status.
  final UserProfileSaveStatus saveStatus;

  /// Error message if load or save failed.
  final String? errorMessage;

  /// Timestamp of last successful Firestore sync.
  final DateTime? lastSyncedAt;

  /// True if preferences are from local cache (before Firestore sync).
  final bool isFromCache;

  /// Returns true if preferences are currently loading.
  bool get isLoading => loadStatus == UserProfileLoadStatus.loading;

  /// Returns true if preferences are currently being saved.
  bool get isSaving => saveStatus == UserProfileSaveStatus.saving;

  /// Creates a copy of this state with the given fields replaced.
  UserProfileState copyWith({
    UserPreference? preference,
    UserProfileLoadStatus? loadStatus,
    UserProfileSaveStatus? saveStatus,
    String? errorMessage,
    DateTime? lastSyncedAt,
    bool? isFromCache,
  }) {
    return UserProfileState(
      userId: userId,
      preference: preference ?? this.preference,
      loadStatus: loadStatus ?? this.loadStatus,
      saveStatus: saveStatus ?? this.saveStatus,
      errorMessage: errorMessage,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    preference,
    loadStatus,
    saveStatus,
    errorMessage,
    lastSyncedAt,
    isFromCache,
  ];
}

