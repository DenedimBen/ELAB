import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../test_engine/test_screen.dart'; // Test ekranı importu

import 'component_menu_screen.dart'; 
import '../knowledge/knowledge_screen.dart'; 
import '../tools/tools_screen.dart'; // <-- ARAÇLAR MENÜSÜ BURAYA GELDİ
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      body: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: GridPainter()),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER (Profil Resmi İle)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("E-LAB", style: GoogleFonts.orbitron(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 2, shadows: [const BoxShadow(color: Colors.amber, blurRadius: 15)])),
                          Text("ELECTRONIC ASSISTANT", style: TextStyle(color: Colors.grey[400], fontSize: 10, letterSpacing: 3)),
                        ],
                      ),
                      _buildProfileIcon(context),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. DASHBOARD (3 Büyük Kart)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // HIZLI ARAMA KARTI
                      GestureDetector(
                        onTap: () {
                          showSearch(context: context, delegate: ComponentSearchDelegate());
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFC0392B), Color(0xFF8E44AD)]), // Kırmızı-Mor Ateşli Renk
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.white, size: 40),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("HIZLI SAĞLAMLIK TESTİ", style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Text("Modeli yaz, testi başlat...", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios, color: Colors.white54),
                            ],
                          ),
                        ),
                      ),

                      // A. DEVRE ELEMANLARI
                      _buildDashboardCard(
                        context,
                        title: text.catComponents,
                        subtitle: "Mosfet, BJT, Diyot ve Entegre Arşivi",
                        icon: Icons.settings_input_component,
                        color: Colors.blueAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ComponentMenuScreen())),
                      ),

                      const SizedBox(height: 20),

                      // B. HESAPLAYICILAR (YENİ YERİ)
                      _buildDashboardCard(
                        context,
                        title: text.catCalculators, // "HESAPLAYICILAR"
                        subtitle: text.calcDesc, // "Direnç, Güç, Bobin..."
                        icon: Icons.calculate, // Hesap makinesi ikonu
                        color: Colors.greenAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ToolsScreen())),
                      ),

                      const SizedBox(height: 20),

                      // C. BİLGİ BANKASI
                      _buildDashboardCard(
                        context,
                        title: text.knowledgeBase,
                        subtitle: "Formüller, Teoriler ve Pinoutlar",
                        icon: Icons.menu_book,
                        color: Colors.purpleAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KnowledgeScreen())),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130, // Biraz küçülttük ki 3 tane rahat sığsın
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 5))]
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle, border: Border.all(color: color.withValues(alpha: 0.5))),
                    child: Icon(icon, size: 30, color: color),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 5),
                  Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Icon(Icons.arrow_forward_ios, color: color.withValues(alpha: 0.5)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileIcon(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return GestureDetector(
          onTap: () {
             showDialog(context: context, builder: (ctx) => AlertDialog(
               backgroundColor: const Color(0xFF25282F),
               title: const Text("Hesap", style: TextStyle(color: Colors.white)),
               content: Text("Giriş: ${user?.email ?? 'Misafir'}", style: const TextStyle(color: Colors.grey)),
               actions: [
                 TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal", style: TextStyle(color: Colors.grey))),
                 TextButton(onPressed: () async {
                   await AuthService().signOut();
                   if(context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
                 }, child: const Text("Çıkış", style: TextStyle(color: Colors.redAccent))),
               ],
             ));
          },
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.amber, width: 2)),
            child: CircleAvatar(
              radius: 18, backgroundColor: Colors.grey[800],
              backgroundImage: (user?.photoURL != null) ? NetworkImage(user!.photoURL!) : null,
              child: (user?.photoURL == null) ? Text(user != null && user.displayName != null && user.displayName!.isNotEmpty ? user.displayName![0] : "?", style: const TextStyle(color: Colors.white)) : null
            ),
          ),
        );
      }
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.03)..strokeWidth = 1;
    const double step = 40.0;
    for (double x = 0; x < size.width; x += step) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += step) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// SEARCH DELEGATE
class ComponentSearchDelegate extends SearchDelegate {
  // Örnek Liste - Normalde Excel Service'den gelecek
  final List<String> components = ["IRF3205", "LM358", "NE555", "BC547", "1N4007"];

  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => Center(child: Text(query));

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = components.where((element) => element.toLowerCase().contains(query.toLowerCase())).toList();
    
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final name = suggestions[index];
        return ListTile(
          title: Text(name),
          subtitle: const Text("Testi Başlat"),
          leading: const Icon(Icons.precision_manufacturing),
          onTap: () {
            // SEÇİLEN PARÇAYLA TESTİ BAŞLAT
            String scriptId = "TEST_GENERIC";
            if (name.contains("IRF")) scriptId = "TEST_MOS_N";
            else if (name.contains("BC")) scriptId = "TEST_BJT_NPN";
            else if (name.contains("78")) scriptId = "TEST_REGULATOR_FIXED";

            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => ComponentTestScreen(
                  componentName: name, 
                  packageType: "TO-220",
                  pinout: "GDS", // Varsayılan pinout
                  scriptId: scriptId,
                ) 
              )
            );
          },
        );
      },
    );
  }
}
