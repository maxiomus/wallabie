
/// August Chat (Wallabie) - Main application entry point.
///
/// Initializes Firebase and sets up the repository layer before
/// launching the Flutter application.
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:august_chat/repositories/chat_repository.dart';
import 'package:august_chat/repositories/auth_repository.dart';
import 'package:august_chat/repositories/user_repository.dart';
import 'package:august_chat/repositories/profile_repostory.dart';
import 'package:august_chat/firebase_options.dart';
import 'package:august_chat/app/view/app.dart';
import 'package:provider/provider.dart';

import 'app/theme_provider.dart';
//import 'package:august_chat/auth/bloc/auth_bloc.dart';

/// Google OAuth client ID for authentication.
const clientId = '961092907782-6n40v5fmkc1bap5cck1uv42cjksmf2u4.apps.googleusercontent.com';

/// Application entry point.
///
/// Initializes Flutter bindings and Firebase before running the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  runApp(const MainApp(clientId: clientId));
}

/// Root widget that provides repositories to the widget tree.
///
/// Sets up [MultiRepositoryProvider] with all data repositories and
/// wraps the [App] widget for dependency injection throughout the app.
class MainApp extends StatelessWidget {
  /// Creates the main application widget.
  ///
  /// [clientId] is required for Google OAuth authentication.
  const MainApp({super.key, required this.clientId});

  /// Google OAuth client ID for authentication.
  final String clientId;

  @override
  Widget build(BuildContext context) {

    /*
    final initialBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    */
    
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => ChatRepository()),
        RepositoryProvider(create: (context) => ProfileRepository()),
        RepositoryProvider(create: (_) {
          final repo = UserRepository();
          repo.start();
          return repo;
        }),
      ],
      
      child: App(clientId: clientId),
    );
  }
}
