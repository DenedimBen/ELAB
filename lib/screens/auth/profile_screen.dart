import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/firestore_service.dart';
import 'package:flutter_application_1/models/rank_system.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? "";
  }

  Future<void> _updateProfile() async {
    if (user == null || user!.isAnonymous) return; // Misafir düzenleyemez
    try {
      await user!.updateDisplayName(_nameController.text.trim());
      await user!.reload();
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil güncellendi!"), backgroundColor: Colors.green));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red));
    }
  }

  String _getLocalizedRank(String dbRankName, AppLocalizations text) {
    if (dbRankName == "Lehim Dumanı") return text.rank0;
    if (dbRankName == "Direnç Okuyucu") return text.rank1;
    // ... (Diğer rütbeler buraya eklenebilir, yer kaplamasın diye kısalttım)
    return dbRankName; 
  }

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context)!;
    
    // MİSAFİR KONTROLÜ
    bool isGuest = user?.isAnonymous ?? true;

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(text.myProfile, style: GoogleFonts.orbitron(color: Colors.amber, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.grey), onPressed: () => Navigator.pop(context)),
        actions: [
          if (!isGuest) // Sadece üye ise düzenleme butonu göster
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit, color: _isEditing ? Colors.green : Colors.white),
              onPressed: () {
                if (_isEditing) _updateProfile();
                else setState(() => _isEditing = true);
              },
            )
        ],
      ),
      body: isGuest ? _buildGuestView() : _buildUserView(text),
    );
  }

  // --- MİSAFİR GÖRÜNÜMÜ ---
  Widget _buildGuestView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle_outlined, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text("Misafir Kullanıcı", style: GoogleFonts.orbitron(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text("Rütbe sistemi, XP kazanma ve profil düzenleme özellikleri için giriş yapmalısın.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
            child: const Text("GİRİŞ YAP / KAYIT OL", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // --- NORMAL ÜYE GÖRÜNÜMÜ (Eski Kod) ---
  Widget _buildUserView(AppLocalizations text) {
    return StreamBuilder<int>(
      stream: FirestoreService().getUserXP(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        int xp = snapshot.data ?? 0;
        Rank currentRank = RankSystem.getRank(xp);
        int nextXP = RankSystem.getNextLevelXP(xp);
        double progress = RankSystem.getProgress(xp);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: currentRank.color, width: 4), boxShadow: [BoxShadow(color: currentRank.color.withOpacity(0.5), blurRadius: 30)]),
                child: CircleAvatar(radius: 50, backgroundColor: Colors.grey[900], child: Icon(currentRank.icon, size: 50, color: currentRank.color)),
              ),
              const SizedBox(height: 15),
              Text(_getLocalizedRank(currentRank.title, text).toUpperCase(), textAlign: TextAlign.center, style: GoogleFonts.orbitron(fontSize: 22, fontWeight: FontWeight.bold, color: currentRank.color, letterSpacing: 1)),
              const SizedBox(height: 5),
              Text("$xp XP", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: Colors.white10, color: currentRank.color),
              const SizedBox(height: 40),
              _isEditing 
              ? TextField(controller: _nameController, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Adınız", enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber))))
              : Text(user?.displayName ?? "İsimsiz", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 50),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () async { await AuthService().signOut(); if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false); }, icon: const Icon(Icons.logout), label: const Text("ÇIKIŞ YAP"))),
            ],
          ),
        );
      },
    );
  }
}