import 'package:chat2/pages/screens/chat_screen.dart';
import 'package:chat2/pages/screens/contacts_screen.dart';
import 'package:chat2/pages/screens/osint_screan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static Route<void> route() {
    return CupertinoPageRoute(
      builder: (context) => const HomePage(),
    );
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [ContactsScreen(), ChatScreen(), OsintScrean()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),
          CupertinoTabBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person),
                label: 'Пользователи',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chat_bubble),
                label: 'Чаты',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.increase_indent),
                label: 'Osint',
              ),
            ],
            currentIndex: _selectedIndex,
            activeColor: CupertinoColors.activeBlue,
            onTap: _onItemTapped,
          ),
        ],
      ),
    );
  }
}
