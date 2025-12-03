import '../tools/smd_calculator_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../data/excel_service.dart';
import '../../models/component_model.dart';
import '../../utils/sound_manager.dart';
import '../../services/auth_service.dart';
import '../test_page/test_screen.dart';
import '../smd/smd_screen.dart';
import 'category_screen.dart';
import '../tools/resistor_screen.dart';
import '../tools/capacitor_screen.dart';
import '../auth/login_screen.dart';
import '../auth/profile_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExcelService _service = ExcelService();
  List<Component> _allComponents = [];
  List<Component> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _getCategories(BuildContext context) {
    final text = AppLocalizations.of(context)!;
    return [
      {'title': text.catTransistors, 'types': ['MOSFET', 'BJT', 'IGBT'], 'icon': Icons.memory, 'color': Colors.blue},
      {'title': text.catDiodes, 'types': ['DIODE', 'ZENER', 'SCHOTTKY'], 'icon': Icons.flash_on, 'color': Colors.orange},
      {'title': text.catRegulators, 'types': ['REGULATOR', 'LDO'], 'icon': Icons.settings_input_component, 'color': Colors.purple},
      {'title': text.catCapacitors, 'types': ['CAP', 'ELCO'], 'icon': Icons.battery_charging_full, 'color': Colors.green},
      {'title': text.catResistors, 'types': ['RES', 'VARISTOR'], 'icon': Icons.code, 'color': Colors.red},
      {'title': text.catICs, 'types': ['IC', 'OPAMP'], 'icon': Icons.developer_board, 'color': Colors.cyan},
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _service.loadDatabase();
    setState(() {
      _allComponents = _service.allComponents;
      _isLoading = false;
    });
  }

  void _runFilter(String keyword) {
    if (keyword.isEmpty) {
      setState(() => _isSearching = false);
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _allComponents
          .where((comp) =>
              comp.id.toLowerCase().contains(keyword.toLowerCase()) ||
              comp.category.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    });
  }

  void _openCategory(Map<String, dynamic> category) {
    SoundManager.playClick();

    if (category['title'] == 'RESISTORS') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ResistorScreen()));
      return;
    }

    if (category['title'] == 'CAPACITORS') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const CapacitorScreen()));
      return;
    }

    List<String> types = category['types'];
    List<Component> filteredList = _allComponents.where((comp) {
      return types.contains(comp.category.toUpperCase());
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryScreen(
          categoryTitle: category['title'],
          components: filteredList,
        ),
      ),
    );
  }

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
                // 1. HEADER
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(text.appTitle, style: GoogleFonts.orbitron(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 2, shadows: [const BoxShadow(color: Colors.amber, blurRadius: 15)])),
                          Text(text.appSubtitle, style: TextStyle(color: Colors.grey[400], fontSize: 10, letterSpacing: 3)),
                        ],
                      ),
                      
                      // --- SAĞ TARAF: AYARLAR VE PROFİL ---
                      Row(
                        children: [
                          // AYARLAR BUTONU
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SettingsScreen()),
                              );
                            },
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFF353A40),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white10),
                              ),
                              child: const Icon(Icons.settings, color: Colors.grey, size: 22),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // PROFİL RESMİ (STREAM BUILDER)
                          StreamBuilder<User?>(
                            stream: FirebaseAuth.instance.authStateChanges(),
                            builder: (context, snapshot) {
                              final user = snapshot.data;

                              // HATA AYIKLAMA: Konsola veriyi yazdıralım
                              if (user != null) {
                                print("Kullanıcı: ${user.displayName}");
                                print("Fotoğraf URL: ${user.photoURL}");
                              } else {
                                print("Kullanıcı giriş yapmamış.");
                              }

                              return GestureDetector(
                                onTap: () {
                                  // DİYALOG YERİNE PROFİL SAYFASINA GİT
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                                  );
                                },
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.amber, width: 2),
                                    boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 10)],
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey[800],
                                    // Resim varsa göster
                                    backgroundImage: (user?.photoURL != null) ? NetworkImage(user!.photoURL!) : null,
                                    // Resim yoksa veya yüklenemezse Harf göster
                                    child: (user?.photoURL == null)
                                        ? Text(
                                            (user?.displayName != null && user!.displayName!.isNotEmpty)
                                                ? user.displayName![0].toUpperCase()
                                                : "?",
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. ARAMA ÇUBUĞU
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFF252930), borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(2, 2), blurRadius: 4)]),
                    child: TextField(
                        controller: _searchController,
                        onChanged: _runFilter,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: text.searchHint,
                          hintStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: const Icon(Icons.search, color: Colors.amber),
                        suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: () { _searchController.clear(); _runFilter(''); }) : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 3. İÇERİK
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                      : _isSearching
                          ? _buildSearchResults()
                          : _buildCategoriesGrid(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = _getCategories(context);
    
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.3,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return GestureDetector(
          onTap: () => _openCategory(cat),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF353A40),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF353A40), Color(0xFF2B2F36)]
              )
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: (cat['color'] as Color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: (cat['color'] as Color).withValues(alpha: 0.2), blurRadius: 15)]
                  ),
                  child: Icon(cat['icon'], size: 30, color: cat['color']),
                ),
                const SizedBox(height: 15),
                Text(
                  cat['title'],
                  style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(child: Text("Sonuç Bulunamadı", style: TextStyle(color: Colors.grey[500])));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final comp = _searchResults[index];
        return GestureDetector(
          onTap: () {
            SoundManager.playClick();
            Navigator.push(context, MaterialPageRoute(builder: (context) => TestScreen(component: comp)));
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF353A40),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[600], size: 20),
                const SizedBox(width: 15),
                Text(comp.id, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(comp.category, style: TextStyle(color: Colors.blue[300], fontSize: 12)),
              ],
            ),
          ),
        );
      },
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