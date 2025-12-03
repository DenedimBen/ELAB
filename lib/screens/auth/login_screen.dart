import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth_service.dart';
import '../main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    
    try {
      final user = await AuthService().signInWithGoogle();
      
      if (user != null && mounted) {
        print("✅ Giriş Başarılı: ${user.displayName}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        print("❌ Kullanıcı girişi iptal edildi");
      }
    } catch (e) {
      print("❌ Google Sign-In Hatası: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Giriş başarısız: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202329),
      body: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: GridPainter()),
          
          Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 5)]
                    ),
                    child: Image.asset('assets/images/app_icon.png', height: 120, errorBuilder: (c,e,s) => const Icon(Icons.bolt, size: 80, color: Colors.amber)),
                  ),
                  const SizedBox(height: 40),
                  
                  Text("HOŞ GELDİNİZ", style: GoogleFonts.orbitron(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Text("Elektronik Dünyasına Giriş Yapın", style: TextStyle(color: Colors.grey[400], fontSize: 14)),

                  const SizedBox(height: 60),

                  // --- GOOGLE BUTONU (GÜNCELLENDİ) ---
                  _isLoading 
                  ? const CircularProgressIndicator(color: Colors.amber)
                  : GestureDetector(
                      onTap: _signInWithGoogle,
                      child: Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.1), blurRadius: 10)]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 22), // <-- ARTIK RESİM DEĞİL İKON
                            SizedBox(width: 15),
                            Text("Google ile Devam Et", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16, height: 1.0)),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
                  
                  // --- APPLE BUTONU ---
                  GestureDetector(
                    onTap: () {}, 
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white24)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          FaIcon(FontAwesomeIcons.apple, color: Colors.white, size: 26), // <-- VEKTÖREL İKON
                          SizedBox(width: 15),
                          Text("Apple ile Devam Et", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, height: 1.0)),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  Text("Hesap oluşturarak Gizlilik Politikasını kabul etmiş olursunuz.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                ],
              ),
            ),
          ),
        ],
      ),
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