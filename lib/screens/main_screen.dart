import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';
import '../widgets/banner_wrapper.dart'; // Reklam Wrapper'ı

// EKRANLAR
import 'home/home_screen.dart';
import 'community/community_screen.dart';
import 'home/favorites_screen.dart';
import 'auth/profile_screen.dart';
import 'settings/settings_screen.dart'; // EKLENDİ ✅

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // --- SAYFA LİSTESİ (Sıralama Önemli!) ---
  final List<Widget> _pages = [
    const HomeScreen(),       // 0
    const CommunityScreen(),  // 1
    const FavoritesScreen(),  // 2
    const ProfileScreen(),    // 3
    const SettingsScreen(),   // 4 (EKLENDİ ✅)
  ];

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF1E2126),
      
      // BODY (Reklamlı Wrapper İçinde)
      body: BannerWrapper(
        child: _pages[_selectedIndex],
      ),

      // ALT MENÜ
      bottomNavigationBar: Container(
        color: const Color(0xFF181A1F),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: GNav(
          backgroundColor: const Color(0xFF181A1F),
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
          tabs: [
            GButton(icon: Icons.home_filled, text: text.navHome),       // 0
            GButton(icon: FontAwesomeIcons.users, text: text.navCommunity), // 1
            GButton(icon: Icons.favorite, text: text.navFavorites),     // 2
            GButton(icon: Icons.person, text: text.navProfile),         // 3
            
            // --- 5. SEKME: AYARLAR (EKLENDİ ✅) ---
            GButton(
              icon: Icons.settings, 
              text: text.navSettings
            ),
          ],
        ),
      ),
    );
  }
}
