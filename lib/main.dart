
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

const clientId = '961092907782-6n40v5fmkc1bap5cck1uv42cjksmf2u4.apps.googleusercontent.com';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  runApp(const MainApp(clientId: clientId));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.clientId});

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
