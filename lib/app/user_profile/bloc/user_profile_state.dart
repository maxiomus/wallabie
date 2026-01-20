part of 'user_profile_bloc.dart';

enum UserProfileLoadStatus { idle, loading, loaded, failure }
enum UserProfileSaveStatus { idle, saving, saved, failure }

final class UserProfileState extends Equatable {
  const UserProfileState({
    required this.userId,
    //required this.userName,
    required this.preference,
    this.loadStatus = UserProfileLoadStatus.idle,    
    this.saveStatus = UserProfileSaveStatus.idle,
    this.errorMessage,
    this.lastSyncedAt,
    this.isFromCache = false,
  });

  // Auth user id (from AppBloc → injected into bloc)
  final String userId;
  // Snapshot of auth displayName at initialization
  // (identity still belongs to FirebaseAuth)
  // final String userName;
  final UserPreference preference;

  final UserProfileLoadStatus loadStatus;
  final UserProfileSaveStatus saveStatus;

  final String? errorMessage;

  // When we last successfully wrote to Firestore (or confirmed stream update)
  final DateTime? lastSyncedAt;
  
  // True if current preference originated from local cache (before Firestore catches up)
  final bool isFromCache;

  bool get isLoading => loadStatus == UserProfileLoadStatus.loading;
  bool get isSaving => saveStatus == UserProfileSaveStatus.saving;

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
      //userName: userName,
      preference: preference ?? this.preference,
      loadStatus: loadStatus ?? this.loadStatus,
      saveStatus: saveStatus ?? this.saveStatus,
      errorMessage: errorMessage,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override  
  //List<Object?> get props => [darkMode, store];
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

