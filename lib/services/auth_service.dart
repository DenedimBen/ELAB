import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithGoogle() async {
    try {
      print("1. Google Giriş Penceresi Başlatılıyor...");
      // Google hesabını seçtir
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print("⚠️ Kullanıcı Google penceresini kapattı (İptal).");
        return null;
      }
      print("2. Google Hesabı Seçildi: ${googleUser.email}");

      // Kimlik bilgilerini al
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print("3. Tokenlar Alındı. Erişim Tokeni: ${googleAuth.accessToken != null ? 'VAR' : 'YOK'}");

      // Firebase kartını hazırla
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("4. Firebase'e Giriş Yapılıyor...");
      // Firebase'e gir
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      print("✅ BAŞARILI! Giriş Yapan: ${userCredential.user?.displayName}");
      return userCredential.user;

    } catch (e) {
      print("❌ GİRİŞ HATASI (DETAYLI): $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
      await _auth.signOut();
      print("🚪 Çıkış Yapıldı.");
    } catch (e) {
      print("Çıkış hatası: $e");
    }
  }
}