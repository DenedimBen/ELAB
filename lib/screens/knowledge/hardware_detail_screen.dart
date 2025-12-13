import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;
import 'package:flutter_application_1/screens/knowledge/knowledge_detail_screen.dart';

class HardwareDetailScreen extends StatefulWidget {
  final Map<String, dynamic> itemData;

  const HardwareDetailScreen({super.key, required this.itemData});

  @override
  State<HardwareDetailScreen> createState() => _HardwareDetailScreenState();
}

class _HardwareDetailScreenState extends State<HardwareDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _warpController;

  @override
  void initState() {
    super.initState();
    _warpController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _warpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.itemData;
    String title = item['name'] ?? 'Donanım';
    String desc = item['desc'] ?? '';
    String? heroImage = item['heroImage'];
    
    // Verileri Güvenli Çekme
    List<Map<String, dynamic>> resources = [];
    if (item['resources'] != null) resources = List<Map<String, dynamic>>.from(item['resources']);

    // Feature List
    List<Map<String, dynamic>> features = [];
    if (item['features'] != null) {
      features = List<Map<String, dynamic>>.from(item['features']);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: Stack(
        children: [
          // Arka Plan
          Positioned.fill(child: CustomPaint(painter: TechGridPainter())),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.amber),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        // --- HERO RESİM ALANI ---
                        Center(
                          child: SizedBox(
                            height: 250,
                            width: double.infinity,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.amber.withOpacity(0.2)),
                                      ),
                                      child: AnimatedBuilder(
                                        animation: _warpController,
                                        builder: (context, child) {
                                          return CustomPaint(
                                            painter: InfiniteWarpPainter(animationValue: _warpController.value),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Hero(
                                  tag: title,
                                  child: heroImage != null
                                      ? Image.asset(
                                          heroImage, 
                                          fit: BoxFit.contain, 
                                          height: 200,
                                          errorBuilder: (c,e,s) => const Icon(Icons.broken_image, color:Colors.white24, size:50)
                                        )
                                      : Icon(item['icon'] ?? Icons.memory, size: 100, color: Colors.amber),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // --- BAŞLIK ---
                        Text(
                          title.toUpperCase(),
                          style: GoogleFonts.teko(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white, height: 0.9, shadows: [BoxShadow(color: Colors.amber.withOpacity(0.6), blurRadius: 25)]),
                        ),
                        
                        const SizedBox(height: 20),

                        // --- AÇIKLAMA ---
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2126),
                            borderRadius: BorderRadius.circular(16),
                            border: Border(left: BorderSide(color: Colors.amber.withOpacity(0.5), width: 3)),
                          ),
                          child: Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6)),
                        ),

                        const SizedBox(height: 30),

                        // --- ÖZELLİK KARTLARI (TAM OTURAN BOYUT) ---
                        if (features.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.grid_view_rounded, color: Colors.amber, size: 24),
                              const SizedBox(width: 10),
                              Text("ÖNE ÇIKAN ÖZELLİKLER", style: GoogleFonts.orbitron(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, 
                              crossAxisSpacing: 10, // Yatay boşluk
                              mainAxisSpacing: 10,  // Dikey boşluk
                              // --- SİHİRLİ DOKUNUŞ BURADA ---
                              // Bu değeri artırarak kutuları kısalttım (1.1 -> 1.4)
                              // Böylece yazı bitince kutu da bitiyor, boşluk kalmıyor.
                              childAspectRatio: 1.4, 
                            ),
                            itemCount: features.length,
                            itemBuilder: (context, index) {
                              return _buildFeatureCard(features[index]);
                            },
                          ),
                          const SizedBox(height: 30),
                        ],

                        // --- DÖKÜMANLAR ---
                        Row(
                          children: [
                            const Icon(Icons.folder_special, color: Colors.amber, size: 24),
                            const SizedBox(width: 10),
                            Text("DÖKÜMANLAR", style: GoogleFonts.orbitron(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Divider(color: Colors.amber.withOpacity(0.3)),
                        const SizedBox(height: 20),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, 
                            crossAxisSpacing: 15, 
                            mainAxisSpacing: 15, 
                            childAspectRatio: 1.4
                          ),
                          itemCount: resources.length,
                          itemBuilder: (context, index) {
                            final res = resources[index];
                            bool isPdf = res['path'].toString().toLowerCase().endsWith('.pdf');
                            return _buildTechDocCard(context, res, isPdf);
                          },
                        ),
                        
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- KOMPAKT FEATURE KARTI ---
  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    IconData iconData = Icons.star;
    Color iconColor = Colors.white;

    String type = feature['type'] ?? 'default';

    switch (type) {
      case 'bluetooth':
        iconData = FontAwesomeIcons.bluetoothB; iconColor = Colors.blueAccent; break;
      case 'wifi':
        iconData = Icons.wifi; iconColor = Colors.cyanAccent; break;
      case 'processor': 
        iconData = FontAwesomeIcons.microchip; iconColor = Colors.white; break;
      case 'imu': 
        iconData = FontAwesomeIcons.arrowsUpDownLeftRight; iconColor = Colors.orangeAccent; break;
      case 'python': 
        iconData = FontAwesomeIcons.python; iconColor = Colors.yellow; break;
      case 'mic':
        iconData = Icons.mic; iconColor = Colors.redAccent; break;
      case 'security':
        iconData = Icons.security; iconColor = Colors.greenAccent; break;
      case 'power':
        iconData = Icons.bolt; iconColor = Colors.amber; break;
      case 'memory':
        iconData = FontAwesomeIcons.memory; iconColor = Colors.purpleAccent; break;
      case 'sensor':
        iconData = Icons.sensors; iconColor = Colors.tealAccent; break;
      default:
        iconData = Icons.settings_input_component; iconColor = Colors.amber;
    }

    return Container(
      // Padding iyice optimize edildi
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF25282F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // İçeriği ortala
        children: [
          // İKON
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(iconData, color: iconColor, size: 18),
          ),
          const SizedBox(height: 6), // Boşluk azaltıldı
          
          // BAŞLIK
          Text(
            feature['title'] ?? '',
            style: GoogleFonts.teko(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 3), // Boşluk azaltıldı
          
          // AÇIKLAMA
          Expanded(
            child: Text(
              feature['desc'] ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 10, height: 1.1), // Satır aralığı sıkılaştırıldı
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechDocCard(BuildContext context, Map<String, dynamic> res, bool isPdf) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => UniversalViewerScreen(title: res['title']!, filePath: res['path']!)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF25282F), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withOpacity(0.15), width: 1),
        ),
        child: Stack(
          children: [
            Positioned(right: -10, bottom: -10, child: Icon(isPdf ? FontAwesomeIcons.filePdf : Icons.image, size: 60, color: Colors.white.withOpacity(0.03))),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(isPdf ? FontAwesomeIcons.filePdf : Icons.image, color: isPdf ? Colors.redAccent : Colors.amber, size: 20), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)), child: Text(isPdf ? "PDF" : "IMG", style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)))]),
                  Text(res['title'].toString().toUpperCase(), maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, height: 1.2)),
                  Container(width: 30, height: 2, color: isPdf ? Colors.redAccent.withOpacity(0.5) : Colors.amber.withOpacity(0.5))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfiniteWarpPainter extends CustomPainter {
  final double animationValue;
  InfiniteWarpPainter({required this.animationValue});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..strokeCap = StrokeCap.round;
    for (int i = 0; i < 100; i++) {
      final random = math.Random(i); 
      double startX = (random.nextDouble() - 0.5) * 2; double startY = (random.nextDouble() - 0.5) * 2;
      double z = (random.nextDouble() - animationValue); if (z <= 0) z += 1.0; 
      double perspective = 1 / z;
      double screenX = center.dx + (startX * size.width * 0.5 * perspective); double screenY = center.dy + (startY * size.height * 0.5 * perspective);
      if (screenX < 0 || screenX > size.width || screenY < 0 || screenY > size.height) continue;
      double prevZ = z + 0.02; double prevPerspective = 1 / prevZ;
      double tailX = center.dx + (startX * size.width * 0.5 * prevPerspective); double tailY = center.dy + (startY * size.height * 0.5 * prevPerspective);
      double alpha = (1.0 - z).clamp(0.0, 1.0); if (z < 0.1) alpha *= (z * 10);
      paint.color = Colors.amber.withOpacity(alpha * 0.8); paint.strokeWidth = (1.0 - z) * 2.0;
      canvas.drawLine(Offset(tailX, tailY), Offset(screenX, screenY), paint);
    }
  }
  @override
  bool shouldRepaint(covariant InfiniteWarpPainter oldDelegate) => oldDelegate.animationValue != animationValue;
}

class TechGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.02)..strokeWidth = 1;
    double step = 40;
    for (double x = 0; x < size.width; x += step) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += step) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}