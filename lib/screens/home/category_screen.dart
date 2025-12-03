import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/component_model.dart';
import '../test_page/test_screen.dart';
import '../../utils/sound_manager.dart';

class CategoryScreen extends StatelessWidget {
  final String categoryTitle;
  final List<Component> components;

  const CategoryScreen({super.key, required this.categoryTitle, required this.components});

  @override
  Widget build(BuildContext context) {
    String _packageImagePath(String packageId) {
      final key = packageId.trim().toLowerCase();
      final map = {
        'to-220': 'assets/packages/to-220.png',
        'to-220_dim': 'assets/packages/to-220_dim.png',
        'to-92': 'assets/packages/to-92.png',
        'to-126': 'assets/packages/to-126.png',
        'do-41': 'assets/packages/do-41.png',
        'sot-23': 'assets/packages/to-92.png',
        'sma': 'assets/packages/do-41.png',
      };
      return map[key] ?? 'assets/packages/$key.png';
    }
    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(categoryTitle, style: GoogleFonts.orbitron(color: Colors.amber, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () {
            SoundManager.playBack();
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: components.length,
        itemBuilder: (context, index) {
          final comp = components[index];
          return GestureDetector(
            onTap: () {
              SoundManager.playClick();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TestScreen(component: comp)),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF353A40),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Hero(
                    tag: comp.id,
                    child: Image.asset(_packageImagePath(comp.packageId), height: 40, errorBuilder: (c, e, s) => const Icon(Icons.memory, color: Colors.grey)),
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
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.amber),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
