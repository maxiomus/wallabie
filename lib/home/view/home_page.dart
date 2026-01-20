import 'package:flutter/material.dart';

import 'home_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
