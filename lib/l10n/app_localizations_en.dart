// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirmTitle => 'Sign Out';

  @override
  String get signOutConfirmMessage => 'Are you sure you want to sign out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get notificationHistory => 'Notification History';

  @override
  String get viewPastNotifications => 'View past notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get failedToLoadNotifications => 'Failed to load notifications';

  @override
  String get timeNow => 'now';

  @override
  String get about => 'About';

  @override
  String get aboutAppName => 'About August Chat';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get appDescription => 'A modern chat application built with Flutter.';

  @override
  String get rooms => 'Rooms';

  @override
  String get newDirectChat => 'New 1-on-1';

  @override
  String get newGroup => 'New group';

  @override
  String get noChatsYet => 'No chats yet. Start one!';

  @override
  String get failedToLoadRooms => 'Failed to load rooms';

  @override
  String get users => 'Users';

  @override
  String get failedToLoadUsers => 'Failed to load users';

  @override
  String get createGroup => 'New Group';

  @override
  String get groupName => 'Group name';

  @override
  String get groupNameRequired => 'Group name required';

  @override
  String get selectAtLeastOneMember => 'Select at least 1 member';

  @override
  String get message => 'Message';

  @override
  String get chatError => 'Chat error';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get file => 'File';

  @override
  String get location => 'Location';

  @override
  String get voiceRecordingNotImplemented =>
      'Voice recording not yet implemented';

  @override
  String get welcomeSignIn => 'Welcome to Wallabie, please sign in!';

  @override
  String get welcomeSignUp => 'Welcome to Wallabie, please sign up!';

  @override
  String get termsAgreement =>
      'By signing in, you agree to our terms and conditions.';
}
