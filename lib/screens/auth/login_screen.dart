import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math; // Matematik işlemleri için
import '../../services/auth_service.dart';
import '../main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animController; // Arka plan animasyonu için

  @override
  void initState() {
    super.initState();
    // Sonsuz dönen animasyon (10 saniyede bir tur)
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // --- GOOGLE GİRİŞ ---
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final user = await AuthService().signInWithGoogle();
      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Giriş başarısız: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- MİSAFİR GİRİŞ ---
  Future<void> _signInGuest() async {
    setState(() => _isLoading = true);
    try {
      final user = await AuthService().signInAnonymously();
      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Misafir girişi hatası: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115), // Daha derin bir siyah
      body: Stack(
        children: [
          // 1. HAREKETLİ ARKA PLAN (Grid ve Partiküller)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return CustomPaint(
                  painter: TechBackgroundPainter(animationValue: _animController.value),
                );
              },
            ),
          ),

          // 2. GRADIENT KARARTMA (Yazıların okunması için)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0F1115).withOpacity(0.9), // Alt taraf daha karanlık
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),

          // 3. İÇERİK
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2), // Üst boşluk

                  // --- LOGO ALANI ---
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                      border: Border.all(color: Colors.amber.withOpacity(0.3), width: 2),
                      boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.2), blurRadius: 50, spreadRadius: 10)],
                    ),
                    child: Image.asset('assets/images/app_icon.png', height: 100, errorBuilder: (c,e,s) => const Icon(Icons.bolt, size: 80, color: Colors.amber)),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  Text("HOŞ GELDİNİZ", style: GoogleFonts.orbitron(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
                  const SizedBox(height: 10),
                  Text("Elektronik Dünyasına Giriş Yapın", style: TextStyle(color: Colors.grey[400], fontSize: 14, letterSpacing: 1)),

                  const Spacer(flex: 2),

                  // --- BUTONLAR ---
                  if (_isLoading)
                    const CircularProgressIndicator(color: Colors.amber)
                  else
                    Column(
                      children: [
                        // GOOGLE BUTONU
                        _buildSocialButton(
                          icon: FontAwesomeIcons.google,
                          color: Colors.red,
                          text: "Google ile Devam Et",
                          onTap: _signInWithGoogle,
                        ),

                        const SizedBox(height: 15),

                        // APPLE BUTONU
                        _buildSocialButton(
                          icon: FontAwesomeIcons.apple,
                          color: Colors.white,
                          text: "Apple ile Devam Et",
                          onTap: () {}, // Apple login fonksiyonu buraya
                          isBlack: true,
                        ),
                      ],
                    ),

                  const SizedBox(height: 25),

                  // --- ŞIK MİSAFİR BUTONU (EN ALTA YAKIN) ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _signInGuest,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.cyanAccent.withOpacity(0.5), width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        backgroundColor: Colors.cyanAccent.withOpacity(0.05), // Hafif neon dolgu
                      ),
                      child: Text(
                        "MİSAFİR OLARAK GİRİŞ YAP",
                        style: GoogleFonts.orbitron(
                          color: Colors.cyanAccent, 
                          fontSize: 14, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  Text("Hesap oluşturarak Gizlilik Politikasını kabul etmiş olursunuz.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700], fontSize: 10)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Yardımcı Buton Widget'ı
  Widget _buildSocialButton({required IconData icon, required Color color, required String text, required VoidCallback onTap, bool isBlack = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          color: isBlack ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: isBlack ? Border.all(color: Colors.white24) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, color: color, size: 22),
            const SizedBox(width: 15),
            Text(text, style: TextStyle(color: isBlack ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// --- HAREKETLİ TEKNOLOJİK ARKA PLAN ---
class TechBackgroundPainter extends CustomPainter {
  final double animationValue; // 0.0 ile 1.0 arasında değer alır
  TechBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05) // Çok silik çizgiler
      ..strokeWidth = 1;

    // 1. Kayan Izgara (Grid)
    double gridSize = 40.0;
    double offset = animationValue * gridSize; // Hareket ettiren kısım

    // Dikey Çizgiler
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Yatay Çizgiler (Aşağı doğru kayar)
    for (double y = offset - gridSize; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 2. Rastgele Parlayan Noktalar (Data Nodes)
    final random = math.Random(42); // Sabit seed, noktalar titremesin diye
    final dotPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 15; i++) {
      // Noktalar da hafifçe hareket etsin
      double x = (random.nextDouble() * size.width);
      double y = (random.nextDouble() * size.height + animationValue * 100) % size.height;
      
      dotPaint.color = Colors.amber.withOpacity(random.nextDouble() * 0.3); // Rastgele parlaklık
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 2 + 1, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TechBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue; // Animasyon değiştikçe tekrar çiz
  }
}