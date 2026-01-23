import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:august_chat/app/theme_provider.dart';
import '../../home/cubit/home_cubit.dart';
import '../../home/view/home_page.dart';
import '../../repositories/profile_repostory.dart';
import '../locale_provider.dart';
import '../user_profile/bloc/user_profile_bloc.dart';
import '../../theme.dart';

/// Root application widget that handles authentication routing.
///
/// Shows sign-in screen when unauthenticated, home screen when authenticated.
/// Sets up blocs and providers for the authenticated app.
class App extends StatelessWidget {
  /// Creates the [App] widget with required OAuth client ID.
  const App({super.key, required this.clientId});

  /// Google OAuth client ID for authentication.
  final String clientId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // loading state while Firebase resolves auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        if (snapshot.data == null) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.system,
            home: SignInScreen(
              showAuthActionSwitch: false,
              showPasswordVisibilityToggle: true,
              providers: [
                EmailAuthProvider(),
                GoogleProvider(clientId: clientId),
              ],
              headerBuilder: (context, constraints, shrinkOffset) {
                return Padding(
                  padding: const EdgeInsets.all(1),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset('assets/wallabie_300x.png'),
                  ),
                );
              },
              subtitleBuilder: (context, action) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: action == AuthAction.signIn
                      ? const Text('Welcome to Wallabie, please sign in!')
                      : const Text('Welcome to Wallabie, please sign up!'),
                );
              },
              footerBuilder: (context, action) {
                return const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'By signing in, you agree to our terms and conditions.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              },
              sideBuilder: (context, shrinkOffset) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset('assets/wallabie_300x.png'),
                  ),
                );
              },
            ),
          );
        }

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => UserProfileBloc(
                user: snapshot.data!,
                profileRepository: context.read<ProfileRepository>(),
              )..add(UserProfileStarted()),
            ),
            BlocProvider(create: (_) => HomeCubit()),
            ChangeNotifierProvider(
              create: (_) => ThemeProvider(initialThemeMode: ThemeMode.system),
            ),
            ChangeNotifierProvider(
              create: (_) => LocaleProvider(locale: 'en'),
            ),
          ],
          child: AppView(),
        );
      },
    );
  }
}

/// The main application view with MaterialApp configuration.
///
/// Applies theme, locale, and localization settings based on user preferences.
class AppView extends StatelessWidget {
  /// Creates the [AppView] widget.
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserProfileBloc, UserProfileState>(
      listenWhen: (prev, next) =>
        prev.preference.themeMode != next.preference.themeMode &&          
          next.loadStatus == UserProfileLoadStatus.loaded,
      listener: (context, state) {
        context.read<ThemeProvider>().setThemeMode(state.preference.themeMode);
        context.read<LocaleProvider>().setLocale(state.preference.locale);   
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        themeMode: context.watch<ThemeProvider>().themeMode,
        themeAnimationDuration: const Duration(milliseconds: 400),
        themeAnimationCurve: Curves.easeInOut,

        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FirebaseUILocalizations.delegate,
        ],
        locale: context.watch<LocaleProvider>().locale,
        supportedLocales: const [Locale('en'), Locale('ko')],

        home: const HomePage(),
      ),
    );
  }
}
