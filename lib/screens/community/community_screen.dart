import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../l10n/generated/app_localizations.dart'; // DIL PAKETI
import '../../services/firestore_service.dart';
import 'add_project_screen.dart';
import 'post_detail_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final text = AppLocalizations.of(context)!; // DİL DEĞİŞKENİ

    return Scaffold(
      backgroundColor: const Color(0xFF202329),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProjectScreen()));
        },
        backgroundColor: Colors.amber,
        icon: const Icon(Icons.add_a_photo, color: Colors.black),
        label: Text(text.btnAddProject, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text.forumTitle, style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 2)),
                      Text(text.forumSubtitle, style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 3)),
                    ],
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: (user?.photoURL != null) ? NetworkImage(user!.photoURL!) : null,
                    child: (user?.photoURL == null) ? const Icon(Icons.person, size: 18, color: Colors.white) : null,
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
                    return Center(child: Text(text.noPostsYet, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])));
                  }

                  final docs = snapshot.data!.docs;
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return _ForumThreadTile(data: data, docId: doc.id, currentUser: user, text: text);
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

// --- FORUM SATIRI (YENİ KOMPAKT TASARIM) ---
class _ForumThreadTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final User? currentUser;
  final AppLocalizations text;

  const _ForumThreadTile({required this.data, required this.docId, required this.currentUser, required this.text});

  @override
  Widget build(BuildContext context) {
    // Verileri Çek
    String title = data['title'] ?? 'Başlıksız';
    String author = data['authorName'] ?? 'Anonim';
    bool isPromoted = data['isPromoted'] ?? false;
    int viewCount = data['viewCount'] ?? 0;
    
    // Son Hareket Tarihi
    Timestamp? lastAct = data['lastActivity'];
    String timeAgo = lastAct != null ? timeago.format(lastAct.toDate(), locale: 'tr') : 'yeni';

    return GestureDetector(
      onTap: () {
        // Tıklanınca Görüntülenmeyi Artır
        FirestoreService().incrementViewCount(docId);
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(postData: data, postId: docId)
          )
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8), // Satırlar arası boşluk azaldı
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPromoted ? const Color(0xFF2A2418) : const Color(0xFF2B2E36), // Öne çıkanlar hafif sarımsı
          borderRadius: BorderRadius.circular(8),
          border: isPromoted 
            ? Border.all(color: Colors.amber.withOpacity(0.5), width: 1)
            : Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SOL İKON (Konu Durumu)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                isPromoted ? Icons.rocket_launch : Icons.forum_outlined,
                color: isPromoted ? Colors.amber : Colors.blueGrey,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // 2. ORTA KISIM (Başlık ve Yazar)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Alt Bilgi (Yazar • Tarih)
                  Row(
                    children: [
                      Icon(Icons.person, size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        author,
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        timeAgo,
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // 3. SAĞ KISIM (İstatistikler)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Cevap Sayısı
                StreamBuilder<int>(
                  stream: FirestoreService().getCommentCount(docId),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chat_bubble, size: 12, color: Colors.blueAccent),
                          const SizedBox(width: 4),
                          Text(
                            "$count",
                            style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),
                // Görüntülenme Sayısı
                Row(
                  children: [
                    const Icon(Icons.visibility, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "$viewCount", // firestore_service'e viewCount eklemiştik
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}


