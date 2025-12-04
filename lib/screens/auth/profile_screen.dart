import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/rank_system.dart';
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
    if (user == null) return;
    try {
      await user!.updateDisplayName(_nameController.text.trim());
      await user!.reload(); // Veriyi tazele
      setState(() => _isEditing = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil güncellendi!"), backgroundColor: Colors.green));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("PROFİLİM", style: GoogleFonts.orbitron(color: Colors.amber, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.grey), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit, color: _isEditing ? Colors.green : Colors.white),
            onPressed: () {
              if (_isEditing) {
                _updateProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          )
        ],
      ),
      body: StreamBuilder<int>(
        stream: FirestoreService().getUserXP(user!.uid),
        builder: (context, snapshot) {
          int xp = snapshot.data ?? 0;
          Rank currentRank = RankSystem.getRank(xp);
          double progress = RankSystem.getProgress(xp);
          int nextXP = RankSystem.getNextLevelXP(xp);

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  // RÜTBE ROZETİ (YENİ - PROFIL FOTOĞRAFI YERİNE)
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: currentRank.color, width: 4),
                      boxShadow: [BoxShadow(color: currentRank.color.withValues(alpha: 0.5), blurRadius: 30)]
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[900],
                      child: Icon(currentRank.icon, size: 50, color: currentRank.color),
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // RÜTBE ADI
                  Text(currentRank.title.toUpperCase(), style: GoogleFonts.orbitron(fontSize: 22, fontWeight: FontWeight.bold, color: currentRank.color, letterSpacing: 1)),
                  Text("$xp XP", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 20),

                  // SEVİYE ÇUBUĞU
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Sonraki Rütbe:", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          Text("$nextXP XP", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.white10,
                          color: currentRank.color,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // İSİM ALANI (DÜZENLENEBİLİR)
                  _isEditing 
                  ? TextField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: "Adınız",
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                      ),
                    )
                  : Text(
                      user?.displayName ?? "İsimsiz Kullanıcı",
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  
                  const SizedBox(height: 10),
                  Text(user?.email ?? "", style: TextStyle(color: Colors.grey[400], fontSize: 14)),

                  const Spacer(),

                  // ÇIKIŞ BUTONU
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await AuthService().signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.redAccent))
                      ),
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      label: const Text("ÇIKIŞ YAP", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
