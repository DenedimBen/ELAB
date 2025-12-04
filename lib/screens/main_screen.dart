import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/generated/app_localizations.dart';
import 'home/home_screen.dart';
import 'home/favorites_screen.dart';
import 'community/community_screen.dart';
import 'tools/tools_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Sayfalar Listesi
  final List<Widget> _pages = [
    const HomeScreen(),      // 0: Ana Sayfa
    const ToolsScreen(),     // 1: Araçlar
    const CommunityScreen(), // 2: Topluluk
    const FavoritesScreen(), // 3: Favoriler
  ];

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      
      // SAYFA İÇERİĞİ
      body: _pages[_selectedIndex],

      // ALT MENÜ (Bottom Navigation)
      bottomNavigationBar: Container(
        color: const Color(0xFF202329),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: GNav(
          backgroundColor: const Color(0xFF202329),
          color: Colors.grey,
          activeColor: Colors.amber,
          tabBackgroundColor: Colors.amber.withValues(alpha: 0.1),
          gap: 6, // İkon ile yazı arası boşluk
          padding: const EdgeInsets.all(10),
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          tabs: [
            GButton(icon: Icons.home_filled, text: AppLocalizations.of(context)!.navHome),
            GButton(icon: Icons.grid_view_rounded, text: AppLocalizations.of(context)!.navTools),
            GButton(icon: FontAwesomeIcons.users, text: AppLocalizations.of(context)!.navCommunity),
            GButton(icon: Icons.favorite, text: AppLocalizations.of(context)!.navFavorites),
          ],
        ),
      ),
    );
  }
}
