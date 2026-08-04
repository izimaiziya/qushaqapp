import 'package:flutter/material.dart';
import '../main.dart';
import '../l10n/strings.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'diary_screen.dart';
import 'learn_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int idx = 0;

  List<Widget> get pages => [
        HomeScreen(),
        ChatScreen(),
        DiaryScreen(),
        LearnScreen(),
        ProfileScreen(),
      ];

  void goTo(int i) {
    setState(() => idx = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: idx, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kLine)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                navItem(0, Icons.home_rounded, tr('nav_home')),
                navItem(1, Icons.chat_bubble_rounded, tr('nav_chat')),
                navItem(2, Icons.calendar_month_rounded, tr('nav_diary')),
                navItem(3, Icons.menu_book_rounded, tr('nav_learn')),
                navItem(4, Icons.person_rounded, tr('nav_profile')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget navItem(int i, IconData icon, String label) {
    final on = idx == i;
    return GestureDetector(
      onTap: () => goTo(i),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 21, color: on ? kTeal : const Color(0xFF94A3B8)),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: on ? kTeal : const Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }
}
