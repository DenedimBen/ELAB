import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screen.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );

    _controller.forward();

    // 3. YÖNLENDİRME MANTIĞI (DÜZELTİLDİ)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        User? user;
        try {
          // Firebase başlatılmadıysa burası hata verebilir
          user = FirebaseAuth.instance.currentUser;
        } catch (e) {
          print("Splash: Firebase Auth erişim hatası (Web config eksik olabilir): $e");
          user = null;
        }
        
        if (user != null) {
          // Evet -> Ana Ekrana git
          print("Kullanıcı zaten giriş yapmış: ${user.email}");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          // Hayır -> Login Ekranına git
          print("Kullanıcı yok, Login'e gidiliyor.");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202329),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO (DÜZELTİLDİ)
                Container(
                  padding: const EdgeInsets.all(10), // Padding azaltıldı, logo büyüdü
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // color: Colors.black, // <-- BU SATIR SİLİNDİ, ARTIK ŞEFFAF
                    boxShadow: [
                      BoxShadow(color: Colors.amber.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 10)
                    ]
                  ),
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 150, height: 150, // Logo boyutu 100'den 150'ye çıktı
                    errorBuilder: (c,e,s) => const Icon(Icons.bolt, size: 120, color: Colors.amber),
                  ),
                ),
                const SizedBox(height: 40),
                
                Text("E-LAB", style: GoogleFonts.orbitron(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 5, shadows: [BoxShadow(color: Colors.amber.withValues(alpha: 0.8), blurRadius: 25)])),
                Text("ELECTRONIC ASSISTANT", style: TextStyle(color: Colors.grey[400], fontSize: 12, letterSpacing: 3)),
                
                const SizedBox(height: 60),
                const SizedBox(width: 150, child: LinearProgressIndicator(color: Colors.amber, backgroundColor: Colors.black12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}