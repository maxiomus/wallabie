import 'package:august_chat/app/user_profile/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/home_cubit.dart';
import '../../users/users.dart';
import '../../rooms/rooms.dart';

/// The main home view with bottom navigation and tab content.
///
/// Displays Users, Rooms, or Profile based on selected tab.
class HomeView extends StatelessWidget {
  /// Creates a [HomeView].
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedTab = context.select((HomeCubit cubit) => cubit.state.tab);        

    return Scaffold(
      /*
      appBar: AppBar(
        title: Text(_getTitle(selectedTab)),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () {

            },
          ),
          IconButton(
            key: const Key('homePage_logout_iconButton'),
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Log Out',
            onPressed: () {
              //context.read<AppBloc>().add(const AppLogoutPressed());
            },
          ),
        ],
      ),
      */
      body: IndexedStack(
        index: selectedTab.index,
        children: const [UsersPage(), RoomsPage(), UserProfilePage()],
      ),
      /*
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        key: const Key('homeView_addTodo_floatingActionButton'),
        onPressed: () => Navigator.of(context).push(EditTodoPage.route()),
        child: const Icon(Icons.add),
      ),
      */
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _HomeTabButton(
              groupValue: selectedTab,
              value: HomeTab.users,
              icon: const Icon(Icons.person_2_rounded),
            ),
            _HomeTabButton(
              groupValue: selectedTab,
              value: HomeTab.rooms,
              icon: const Icon(Icons.chat_bubble_rounded),
            ),
            _HomeTabButton(
              groupValue: selectedTab,
              value: HomeTab.options,
              icon: const Icon(Icons.more_horiz_rounded),
            ),              
          ],
        ),
      ),
    );
  }
}

class _HomeTabButton extends StatelessWidget {
  const _HomeTabButton({
    required this.groupValue,
    required this.value,
    required this.icon,
  });

  final HomeTab groupValue;
  final HomeTab value;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => context.read<HomeCubit>().setTab(value),
      iconSize: 32,
      color: groupValue != value
          ? Theme.of(context).colorScheme.primary.withAlpha(100)
          : Theme.of(context).colorScheme.secondary,
      icon: icon,
    );
  }
}