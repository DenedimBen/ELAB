import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
// DİL DOSYASI (KESİN YOL)
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';
// DİĞER EKRANLAR (KESİN YOL)
import 'package:flutter_application_1/screens/settings/settings_screen.dart';
import 'package:flutter_application_1/screens/auth/profile_screen.dart';
import 'package:flutter_application_1/test_engine/test_screen.dart';
import 'package:flutter_application_1/screens/tools/tools_screen.dart';
import 'package:flutter_application_1/screens/knowledge/knowledge_screen.dart';
import 'package:flutter_application_1/screens/smd/smd_screen.dart';
import 'package:flutter_application_1/screens/home/favorites_screen.dart';
import 'package:flutter_application_1/screens/knowledge/dev_boards_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final text = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF1E2126),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100), // Alt navigasyon için boşluk
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER (Profil ve Başlık)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(text.appTitle, style: GoogleFonts.orbitron(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 2)),
                        const Text("v1.0.0 Pro", style: TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white70),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(colors: [Colors.amber, Colors.deepOrange]),
                              boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.5), blurRadius: 10)]
                            ),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey[900],
                              backgroundImage: (user?.photoURL != null) ? NetworkImage(user!.photoURL!) : null,
                              child: (user?.photoURL == null) ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. HIZLI TEST KARTI (Search)
              GestureDetector(
                onTap: () {
                  showSearch(context: context, delegate: ComponentSearchDelegate(text));
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFC0392B), Color(0xFF8E44AD)]),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.purpleAccent.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white, size: 40),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(text.quickTestTitle, style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(text.quickTestDesc, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // 3. KATEGORİ BAŞLIĞI
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(text.catCalculators, style: GoogleFonts.teko(color: Colors.grey, fontSize: 16, letterSpacing: 2)),
              ),
              
              const SizedBox(height: 10),

              // 4. ANA MENÜ GRID'İ (Araçlar, Bilgi, SMD)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.3,
                children: [
                  // ARAÇLAR (Hesaplayıcılar)
                  _buildMenuCard(
                    context,
                    title: text.catCalculators,
                    subtitle: text.calcDesc,
                    icon: Icons.calculate,
                    color: Colors.blueAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ToolsScreen())),
                  ),

                  // BİLGİ BANKASI
                  _buildMenuCard(
                    context,
                    title: text.knowledgeBase,
                    subtitle: "Teori & Dersler",
                    icon: Icons.menu_book,
                    color: Colors.greenAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KnowledgeScreen())),
                  ),

                  // GELİŞTİRME KARTLARI
                  _buildMenuCard(
                    context,
                    title: "GELİŞTİRME KARTLARI",
                    subtitle: "Arduino & ESP",
                    icon: Icons.developer_board,
                    color: const Color(0xFF00E5FF),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DevBoardsScreen())),
                  ),

                  // SMD KODLARI
                  _buildMenuCard(
                    context,
                    title: text.kbSmdCodes,
                    subtitle: "Kod Çözücü",
                    icon: Icons.qr_code_scanner,
                    color: Colors.orangeAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SmdScreen())),
                  ),

                  // FAVORİLER (Kısayol)
                  _buildMenuCard(
                    context,
                    title: text.myFavorites,
                    subtitle: "Kaydedilenler",
                    icon: Icons.favorite,
                    color: Colors.redAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen())), // Ana tab'e yönlendirilebilir ama direkt açmak daha hızlı
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // YARDIMCI KART WIDGET'I
  Widget _buildMenuCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2E36),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(title, style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ARAMA DELEGATE (Aynı kalıyor)
class ComponentSearchDelegate extends SearchDelegate {
  final AppLocalizations text;
  ComponentSearchDelegate(this.text);

  final List<String> components = ["IRF3205", "LM358", "NE555", "BC547", "1N4007", "7805", "TIP31C", "2N2222"];

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
          subtitle: Text(text.searchStartTest),
          leading: const Icon(Icons.precision_manufacturing),
          onTap: () {
            // ARAMADAN SEÇİNCE DOĞRU VERİ GÖNDERİLİYOR
            String pinout = "123";
            String script = "TEST_GENERIC";
            String pkg = "TO-220";

            if (name.contains("IRF")) { pinout="GDS"; script="TEST_MOS_N"; }
            else if (name.contains("BC")) { pinout="CBE"; script="TEST_BJT_NPN"; pkg="TO-92"; }
            else if (name.contains("1N")) { pinout="AK"; script="TEST_DIODE"; pkg="DO-41"; }
            
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => ComponentTestScreen(
                  componentName: name, 
                  packageType: pkg, 
                  pinout: pinout,
                  scriptId: script
                )
              )
            );
          },
        );
      },
    );
  }
}
