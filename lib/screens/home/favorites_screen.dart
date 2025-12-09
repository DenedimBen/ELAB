import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';
import 'package:flutter_application_1/data/excel_service.dart';
import 'package:flutter_application_1/models/component_model.dart';
import 'package:flutter_application_1/services/firestore_service.dart';
import 'package:flutter_application_1/utils/sound_manager.dart';
import 'package:flutter_application_1/test_engine/test_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ExcelService _excelService = ExcelService();
  final FirestoreService _firestoreService = FirestoreService();
  
  List<ComponentModel> allComponents = [];

  @override
  void initState() {
    super.initState();
    _loadComponents();
  }

  Future<void> _loadComponents() async {
    await _excelService.loadDatabase();
    setState(() {
      allComponents = _excelService.allComponents;
    });
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
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      Text(text.myFavorites, style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 2)),
                    ],
                  ),
                ),

                // FAVORİ LİSTESİ (Canlı Akış)
                Expanded(
                  child: StreamBuilder<List<String>>(
                    stream: _firestoreService.getFavorites(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.amber));
                      }

                      final favIds = snapshot.data ?? [];

                      if (favIds.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite_border, size: 60, color: Colors.grey.withValues(alpha: 0.3)),
                              const SizedBox(height: 10),
                              Text(text.noFavoritesYet, style: TextStyle(color: Colors.grey[500])),
                            ],
                          ),
                        );
                      }

                      // ID listesini Gerçek Komponent Objelerine çevir
                      // (Excel'deki tüm parçalar içinden favori olanları bul)
                      final favComponents = allComponents
                          .where((comp) => favIds.contains(comp.id))
                          .toList();

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: favComponents.length,
                        itemBuilder: (context, index) {
                          final comp = favComponents[index];
                          return _buildFavCard(comp);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavCard(ComponentModel comp) {
    return GestureDetector(
      onTap: () {
        SoundManager.playClick();
        Navigator.push(context, MaterialPageRoute(builder: (context) => ComponentTestScreen(
          componentName: comp.id,
          packageType: comp.packageId,
          pinout: comp.pinoutCode.isNotEmpty ? comp.pinoutCode : 'GDS',
          scriptId: comp.testScriptId.isNotEmpty ? comp.testScriptId : 'TEST_GENERIC',
        )));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF353A40),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)), // Favori olduğu için sarı çerçeve
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Hero(
              tag: "fav_${comp.id}",
              child: Image.asset(
                'assets/packages/${comp.packageId.trim().toLowerCase()}.png',
                height: 40,
                errorBuilder: (c,e,s) => const Icon(Icons.memory, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comp.id, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text("${comp.category} • ${comp.packageId}", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.redAccent),
              onPressed: () async {
                // Listeden Hızlı Silme
                await _firestoreService.removeFavorite(comp.id);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Favorilerden çıkarıldı"), duration: Duration(seconds: 1)));
              },
            )
          ],
        ),
      ),
    );
  }
}

// Grid Painter (Arka Plan Izgarası)
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.03)..strokeWidth = 1;
    const double step = 40.0;
    for (double x = 0; x < size.width; x += step) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += step) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}