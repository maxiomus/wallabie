# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

August Chat (Wallabie) is a Flutter chat application with Firebase backend supporting real-time messaging, authentication, and multi-platform deployment (Android, iOS, Web, Windows, macOS, Linux).

## Common Commands

```bash
flutter pub get              # Install dependencies
flutter analyze              # Run linter (uses flutter_lints)
flutter test                 # Run all tests
flutter test path/to/test.dart  # Run single test file
flutter run                  # Run in debug mode
flutter build apk            # Build Android APK
flutter build ios            # Build iOS
flutter build web            # Build web
flutter build windows        # Build Windows
```

## Architecture

### State Management (Hybrid Approach)

- **Bloc** - Primary pattern for feature logic (auth, chat, rooms, users, profile)
- **Cubit** - Simpler state without events (HomeCubit for tab navigation)
- **Provider (ChangeNotifier)** - App-wide UI state (ThemeProvider, LocaleProvider)

### Folder Organization (Feature-based)

```
lib/
├── main.dart                # Entry point, Firebase init, repository setup
├── theme.dart               # Light/dark Material Design themes
├── firebase_options.dart    # Platform-specific Firebase config
├── app/                     # Root app config, auth routing, user profile
├── auth/                    # Auth state bloc
├── login/                   # Login feature (bloc + view)
├── register/                # Registration feature (bloc + view)
├── home/                    # Home/inbox with tab navigation
├── chat/                    # Chat conversation view
├── rooms/                   # Room list feature
├── users/                   # User list/picker
├── group/                   # Group creation
└── repositories/            # Data layer (Firebase interaction)
```

### Repository Layer

- `AuthRepository` - Firebase Auth, user document management
- `ChatRepository` - Rooms, messages, batch operations, deterministic room IDs
- `UserRepository` - In-memory user cache with Firestore streaming
- `ProfileRepository` - User preferences persistence (theme, locale)

### Data Flow

```
Widgets → Bloc/Cubit → Repository → Firebase (Firestore + Auth)
```

### Key Patterns

- **Bloc 9 syntax**: `on<Event>(_handler)` with `emit.onEach()` for streams
- **Stream handling**: Real-time Firestore snapshots throughout (chat, users, rooms)
- **Batch writes**: Messages + room metadata in single transaction
- **Deterministic direct room IDs**: Hash of sorted user IDs prevents duplicates
- **Theme/locale persistence**: Synced to Firestore via UserProfileBloc

### Firebase Collections

- `users/` - User profiles (name, email, imageUrl, timestamps)
- `rooms/` - Chat rooms (type, memberIds, name)
- `rooms/{id}/messages/` - Message documents

## Key Dependencies

- `flutter_bloc` / `bloc` - State management
- `firebase_core`, `firebase_auth`, `cloud_firestore` - Backend
- `firebase_ui_auth` - Pre-built auth screens
- `flutter_chat_ui`, `flutter_chat_core`, `flutter_firebase_chat_core` - Chat UI
- `google_sign_in` - OAuth
- `shared_preferences` - Local storage

## Localization

Supports English (en) and Korean (ko). Locale state managed via `LocaleProvider` (in `app/`) with Firebase UI integration.
