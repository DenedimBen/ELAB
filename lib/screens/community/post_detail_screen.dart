import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_application_1/services/firestore_service.dart';
// DİL DOSYASI (KESİN YOL)
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> postData;
  final String postId;

  const PostDetailScreen({super.key, required this.postData, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context)!;
    
    // TİMEAGO DİL AYARI (Burada yapıyoruz)
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    timeago.setLocaleMessages('en', timeago.EnMessages());
    String currentLang = Localizations.localeOf(context).languageCode;

    // Verileri Hazırla
    String title = widget.postData['title'] ?? 'Başlıksız';
    String content = widget.postData['content'] ?? '';
    String author = widget.postData['authorName'] ?? 'Anonim';
    String? photo = widget.postData['authorPhoto'];
    String? postImage = widget.postData['imageUrl'];
    Timestamp? ts = widget.postData['timestamp'];
    String timeAgo = ts != null ? timeago.format(ts.toDate(), locale: currentLang) : '';

    return Scaffold(
      backgroundColor: const Color(0xFF1E2126),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(text.postDetailTitle, style: const TextStyle(color: Colors.amber)), // DİL DESTEĞİ
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- GÖNDERİ BAŞLIĞI VE DETAYLARI ---
                  Container(
                    padding: const EdgeInsets.all(15),
                    color: const Color(0xFF25282F),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: photo != null ? NetworkImage(photo) : null,
                              child: photo == null ? const Icon(Icons.person) : null,
                            ),
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
                        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(content, style: const TextStyle(color: Colors.white70, fontSize: 15)),
                        
                        if (postImage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(imageUrl: postImage),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // --- YORUMLAR BAŞLIĞI ---
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirestoreService().getComments(widget.postId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        return Text(
                          "${snapshot.data!.docs.length} ${text.comments}", // DİL DESTEĞİ
                          style: const TextStyle(color: Colors.grey),
                        );
                      },
                    ),
                  ),

                  // --- YORUM LİSTESİ ---
                  StreamBuilder<QuerySnapshot>(
                    stream: FirestoreService().getComments(widget.postId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const SizedBox(height: 50, child: Center(child: Text("İlk yorumu sen yaz!", style: TextStyle(color: Colors.grey))));
                      }
                      
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var comment = snapshot.data!.docs[index];
                          var cData = comment.data() as Map<String, dynamic>;
                          var cTime = cData['timestamp'] as Timestamp?;
                          var cTimeAgo = cTime != null ? timeago.format(cTime.toDate(), locale: currentLang) : '';

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2F36),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  backgroundImage: cData['authorPhoto'] != null ? NetworkImage(cData['authorPhoto']) : null,
                                  child: cData['authorPhoto'] == null ? const Icon(Icons.person, size: 15) : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(cData['authorName'] ?? 'Anonim', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                          Text(cTimeAgo, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(cData['content'] ?? '', style: const TextStyle(color: Colors.white70)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 80), // Alt boşluk
                ],
              ),
            ),
          ),
          
          // --- YORUM YAZMA ALANI ---
          CommentInputArea(postId: widget.postId),
        ],
      ),
    );
  }
}

// --- YORUM INPUT WIDGET ---
class CommentInputArea extends StatefulWidget {
  final String postId;
  const CommentInputArea({super.key, required this.postId});

  @override
  State<CommentInputArea> createState() => _CommentInputAreaState();
}

class _CommentInputAreaState extends State<CommentInputArea> {
  final _controller = TextEditingController();
  bool _isSending = false;

  void _sendComment() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    setState(() => _isSending = true);
    
    try {
      await FirestoreService().addComment(widget.postId, content);
      _controller.clear();
      FocusManager.instance.primaryFocus?.unfocus(); // Klavyeyi kapat
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      color: const Color(0xFF25282F),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Yorum yaz...",
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.black12,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: _isSending ? null : _sendComment,
            icon: _isSending 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber))
              : const Icon(Icons.send, color: Colors.amber),
          )
        ],
      ),
    );
  }
}
