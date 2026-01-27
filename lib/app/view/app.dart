import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:august_chat/l10n/app_localizations.dart';
import 'package:august_chat/app/theme_provider.dart';
import '../../home/cubit/home_cubit.dart';
import '../../home/view/home_page.dart';
import '../../chat/view/chat_page.dart';
import '../../repositories/profile_repostory.dart';
import '../../repositories/notifications_repository.dart';
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
    //final themeProvider = context.watch<ThemeProvider>();

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
                notificationsRepository: context.read<NotificationsRepository>(),
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
          child: AppView(user: snapshot.data!),
        );
      },
    );
  }
}

/// The main application view with MaterialApp configuration.
///
/// Applies theme, locale, and localization settings based on user preferences.
/// Handles FCM notification tap navigation.
class AppView extends StatefulWidget {
  /// Creates the [AppView] widget.
  const AppView({super.key, required this.user});

  /// The authenticated Firebase user.
  final User user;

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _setupNotificationHandlers();
  }

  Future<void> _setupNotificationHandlers() async {
    final notificationsRepository = context.read<NotificationsRepository>();

    // Handle notification tap when app is in background
    notificationsRepository.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle notification tap when app was terminated
    final initialMessage = await notificationsRepository.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    final roomId = message.data['roomId'] as String?;
    if (roomId != null && roomId.isNotEmpty) {
      // Navigate to the chat page
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => _buildChatPage(roomId),
        ),
      );
    }
  }

  Widget _buildChatPage(String roomId) {
    return ChatPage(roomId: roomId);
  }

  @override
  Widget build(BuildContext context) {
    //final userPreference = Provider.of<UserPreference>(context);
    //final locale = const Locale('en', 'US');
    /*
    final themeMode = context.select((UserProfileBloc bloc) {
      final s = bloc.state;
      return s.loadStatus == UserProfileLoadStatus.loaded
          ? s.preference.themeMode
          : ThemeMode.system;
    });
    */    

    return BlocListener<UserProfileBloc, UserProfileState>(
      listenWhen: (prev, next) =>
        (prev.preference.themeMode != next.preference.themeMode ||
         prev.preference.locale != next.preference.locale) &&
          next.loadStatus == UserProfileLoadStatus.loaded,
      listener: (context, state) {
        context.read<ThemeProvider>().setThemeMode(state.preference.themeMode);
        context.read<LocaleProvider>().setLocale(state.preference.locale);
      },
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        themeMode: context.watch<ThemeProvider>().themeMode,
        themeAnimationDuration: const Duration(milliseconds: 400),
        themeAnimationCurve: Curves.easeInOut,

        localizationsDelegates: [
          AppLocalizations.delegate,
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
