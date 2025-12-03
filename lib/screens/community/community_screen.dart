import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firestore_service.dart';
import 'add_post_screen.dart';
import 'post_detail_screen.dart'; // Yeni ekran

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      floatingActionButton: FloatingActionButton(
        heroTag: 'communityFab', // Benzersiz tag
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPostScreen()));
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
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
                  Text(text.community, style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 2)),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: (user?.photoURL != null) ? NetworkImage(user!.photoURL!) : null,
                    child: (user?.photoURL == null) ? const Icon(Icons.person, size: 16, color: Colors.white) : null,
                  ),
                ],
              ),
            ),

            // CANLI GÖNDERİ LİSTESİ
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirestoreService().getPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.amber));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text(text.errorOccurred, style: const TextStyle(color: Colors.red)));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 60, color: Colors.white.withValues(alpha: 0.1)),
                          const SizedBox(height: 10),
                          Text(text.noPostsYet, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index]; // Dokümanın kendisi (ID için lazım)
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

// PostCard'ı ayrı bir Widget yaptık (Yönetimi kolay olsun diye)
class _PostCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final User? currentUser;

  const _PostCard({required this.data, required this.docId, required this.currentUser});

  void _showEditDialog(BuildContext context) {
    final titleController = TextEditingController(text: data['title']);
    final contentController = TextEditingController(text: data['content']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF25282F),
        title: const Text("Düzenle", style: TextStyle(color: Colors.amber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Başlık", labelStyle: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(labelText: "İçerik", labelStyle: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              await FirestoreService().updatePost(docId, titleController.text, contentController.text);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Kaydet", style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  void _deletePost(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF25282F),
        title: const Text("Sil", style: TextStyle(color: Colors.redAccent)),
        content: const Text("Bu gönderiyi silmek istediğine emin misin?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              await FirestoreService().deletePost(docId);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("SİL", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = data['title'] ?? 'Başlıksız';
    String content = data['content'] ?? '';
    String author = data['authorName'] ?? 'Anonim';
    String authorId = data['authorId'] ?? ''; // Yazarın ID'si
    String? photo = data['authorPhoto'];
    bool isEdited = data['isEdited'] ?? false;

    // BENİM GÖNDERİM Mİ? KONTROLÜ
    bool isMyPost = (currentUser != null && currentUser!.uid == authorId);

    // TIKLAMA ÖZELLİĞİ EKLENDİ
    return GestureDetector(
      onTap: () {
        // Detay sayfasına git
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(postData: data, postId: docId)
          ),
        );
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF353A40),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ÜST SATIR (Profil + İsim + MENÜ)
          Row(
            children: [
              CircleAvatar(
                radius: 12, 
                backgroundColor: Colors.blueAccent, 
                backgroundImage: photo != null ? NetworkImage(photo) : null,
                child: photo == null ? const Icon(Icons.person, size: 14, color: Colors.white) : null
              ),
              const SizedBox(width: 10),
              Text(author, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
              
              const Spacer(),
              
              // EĞER YAZAR BEN İSEM -> MENÜ GÖSTER
              if (isMyPost)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey, size: 18),
                  color: const Color(0xFF25282F),
                  onSelected: (value) {
                    if (value == 'edit') _showEditDialog(context);
                    if (value == 'delete') _deletePost(context);
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [Icon(Icons.edit, color: Colors.amber, size: 16), SizedBox(width: 10), Text("Düzenle", style: TextStyle(color: Colors.white))]),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [Icon(Icons.delete, color: Colors.redAccent, size: 16), SizedBox(width: 10), Text("Sil", style: TextStyle(color: Colors.white))]),
                    ),
                  ],
                )
            ],
          ),
          
          const SizedBox(height: 10),
          
          // BAŞLIK
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))), // Expanded ile taşmayı önle
              if (isEdited) // Düzenlendiyse küçük yazı
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text("(düzenlendi)", style: TextStyle(color: Colors.grey[600], fontSize: 10, fontStyle: FontStyle.italic)),
                )
            ],
          ),
          
          const SizedBox(height: 5),
          
          // İÇERİK
          Text(
            content,
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
            maxLines: 3,
            overflow: TextOverflow.ellipsis, // Uzun yazıyı kes
          ),
          
          const SizedBox(height: 15),
          
          // ALT BUTONLAR (BEĞENİ SİSTEMİ EKLENDİ)
          Row(
            children: [
              // BEĞEN BUTONU
              StreamBuilder<bool>(
                stream: FirestoreService().isLiked(docId),
                builder: (context, snapshotLike) {
                  final isLiked = snapshotLike.data ?? false;
                  
                  return StreamBuilder<int>(
                    stream: FirestoreService().getLikeCount(docId),
                    builder: (context, snapshotCount) {
                      final count = snapshotCount.data ?? 0;
                      
                      return GestureDetector(
                        onTap: () => FirestoreService().toggleLike(docId),
                        child: Row(
                          children: [
                            Icon(
                              isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined, 
                              size: 18, 
                              color: isLiked ? Colors.amber : Colors.grey[600]
                            ),
                            const SizedBox(width: 5),
                            Text("$count", style: TextStyle(color: isLiked ? Colors.amber : Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(width: 20),
              
              // YORUM İKONU (Sadece Görsel)
              Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 5),
              const Text("Yanıtla", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    ),
    );
  }
}