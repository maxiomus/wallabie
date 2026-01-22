part of 'home_cubit.dart';

/// Available tabs in the home screen bottom navigation.
enum HomeTab {
  /// Users list tab for starting new chats.
  users,

  /// Rooms list tab showing existing conversations.
  rooms,

  /// Options/settings tab for user profile.
  options,
}

/// State representing the currently selected home tab.
final class HomeState extends Equatable {
  /// Creates a [HomeState] with optional tab selection.
  const HomeState({
    this.tab = HomeTab.rooms,
  });

  /// The currently selected tab.
  final HomeTab tab;

  @override
  List<Object> get props => [tab];
}