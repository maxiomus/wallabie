import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:august_chat/l10n/app_localizations.dart';
import 'package:august_chat/notifications/notifications.dart';
import '../widgets/widgets.dart';
import '../bloc/user_profile_bloc.dart';

/// Page displaying user profile with settings for theme, locale, and notifications.
class UserProfilePage extends StatelessWidget {
  /// Creates a [UserProfilePage].
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = FirebaseAuth.instance.currentUser!;
        final pref = state.preference;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Profile Header
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.surface,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          Avatar(photo: user.photoURL),
                          const SizedBox(height: 12),
                          Text(
                            user.displayName ?? 'User',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email ?? '',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Settings Sections
              SliverToBoxAdapter(
                child: Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Appearance Section
                        _SectionHeader(title: l10n.appearance),
                        _buildThemeTile(context, pref),
                        _buildLocaleTile(context, pref),
                        const Divider(height: 32),

                        // Notifications Section
                        _SectionHeader(title: l10n.notifications),
                        _buildNotificationsTile(context, pref),
                        _buildNotificationsListTile(context),
                        const Divider(height: 32),

                        // About Section
                        _SectionHeader(title: l10n.about),
                        _buildAboutTile(context),
                        const SizedBox(height: 24),

                        // Logout Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _showLogoutDialog(context),
                              icon: const Icon(Icons.logout),
                              label: Text(l10n.signOut),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.error,
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeTile(BuildContext context, pref) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = pref.themeMode == ThemeMode.dark;

    return ListTile(
      leading: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            RotationTransition(turns: animation, child: child),
        child: Icon(
          isDarkMode ? Icons.dark_mode : Icons.light_mode,
          key: ValueKey<bool>(isDarkMode),
          color: isDarkMode ? Colors.amber : const Color(0xFF004DFF),
        ),
      ),
      title: Text(l10n.darkMode),
      subtitle: Text(isDarkMode ? l10n.on : l10n.off),
      trailing: Switch(
        value: isDarkMode,
        onChanged: (value) {
          context.read<UserProfileBloc>().add(
            UserProfileThemeModeChanged(
              value ? ThemeMode.dark : ThemeMode.light,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocaleTile(BuildContext context, pref) {
    final l10n = AppLocalizations.of(context)!;
    const locales = <(String tag, String label)>[
      ('en', 'English'),
      ('ko', '한국어'),
    ];

    final currentLabel = locales
        .firstWhere((l) => l.$1 == pref.locale, orElse: () => locales.first)
        .$2;

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.language),
      subtitle: Text(currentLabel),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageDialog(context, pref.locale, locales),
    );
  }

  Widget _buildNotificationsTile(BuildContext context, pref) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.notifications_outlined),
      title: Text(l10n.pushNotifications),
      subtitle: Text(pref.notificationsEnabled ? l10n.enabled : l10n.disabled),
      trailing: Switch(
        value: pref.notificationsEnabled,
        onChanged: (value) {
          context.read<UserProfileBloc>().add(
            const UserProfileNotificationsToggled(),
          );
        },
      ),
    );
  }

  Widget _buildNotificationsListTile(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.inbox_outlined),
      title: Text(l10n.notificationHistory),
      subtitle: Text(l10n.viewPastNotifications),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(NotificationsPage.route());
      },
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: Text(l10n.aboutAppName),
      subtitle: Text(l10n.version('1.0.0')),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: 'August Chat',
          applicationVersion: '1.0.0',
          applicationLegalese: '© 2024 August Chat',
          children: [
            const SizedBox(height: 16),
            Text(l10n.appDescription),
          ],
        );
      },
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    String currentLocale,
    List<(String, String)> locales,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: locales.map((locale) {
            final isSelected = locale.$1 == currentLocale;
            return ListTile(
              title: Text(locale.$2),
              leading: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
              onTap: () {
                context.read<UserProfileBloc>().add(
                  UserProfileLocaleChanged(locale.$1),
                );
                Navigator.of(dialogContext).pop();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.signOutConfirmTitle),
        content: Text(l10n.signOutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              // Delete FCM tokens before signing out to prevent
              // notifications to signed-out devices
              await context.read<UserProfileBloc>().deleteAllFcmTokens();
              await FirebaseAuth.instance.signOut();
            },
            child: Text(
              l10n.signOut,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
