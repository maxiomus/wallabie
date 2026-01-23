import 'dart:async';

import 'package:august_chat/repositories/profile_repostory.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_preference.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

/// Bloc that manages user preferences with offline-first sync.
///
/// Loads preferences from local cache first for instant UI, then syncs
/// with Firestore. Changes are debounced before persisting to reduce writes.
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final ProfileRepository _profileRepository;
  StreamSubscription<UserPreference>? _sub;
  Timer? _debounce;

  /// Creates a [UserProfileBloc] for the given Firebase [user].
  UserProfileBloc({
    required User user,
    required ProfileRepository profileRepository,
  }) : _profileRepository = profileRepository,
    super(UserProfileState(
        userId: user.uid,
        preference: UserPreference(userId: user.uid),
      )) {

    on<UserProfileStarted>(_onStarted);
    on<UserProfilePreferenceLoaded>(_onLoaded);
    on<UserProfilePreferenceUpdated>(_onUpdated);
    on<UserProfileThemeModeChanged>(_onThemeModeChanged);
    on<UserProfileThemeModeToggled>(_onThemeModeToggled);
    on<UserProfileLocaleChanged>(_onLocaleChanged);
    on<UserProfileNotificationsToggled>(_onNotificationsToggled);
    on<UserProfilePersistRequested>(_onPersistRequested);
  }

  Future<void> _onStarted(UserProfileStarted event, Emitter<UserProfileState> emit) async {
    
    emit(state.copyWith(loadStatus: UserProfileLoadStatus.loading));

    // 1. load cache immediately (offline-first)
    final cached = await _profileRepository.getCached(state.userId);

    if(cached != null) {
      emit(state.copyWith(
        preference: cached,
        loadStatus: UserProfileLoadStatus.loaded,
        isFromCache: true,
      ));
    } else {
      // ensure UI does not stay stuck
      emit(state.copyWith(
        loadStatus: UserProfileLoadStatus.loaded,
      ));
    }

    // Create preference doc if missing (First time)
    final exist = await _profileRepository.exists(state.userId);
    if(!exist) {            

      await _profileRepository.savePreference(
        // Initial preference
        UserPreference(
          userId: state.userId,
          userName: state.preference.userName,
        ),
      );
    }

    // 2. Start Firestore stream (source of truth)
    await _sub?.cancel();
    _sub = _profileRepository.watchPreference(state.userId).listen(
      (pref) {
        add(UserProfilePreferenceLoaded(pref));
      },
      onError: (e) {
        if(emit.isDone) return;

        emit(state.copyWith(
          loadStatus: UserProfileLoadStatus.failure,
          errorMessage: e.toString(),
        ));
      },
    );    
  }

  Future<void> _onLoaded(
    UserProfilePreferenceLoaded event,
    Emitter<UserProfileState> emit,
  ) async {

    // Firestore wins; also refresh cache
    await _profileRepository.saveCached(event.preference);

    emit(state.copyWith(
      preference: event.preference,
      loadStatus: UserProfileLoadStatus.loaded,
      saveStatus: UserProfileSaveStatus.idle,
      errorMessage: null,
      lastSyncedAt: DateTime.now(),      
    ));
  }

  Future<void> _onUpdated(
    UserProfilePreferenceUpdated event,
    Emitter<UserProfileState> emit,
  ) async {

    final next = state.preference.copyWith(
      userName: event.userName,      
      themeMode: event.themeMode,
      updatedAt: DateTime.now(),
    );

    // Update UI immediately
    emit(state.copyWith(
      preference: next,
      saveStatus: UserProfileSaveStatus.saving,
      errorMessage: null,
    ));

    // Write to local cache immediately (offline-first feel)
    await _profileRepository.saveCached(next);

    // Debounce Firestore save
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if(!isClosed) {
        add(UserProfilePersistRequested(next));
      }
    });
  }

  Future<void> _onThemeModeChanged(UserProfileThemeModeChanged event, Emitter<UserProfileState> emit) async {

    final updated = state.preference.copyWith(
      themeMode: event.themeMode,
      updatedAt: DateTime.now(),
    );
    //final userId = event.userId;

    // Update UI immediately
    emit(state.copyWith(
      preference: updated,
      saveStatus: UserProfileSaveStatus.saving,
      errorMessage: null,
    ));

    // Save to local cache (offline-first)
    await _profileRepository.saveCached(updated);

    // 3️⃣ Debounce remote save
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!isClosed) {
        add(UserProfilePersistRequested(updated));
      }
    });
  }  

  Future<void> _onLocaleChanged(UserProfileLocaleChanged event, Emitter<UserProfileState> emit) async {
    final updated = state.preference.copyWith(
      locale: event.locale,
      updatedAt: DateTime.now(),
    );

    emit(state.copyWith(
      preference: updated,
      saveStatus: UserProfileSaveStatus.saving,
      errorMessage: null,
    ));

    await _profileRepository.saveCached(updated);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!isClosed) {
        add(UserProfilePersistRequested(updated));
      }
    });
  }

  Future<void> _onNotificationsToggled(
    UserProfileNotificationsToggled event,
    Emitter<UserProfileState> emit,
  ) async {
    final updated = state.preference.copyWith(
      notificationsEnabled: !state.preference.notificationsEnabled,
      updatedAt: DateTime.now(),
    );

    emit(state.copyWith(
      preference: updated,
      saveStatus: UserProfileSaveStatus.saving,
      errorMessage: null,
    ));

    await _profileRepository.saveCached(updated);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!isClosed) {
        add(UserProfilePersistRequested(updated));
      }
    });
  }

  Future<void> _onPersistRequested(
    UserProfilePersistRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    try {

      await _profileRepository.savePreference(event.preference);

      if (emit.isDone) return;

      emit(state.copyWith(
        saveStatus: UserProfileSaveStatus.saved,
        lastSyncedAt: DateTime.now(),
        isFromCache: false,
      ));
    } catch (e) {
      if (emit.isDone) return;

      emit(state.copyWith(
        saveStatus: UserProfileSaveStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onThemeModeToggled(
    UserProfileThemeModeToggled event,
    Emitter<UserProfileState> emit,
  ) async {
    final current = state.preference.themeMode;

    // Choose your cycle; Kakao-style apps usually just flip light/dark.
    final next = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

    add(UserProfileThemeModeChanged(next));
  }

  @override
  Future<void> close() async {
    _debounce?.cancel();
    await _sub?.cancel();
    return super.close();
  }
}
