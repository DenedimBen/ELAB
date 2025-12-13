import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/excel_service.dart';
import '../../models/component_model.dart';
import '../component_detail_screen.dart';

class ComponentMenuScreen extends StatefulWidget {
  const ComponentMenuScreen({super.key});

  @override
  State<ComponentMenuScreen> createState() => _ComponentMenuScreenState();
}

class _ComponentMenuScreenState extends State<ComponentMenuScreen> {
  // Veri Yönetimi
  List<ComponentModel> _allComponents = []; // Tüm liste (Önbellek)
  List<ComponentModel> _filteredComponents = []; // Ekranda görünen liste
  
  // Arama ve Filtreleme
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "Tümü";
  final List<String> _categories = ["Tümü", "MOSFET", "BJT", "IC", "DIODE", "RESISTOR"];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Verileri Excel Servisinden Çek
  void _loadData() async {
    // ExcelService örneğini al
    final service = ExcelService(); 
    
    // Verileri yükle
    await service.loadDatabase();
    
    if (mounted) {
      setState(() {
        _allComponents = service.allComponents; // Servisteki ana liste
        _filteredComponents = _allComponents;
        _isLoading = false;
      });
    }
  }

  // 🔍 FİLTRELEME MOTORU
  void _filterList(String query) {
    List<ComponentModel> temp = [];

    // 1. Adım: Kategori Filtresi
    if (_selectedCategory == "Tümü") {
      temp = _allComponents;
    } else {
      temp = _allComponents.where((c) => c.category.toUpperCase().contains(_selectedCategory)).toList();
    }

    // 2. Adım: Arama Metni Filtresi
    if (query.isNotEmpty) {
      temp = temp.where((c) {
        final id = c.id.toLowerCase();
        final desc = c.description.toLowerCase();
        final q = query.toLowerCase();
        return id.contains(q) || desc.contains(q);
      }).toList();
    }

    setState(() {
      _filteredComponents = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121418), // Koyu Tema
      body: SafeArea(
        child: Column(
          children: [
            // --- ÜST BAŞLIK VE ARAMA ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2126),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("VERİ BANKASI", style: GoogleFonts.teko(color: Colors.grey, fontSize: 14, letterSpacing: 2)),
                  Text("Komponent Ara", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // ARAMA ÇUBUĞU
                  TextField(
                    controller: _searchController,
                    onChanged: _filterList,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Örn: IRF3205, 7805...",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: const Icon(Icons.search, color: Colors.amber),
                      suffixIcon: _searchController.text.isNotEmpty 
                        ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: () {
                            _searchController.clear();
                            _filterList('');
                          }) 
                        : null,
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // KATEGORİ FİLTRELERİ (Yatay Liste)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        bool isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: FilterChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                _selectedCategory = cat;
                                _filterList(_searchController.text);
                              });
                            },
                            backgroundColor: Colors.white10,
                            selectedColor: Colors.amber,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.white70, 
                              fontWeight: FontWeight.bold
                            ),
                            checkmarkColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // --- LİSTE ALANI ---
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                : _filteredComponents.isEmpty 
                  ? _buildEmptyState() 
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: _filteredComponents.length,
                      itemBuilder: (context, index) {
                        return _buildComponentCard(_filteredComponents[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- KOMPONENT KARTI ---
  Widget _buildComponentCard(ComponentModel comp) {
    return GestureDetector(
      onTap: () {
        // DETAY EKRANINA GİT (VERİ TAŞIMA)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComponentDetailScreen(
              componentData: {
                'id': comp.id,
                'package': comp.packageId,
                'category': comp.category,
                'polarity': comp.polarity,
                'vmax': comp.vMax,
                'imax': comp.iMax,
                'power_max': comp.powerMax,
                'description': comp.description,
                'pinout_code': comp.pinoutCode,
                'test_script_id': comp.testScriptId,
                'datasheet_url': comp.datasheetUrl,
                'applications': comp.applications, // Akıllı veriler
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2126),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            // 1. KÜÇÜK RESİM KUTUSU
            Container(
              width: 60, height: 60,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/packages/${comp.packageId.toLowerCase()}.png',
                fit: BoxFit.contain,
                errorBuilder: (c, o, s) => const Icon(Icons.memory, color: Colors.grey),
              ),
            ),
            
            const SizedBox(width: 15),

            // 2. BİLGİLER
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(comp.id, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.blueAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                        child: Text(comp.packageId, style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comp.category.toUpperCase(), 
                    style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)
                  ),
                  const SizedBox(height: 4),
                  // Teknik Özet (V/I)
                  Row(
                    children: [
                      Icon(Icons.flash_on, size: 12, color: Colors.grey[500]),
                      Text("${comp.vMax}V  ", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      Icon(Icons.bolt, size: 12, color: Colors.grey[500]),
                      Text("${comp.iMax}A", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            // 3. OK İKONU
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }

  // --- BOŞ DURUM (BULUNAMADI) ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[800]),
          const SizedBox(height: 20),
          const Text("Sonuç Bulunamadı", style: TextStyle(color: Colors.grey, fontSize: 18)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Google'da Ara
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
            child: const Text("Google'da Ara", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
