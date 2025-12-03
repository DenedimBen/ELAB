import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    // Klavye kapanmasın, liste en sona kaysın
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gönderi verileri
    String title = widget.postData['title'] ?? 'Başlıksız';
    String content = widget.postData['content'] ?? '';
    String author = widget.postData['authorName'] ?? 'Anonim';
    String? photo = widget.postData['authorPhoto'];

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      appBar: AppBar(
        backgroundColor: const Color(0xFF202329),
        title: Text("DETAYLAR", style: GoogleFonts.orbitron(color: Colors.amber, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.grey),
      ),
      body: Column(
        children: [
          // 1. ORİJİNAL GÖNDERİ (SABİT ÜST KISIM)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF353A40),
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 14, backgroundImage: photo != null ? NetworkImage(photo) : null, backgroundColor: Colors.blue),
                    const SizedBox(width: 10),
                    Text(author, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 5),
                Text(content, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          // 2. YORUMLAR LİSTESİ (ORTA KISIM)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreService().getComments(widget.postId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.amber));
                
                final comments = snapshot.data!.docs;
                if (comments.isEmpty) {
                  return Center(child: Text("Henüz yorum yok. İlk sen yaz!", style: TextStyle(color: Colors.grey[600])));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(15),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final cData = comments[index].data() as Map<String, dynamic>;
                    return _buildCommentBubble(cData);
                  },
                );
              },
            ),
          ),

          // 3. YORUM YAZMA ALANI (ALT KISIM)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Color(0xFF202329)),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(25)
                      ),
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Bir yorum yaz...",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: Colors.amber,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.black, size: 18),
                      onPressed: _sendComment,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Konuşma Balonu Tasarımı
  Widget _buildCommentBubble(Map<String, dynamic> data) {
    final bool isMe = data['authorId'] == FirebaseAuth.instance.currentUser?.uid;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 250), // Balon çok genişlemesin
        decoration: BoxDecoration(
          color: isMe ? Colors.blue.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(15),
          ),
          border: Border.all(color: isMe ? Colors.blue.withValues(alpha: 0.3) : Colors.transparent)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe) // Başkasının yorumuysa ismini yaz
              Text(data['authorName'] ?? 'Anonim', style: TextStyle(color: Colors.orange[300], fontSize: 10, fontWeight: FontWeight.bold)),
            
            Text(data['content'], style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
