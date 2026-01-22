import 'package:flutter/material.dart';

import 'home_view.dart';

/// Main home page container with animated background color transitions.
class HomePage extends StatefulWidget {
  /// Creates a [HomePage].
  const HomePage({super.key});

  /// Creates a [MaterialPage] containing the [HomePage].
  static Page<void> page() => const MaterialPage<void>(child: HomePage());

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //final bool _isDarkMode = false;
  //bool _sheetOpen = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(microseconds: 2400),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const HomeView(),
    );   
  }
}
