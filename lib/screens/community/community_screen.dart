import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import 'add_project_screen.dart'; // <-- YENİ EKRANI BAĞLADIK
import 'post_detail_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // BURASI ARTIK PROJE EKLEMEYE GİDİYOR
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProjectScreen()));
        },
        backgroundColor: Colors.amber,
        icon: const Icon(Icons.camera_alt, color: Colors.black),
        label: const Text("PROJE EKLE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("PROJE VİTRİNİ", style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 2)),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: (user?.photoURL != null) ? NetworkImage(user!.photoURL!) : null,
                    child: (user?.photoURL == null) ? const Icon(Icons.person, size: 16, color: Colors.white) : null,
                  ),
                ],
              ),
            ),

            // AKIŞ
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirestoreService().getPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.amber));
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("Henüz proje yok.\nİlk sen paylaş!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])));
                  }

                  final docs = snapshot.data!.docs;
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return _PostCard(data: data, docId: doc.id, currentUser: user);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// GÖRSEL AĞIRLIKLI KART
class _PostCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final User? currentUser;

  const _PostCard({required this.data, required this.docId, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    String title = data['title'] ?? 'Başlıksız';
    String author = data['authorName'] ?? 'Anonim';
    String? postImage = data['imageUrl']; // <-- GÖNDERİ RESMİ

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailScreen(postData: data, postId: docId)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF353A40),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. BÜYÜK GÖRSEL (VİTRİN)
            if (postImage != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  postImage,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(height: 200, color: Colors.black12, child: const Center(child: CircularProgressIndicator(color: Colors.amber)));
                  },
                ),
              ),

            // 2. BİLGİLER
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text("Yapan: $author", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const Spacer(),
                      // Beğeni Sayısı (Şimdilik statik veya servisten çekilebilir)
                      const Icon(Icons.favorite, size: 16, color: Colors.redAccent),
                      const SizedBox(width: 5),
                      // Buraya dinamik beğeni sayısı gelecek
                      const Text("Beğen", style: TextStyle(color: Colors.white70, fontSize: 12))
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
