import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../data/excel_service.dart';
import '../../models/component_model.dart';
import '../../utils/sound_manager.dart';
import '../test_page/test_screen.dart';
import '../tools/resistor_screen.dart';
import '../tools/capacitor_screen.dart';
import 'category_screen.dart';

class ComponentMenuScreen extends StatefulWidget {
  const ComponentMenuScreen({super.key});

  @override
  State<ComponentMenuScreen> createState() => _ComponentMenuScreenState();
}

class _ComponentMenuScreenState extends State<ComponentMenuScreen> {
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

    if (category['title'].toString().contains(AppLocalizations.of(context)!.catResistors)) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ResistorScreen()));
      return;
    }

    if (category['title'].toString().contains(AppLocalizations.of(context)!.catCapacitors)) {
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
    final categories = _getCategories(context);

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(text.catComponents, style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.grey), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.all(20),
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
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          ),

          // İçerik
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                : _isSearching
                    ? _buildSearchResults()
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1.3),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          return _buildCategoryCard(cat);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    return GestureDetector(
      onTap: () => _openCategory(cat),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF353A40),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF353A40), Color(0xFF2B2F36)])
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: (cat['color'] as Color).withValues(alpha: 0.1), shape: BoxShape.circle, boxShadow: [BoxShadow(color: (cat['color'] as Color).withValues(alpha: 0.2), blurRadius: 15)]),
              child: Icon(cat['icon'], size: 30, color: cat['color']),
            ),
            const SizedBox(height: 15),
            Text(cat['title'], style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
          ],
        ),
      ),
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
