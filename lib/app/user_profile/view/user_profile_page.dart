
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

//import '../models/user_preference.dart';
import '../widgets/widgets.dart';
import '../bloc/user_profile_bloc.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});  

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;    
    //final user = context.select((AppBloc bloc) => bloc.state.user);
    //final userPreference = Provider.of<UserPreference>(context);
    
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      buildWhen: (prev, curr) => 
        prev.preference != curr.preference ||
        prev.loadStatus != curr.loadStatus || 
        prev.saveStatus != curr.saveStatus,
      builder: (context, state) {
        debugPrint('UserProfile loadStatus = ${state.loadStatus}');
        final user = FirebaseAuth.instance.currentUser!;

        if (state.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(),
          );
        }       

        final pref = state.preference;
        final isDarkMode = pref.themeMode == ThemeMode.dark;
        final locales = const <(String tag, String label)>[
          ('en', 'English'),
          ('ko', '한국어'),
        ];

        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                tooltip: 'Logout',
                icon: const Icon(Icons.logout),
                onPressed: () => FirebaseAuth.instance.signOut(),
              ),
            ],
          ),
          body: Align(
            alignment: const Alignment(0, -1 / 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Avatar(photo: user.photoURL),
                const SizedBox(height: 4),
                Text(
                  user.email ?? '',              
                  /*
                  style: TextStyle(
                    
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black,
                  ),
                  */      
                ),
                const SizedBox(height: 4),
                Text(user.displayName ?? '', style: textTheme.headlineSmall),
                const SizedBox(height: 8),
                // Dark Mode Switch
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 10.0,
                    children: <Widget>[
                      SwitchListTile(
                        activeThumbColor: Colors.white,
                        activeTrackColor: Color(0xFF004DFF),
                        inactiveThumbColor: Color(0xFF004DFF),
                        title: const Text('Dark Mode'),
                        value: isDarkMode,
                        onChanged: (value) {                      
                          context.read<UserProfileBloc>().add(
                            UserProfileThemeModeChanged(
                              value ? ThemeMode.dark : ThemeMode.light
                            )
                          );
                        },
                        secondary: AnimatedSwitcher(
                          duration: Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) =>
                            RotationTransition(turns: animation, child: child,),
                          child: Icon(
                            isDarkMode
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            key: ValueKey<bool>(isDarkMode),
                            color: isDarkMode ? Colors.amber : Color(0xFF004DFF)
                          ),
                        )
                      ),
                      DropdownButton<String>(
                        value: state.preference.locale,
                        items: locales
                            .map((x) => DropdownMenuItem(value: x.$1, child: Text(x.$2)))
                            .toList(),
                        onChanged: (tag) {
                          if (tag == null) return;
                          context.read<UserProfileBloc>().add(
                            UserProfileLocaleChanged(tag),
                          );
                        },
                      )
                    ],
                  ),
                ),
                                                
                /*
                Switch(
                  value: _isDarkMode!,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value;
                    });
                  },
                ),
                */
              ],
            ),
          ),
        );
      },      
    );
  }
}