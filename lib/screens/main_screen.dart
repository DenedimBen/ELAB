import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/generated/app_localizations.dart';

import 'home/home_screen.dart';
import 'home/favorites_screen.dart';
import 'community/community_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // ARTIK SADECE 3 ANA EKRAN VAR
  final List<Widget> _pages = [
    const HomeScreen(),      // 0: Dashboard
    const CommunityScreen(), // 1: Topluluk
    const FavoritesScreen(), // 2: Favoriler
  ];

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: Container(
        color: const Color(0xFF202329),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: GNav(
          backgroundColor: const Color(0xFF202329),
          color: Colors.grey,
          activeColor: Colors.amber,
          tabBackgroundColor: Colors.amber.withValues(alpha: 0.1),
          gap: 8,
          padding: const EdgeInsets.all(12),
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          // SADECE 3 SEKME
          tabs: [
            GButton(icon: Icons.home_filled, text: text.navHome),
            GButton(icon: FontAwesomeIcons.users, text: text.navCommunity),
            GButton(icon: Icons.favorite, text: text.navFavorites),
          ],
        ),
      ),
    );
  }
}
