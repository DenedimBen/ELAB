import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

// IMPORTLAR (Tam Yol - Hata Almamak İçin)
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';
import 'package:flutter_application_1/services/firestore_service.dart';
import 'package:flutter_application_1/screens/community/add_post_screen.dart'; // Dosya adın add_project_screen ise burayı düzelt
import 'package:flutter_application_1/screens/community/post_detail_screen.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context)!;
    
    // Timeago Dil Ayarlarını Yükle
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    timeago.setLocaleMessages('en', timeago.EnMessages());
    
    // Geçerli dili algıla
    String currentLang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFF1E2126), // Ana tema rengi ile uyumlu
      
      // EKLEME BUTONU
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser == null || currentUser.isAnonymous) {
            _showGuestAlert(context);
          } else {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const AddPostScreen()) // add_post_screen.dart
            );
          }
        },
        backgroundColor: Colors.amber,
        icon: const Icon(Icons.add_a_photo, color: Colors.black),
        label: Text(text.btnAddProject, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER (BAŞLIK VE PROFİL RESMİ) ---
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2126),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text.forumTitle, style: GoogleFonts.orbitron(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1.5)),
                      const SizedBox(height: 2),
                      Text(text.forumSubtitle, style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.amber.withOpacity(0.5))),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: (user?.photoURL != null) ? NetworkImage(user!.photoURL!) : null,
                      child: (user?.photoURL == null) ? const Icon(Icons.person, size: 18, color: Colors.white) : null,
                    ),
                  ),
                ],
              ),
            ),

            // --- GÖNDERİ LİSTESİ (STREAM) ---
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirestoreService().getPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.amber));
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text(text.noPostsYet, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])));
                  }

                  final docs = snapshot.data!.docs;
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return _ForumThreadTile(
                        data: data, 
                        docId: doc.id, 
                        currentUser: user, 
                        langCode: currentLang
                      );
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

  // MİSAFİR UYARI PENCERESİ
  void _showGuestAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2E3239),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.amber.withOpacity(0.5))),
        title: Row(
          children: [
            const Icon(Icons.lock_outline, color: Colors.amber),
            const SizedBox(width: 10),
            Text("Misafir Modu", style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          "Toplulukta paylaşım yapmak için üye olman gerekiyor. Misafirler sadece içerikleri görüntüleyebilir.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (context) => const LoginScreen()), 
                (route) => false
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text("Giriş Yap", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// --- FORUM KARTI (KOMPAKT TASARIM) ---
class _ForumThreadTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final User? currentUser;
  final String langCode;

  const _ForumThreadTile({required this.data, required this.docId, required this.currentUser, required this.langCode});

  @override
  Widget build(BuildContext context) {
    String title = data['title'] ?? 'Başlıksız';
    String author = data['authorName'] ?? 'Anonim';
    bool isPromoted = data['isPromoted'] ?? false;
    int viewCount = data['viewCount'] ?? 0;
    
    // Tarih Hesaplama
    Timestamp? lastAct = data['timestamp']; // Veritabanındaki alan adı genelde 'timestamp' olur
    String timeAgo = lastAct != null ? timeago.format(lastAct.toDate(), locale: langCode) : '...';

    return GestureDetector(
      onTap: () {
        // Görüntülenme artır
        try { FirestoreService().incrementViewCount(docId); } catch(e) {/* Hata yok say */}
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(postData: data, postId: docId)
          )
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isPromoted ? const Color(0xFF2A2418) : const Color(0xFF2B2E36),
          borderRadius: BorderRadius.circular(12),
          border: isPromoted 
            ? Border.all(color: Colors.amber.withOpacity(0.4), width: 1)
            : Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ÜST BİLGİ (Yazar ve Tarih)
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage: data['authorPhoto'] != null ? NetworkImage(data['authorPhoto']) : null,
                  child: data['authorPhoto'] == null ? Icon(Icons.person, size: 14, color: Colors.grey[400]) : null,
                ),
                const SizedBox(width: 8),
                Text(author, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                const Spacer(),
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(timeAgo, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              ],
            ),
            
            const SizedBox(height: 10),

            // ORTA KISIM (Başlık ve İkon)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPromoted) 
                  const Padding(padding: EdgeInsets.only(right: 8, top: 2), child: Icon(Icons.star, size: 16, color: Colors.amber)),
                
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.white.withOpacity(0.05), height: 1),
            const SizedBox(height: 8),

            // ALT KISIM (İstatistikler)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Görüntülenme
                Icon(Icons.remove_red_eye, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text("$viewCount", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                
                const SizedBox(width: 15),

                // Yorum Sayısı (StreamBuilder ile canlı)
                StreamBuilder<int>(
                  stream: FirestoreService().getCommentCount(docId),
                  builder: (context, snapshot) {
                    return Row(
                      children: [
                        const Icon(FontAwesomeIcons.comment, size: 14, color: Colors.blueAccent),
                        const SizedBox(width: 5),
                        Text("${snapshot.data ?? 0}", style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}