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
                      return _ForumPostCard(data: data, docId: doc.id, currentUser: user, text: text);
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

// --- FORUM KARTI ---
class _ForumPostCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final User? currentUser;
  final AppLocalizations text; // Dil değişkeni buraya da geldi

  const _ForumPostCard({required this.data, required this.docId, required this.currentUser, required this.text});

  void _showBoostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF25282F),
        title: const Text("🚀 Öne Çıkar", style: TextStyle(color: Colors.amber)),
        content: const Text(
          "Bu gönderiyi 24 saat boyunca en üstte göstermek ister misin?\n(Demo: Ücretsiz)",
          style: TextStyle(color: Colors.white70)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              FirestoreService().boostPost(docId, 1);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Gönderi Öne Çıkarıldı! 🚀"),
                  backgroundColor: Colors.green
                )
              );
            },
            child: const Text(
              "Öne Çıkar",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
            )
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // Verileri Ayrıştır
    String title = data['title'] ?? 'Başlıksız';
    String content = data['content'] ?? '';
    String author = data['authorName'] ?? 'Anonim';
    String? authorId = data['authorId'];
    String? photo = data['authorPhoto'];
    String? postImage = data['imageUrl'];
    
    // Oylama Verileri
    List upvotes = data['upvotes'] ?? [];
    List downvotes = data['downvotes'] ?? [];
    int score = upvotes.length - downvotes.length;
    bool isUpvoted = currentUser != null && upvotes.contains(currentUser!.uid);
    bool isDownvoted = currentUser != null && downvotes.contains(currentUser!.uid);
    
    // Öne Çıkarılmış mı?
    bool isPromoted = data['isPromoted'] ?? false;

    // Zaman
    Timestamp? ts = data['timestamp'];
    String timeAgo = ts != null ? timeago.format(ts.toDate(), locale: 'tr') : 'şimdi';

    bool isMe = currentUser?.uid == authorId;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(postData: data, postId: docId)
          )
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF30353C),
          borderRadius: BorderRadius.circular(15),
          border: isPromoted 
            ? Border.all(color: Colors.amber, width: 2)
            : Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5)
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER (Yazar, Tarih, Ayarlar)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue,
                    backgroundImage: photo != null ? NetworkImage(photo) : null,
                    child: photo == null ? const Icon(Icons.person, size: 16, color: Colors.white) : null
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            author,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13
                            )
                          ),
                          if (isPromoted)
                            Container(
                              margin: const EdgeInsets.only(left: 5),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(4)
                              ),
                              child: Text(
                                text.promoted,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold
                                )
                              )
                            )
                        ],
                      ),
                      Text(
                        timeAgo,
                        style: TextStyle(color: Colors.grey[500], fontSize: 11)
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (isMe)
                    IconButton(
                      icon: const Icon(Icons.rocket_launch, color: Colors.amber, size: 20),
                      onPressed: () => _showBoostDialog(context),
                    )
                ],
              ),
            ),

            // 2. MEDYA (RESİM) - Optimize Edilmiş
            if (postImage != null)
              CachedNetworkImage(
                imageUrl: postImage,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                memCacheHeight: 500, // PERFORMANS SIRRI
                placeholder: (context, url) => Container(
                  height: 250,
                  color: Colors.black12,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.amber)
                  )
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.error,
                  color: Colors.red
                ),
              ),

            // 3. İÇERİK (Başlık ve Metin)
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    )
                  ),
                  const SizedBox(height: 5),
                  Text(
                    content,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis
                  ),
                ],
              ),
            ),
            
            const Divider(color: Colors.white10, height: 1),

            // 4. ALT BAR (GÜNCELLENMİŞ: AYRI LIKE/DISLIKE VE YORUM SAYISI)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  // --- LIKE KISMI ---
                  StreamBuilder<bool>(
                    stream: FirestoreService().isLiked(docId),
                    builder: (context, snapIsLiked) {
                      final isLiked = snapIsLiked.data ?? false;
                      
                      return StreamBuilder<int>(
                        stream: FirestoreService().getLikeCount(docId),
                        builder: (context, snapCount) {
                          final count = snapCount.data ?? 0;
                          return InkWell(
                            onTap: () => FirestoreService().toggleLike(docId),
                            child: Row(
                              children: [
                                Icon(
                                  isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt,
                                  size: 20,
                                  color: isLiked ? Colors.blueAccent : Colors.grey
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "$count",
                                  style: TextStyle(
                                    color: isLiked ? Colors.blueAccent : Colors.grey,
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(width: 20),

                  // --- DISLIKE KISMI (Downvotes) ---
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('posts').doc(docId).snapshots(),
                    builder: (context, snapDoc) {
                      if (!snapDoc.hasData) return const SizedBox();
                      final postData = snapDoc.data!.data() as Map<String, dynamic>;
                      final downvotes = (postData['downvotes'] as List?)?.length ?? 0;
                      final isDisliked = (postData['downvotes'] as List?)?.contains(currentUser?.uid) ?? false;

                      return InkWell(
                        onTap: () => FirestoreService().votePost(docId, false),
                        child: Row(
                          children: [
                            Icon(
                              isDisliked ? Icons.thumb_down : Icons.thumb_down_off_alt,
                              size: 20,
                              color: isDisliked ? Colors.redAccent : Colors.grey
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "$downvotes",
                              style: TextStyle(
                                color: isDisliked ? Colors.redAccent : Colors.grey,
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const Spacer(),
                  
                  // --- YORUM SAYISI (CANLI) ---
                  StreamBuilder<int>(
                    stream: FirestoreService().getCommentCount(docId),
                    builder: (context, snapComments) {
                      return Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text("${snapComments.data ?? 0} ${text.comments}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
