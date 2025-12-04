import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Resimler için
import 'package:timeago/timeago.dart' as timeago; // Zaman için
import '../../services/firestore_service.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> postData;
  final String postId;

  const PostDetailScreen({super.key, required this.postData, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;
    await FirestoreService().addComment(widget.postId, _commentController.text.trim());
    _commentController.clear();
    // Listeyi aşağı kaydır
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  // Resmi Tam Ekran Açma Fonksiyonu
  void _openFullScreenImage(String imageUrl) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: InteractiveViewer( // Zoom özelliği
          child: CachedNetworkImage(imageUrl: imageUrl),
        ),
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    // Verileri hazırla
    String title = widget.postData['title'] ?? 'Başlıksız';
    String content = widget.postData['content'] ?? '';
    String author = widget.postData['authorName'] ?? 'Anonim';
    String? authorPhoto = widget.postData['authorPhoto'];
    String? postImage = widget.postData['imageUrl']; // <-- GÖNDERİ RESMİ
    
    // Tarih
    Timestamp? ts = widget.postData['timestamp'];
    String timeAgo = ts != null ? timeago.format(ts.toDate(), locale: 'tr') : '';

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      appBar: AppBar(
        backgroundColor: const Color(0xFF202329),
        title: Text("GÖNDERİ DETAYI", style: GoogleFonts.orbitron(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.grey),
      ),
      body: Column(
        children: [
          // LİSTE (Gönderi + Yorumlar)
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. GÖNDERİ KARTI ---
                  Container(
                    color: const Color(0xFF353A40),
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // GÖNDERİ RESMİ (VARSA)
                        if (postImage != null)
                          GestureDetector(
                            onTap: () => _openFullScreenImage(postImage),
                            child: Hero(
                              tag: postImage, // Animasyon etiketi
                              child: CachedNetworkImage(
                                imageUrl: postImage,
                                width: double.infinity,
                                height: 250,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(height: 250, color: Colors.black12, child: const Center(child: CircularProgressIndicator(color: Colors.amber))),
                              ),
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Yazar ve Tarih
                              Row(
                                children: [
                                  CircleAvatar(radius: 16, backgroundColor: Colors.blue, backgroundImage: authorPhoto != null ? NetworkImage(authorPhoto) : null, child: authorPhoto == null ? const Icon(Icons.person, size: 16, color: Colors.white) : null),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(author, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      Text(timeAgo, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              // Başlık ve İçerik
                              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                              const SizedBox(height: 10),
                              Text(content, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- 2. YORUMLAR BAŞLIĞI ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Text("YORUMLAR", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),

                  // --- 3. YORUMLAR LİSTESİ (STREAM) ---
                  StreamBuilder<QuerySnapshot>(
                    stream: FirestoreService().getComments(widget.postId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: Colors.amber)));
                      
                      final comments = snapshot.data!.docs;
                      if (comments.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(30),
                          alignment: Alignment.center,
                          child: Text("Henüz yorum yok.\nİlk yorumu sen yaz!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                        );
                      }

                      // Yorumları Listele
                      return ListView.builder(
                        shrinkWrap: true, // Scroll içinde scroll olmasın diye
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final cData = comments[index].data() as Map<String, dynamic>;
                          return _buildCommentItem(cData);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 80), // Alt boşluk
                ],
              ),
            ),
          ),

          // --- 4. YORUM YAZMA ALANI (SABİT ALT) ---
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF202329),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, -5))]
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10)),
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(hintText: "Bir yorum yaz...", hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.amber,
                    child: IconButton(icon: const Icon(Icons.send, color: Colors.black, size: 20), onPressed: _sendComment),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // YORUM KARTI TASARIMI
  Widget _buildCommentItem(Map<String, dynamic> data) {
    String author = data['authorName'] ?? 'Anonim';
    String? photo = data['authorPhoto'];
    String content = data['content'] ?? '';
    Timestamp? ts = data['timestamp'];
    String timeAgo = ts != null ? timeago.format(ts.toDate(), locale: 'tr') : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 18, backgroundImage: photo != null ? NetworkImage(photo) : null, child: photo == null ? const Icon(Icons.person, size: 18, color: Colors.white) : null),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(author, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 10),
                    Text(timeAgo, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(content, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.3)),
              ],
            ),
          )
        ],
      ),
    );
  }
}