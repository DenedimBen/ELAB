import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference? get _favCollection {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('favorites');
  }

  Future<void> addFavorite(String componentId, String category) async {
    if (_favCollection == null) return;
    await _favCollection!.doc(componentId).set({
      'id': componentId,
      'category': category,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String componentId) async {
    if (_favCollection == null) return;
    await _favCollection!.doc(componentId).delete();
  }

  Stream<bool> isFavorite(String componentId) {
    if (_favCollection == null) return Stream.value(false);
    return _favCollection!.doc(componentId).snapshots().map((snapshot) => snapshot.exists);
  }

  // --- YENİ EKLENEN FONKSİYON: TÜM FAVORİLERİ ÇEK ---
  Stream<List<String>> getFavorites() {
    if (_favCollection == null) return Stream.value([]);
    
    return _favCollection!
        .orderBy('addedAt', descending: true) // En son eklenen en başta
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc['id'] as String).toList();
        });
  }

  // ==================================================
  // --- YENİ: TOPLULUK (COMMUNITY) FONKSİYONLARI ---
  // ==================================================

  // 1. Yeni Gönderi Ekle
  Future<void> addPost(String title, String content) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('posts').add({
      'title': title,
      'content': content,
      'authorName': user.displayName ?? 'Anonim',
      'authorId': user.uid,
      'authorPhoto': user.photoURL,
      'timestamp': FieldValue.serverTimestamp(), // Sunucu saati
      'likes': 0,
    });
  }

  // 2. Gönderileri Canlı Çek (En yeni en üstte)
  Stream<QuerySnapshot> getPosts() {
    return _db.collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 3. Gönderi Güncelle (Sadece başlık ve içerik)
  Future<void> updatePost(String docId, String newTitle, String newContent) async {
    await _db.collection('posts').doc(docId).update({
      'title': newTitle,
      'content': newContent,
      'isEdited': true, // "Düzenlendi" ibaresi için
    });
  }

  // 4. Gönderi Sil
  Future<void> deletePost(String docId) async {
    await _db.collection('posts').doc(docId).delete();
  }

  // ==================================================
  // --- YENİ: YORUM SİSTEMİ (COMMENTS) ---
  // ==================================================

  // 1. Yorum Ekle (Bir gönderinin altına)
  Future<void> addComment(String postId, String content) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 'posts' koleksiyonundaki ilgili belgenin altına 'comments' koleksiyonu açıyoruz
    await _db.collection('posts').doc(postId).collection('comments').add({
      'content': content,
      'authorName': user.displayName ?? 'Anonim',
      'authorId': user.uid,
      'authorPhoto': user.photoURL,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // 2. Yorumları Canlı Çek (Eskiden yeniye doğru)
  Stream<QuerySnapshot> getComments(String postId) {
    return _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false) // Eskiler üstte (WhatsApp gibi)
        .snapshots();
  }

  // ==================================================
  // --- YENİ: BEĞENİ (LIKE) SİSTEMİ ---
  // ==================================================

  // 1. Beğen / Vazgeç (Toggle)
  Future<void> toggleLike(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final likeDoc = _db.collection('posts').doc(postId).collection('likes').doc(user.uid);

    final docSnapshot = await likeDoc.get();

    if (docSnapshot.exists) {
      // Zaten beğenmiş -> Sil (Unlike)
      await likeDoc.delete();
    } else {
      // Beğenmemiş -> Ekle (Like)
      await likeDoc.set({
        'likedAt': FieldValue.serverTimestamp(),
        'userName': user.displayName,
      });
    }
  }

  // 2. Beğeni Sayısını ve Durumunu Dinle
  Stream<bool> isLiked(String postId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(false);
    
    return _db.collection('posts').doc(postId).collection('likes').doc(user.uid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Stream<int> getLikeCount(String postId) {
    return _db.collection('posts').doc(postId).collection('likes')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}