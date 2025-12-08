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

  // 1. Yeni Gönderi Ekle (Resim destekli + Oylama + Promosyon)
  Future<void> addPost(String title, String content, {String? imageUrl}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('posts').add({
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'authorName': user.displayName ?? 'Anonim',
      'authorId': user.uid,
      'authorPhoto': user.photoURL,
      'timestamp': FieldValue.serverTimestamp(),
      'lastActivity': FieldValue.serverTimestamp(), // FORUM MANTIĞI: Son hareket tarihi
      'viewCount': 0, // Görüntülenme sayısı
      'upvotes': [],   // Beğenenlerin listesi (UID)
      'downvotes': [], // Beğenmeyenlerin listesi (UID)
      'isPromoted': false, // Öne çıkarılmış mı?
      'promotedUntil': null, // Ne zamana kadar öne çıkacak?
      'likes': 0, // Eski sistem (geriye dönük uyumluluk)
    });
  }

  // 2. Gönderileri Canlı Çek (En yeni en üstte)
  Stream<QuerySnapshot> getPosts() {
    return _db.collection('posts')
        .orderBy('lastActivity', descending: true)
        .snapshots();
  }

  // YENİ: Görüntülenme Sayısını Artır
  Future<void> incrementViewCount(String postId) async {
     // Anlık çok fazla yazma olmaması için basit bir artırma
     await _db.collection('posts').doc(postId).update({
       'viewCount': FieldValue.increment(1),
     });
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

    // 2. Ana gönderinin "lastActivity" alanını güncelle (Konu yukarı çıkar)
    await _db.collection('posts').doc(postId).update({
      'lastActivity': FieldValue.serverTimestamp(),
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

  // ==================================================
  // --- YENİ: OYLAMA SİSTEMİ (Reddit/Forum Tarzı) ---
  // ==================================================

  // 1. Oylama (+ veya - ile)
  Future<void> votePost(String postId, bool isUpvote) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _db.collection('posts').doc(postId);
    
    // Transaction kullanarak anlık çakışmaları önlüyoruz
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data();
      List<dynamic> upvotes = List.from(data?['upvotes'] ?? []);
      List<dynamic> downvotes = List.from(data?['downvotes'] ?? []);
      String uid = user.uid;

      if (isUpvote) {
        // ARTI OY VERİLDİ
        if (upvotes.contains(uid)) {
          upvotes.remove(uid); // Zaten vermişse geri al
        } else {
          upvotes.add(uid);    // Ekle
          downvotes.remove(uid); // Eksideyse oradan sil
        }
      } else {
        // EKSİ OY VERİLDİ
        if (downvotes.contains(uid)) {
          downvotes.remove(uid); // Zaten vermişse geri al
        } else {
          downvotes.add(uid);    // Ekle
          upvotes.remove(uid);   // Artıdaysa oradan sil
        }
      }

      transaction.update(docRef, {
        'upvotes': upvotes,
        'downvotes': downvotes
      });
    });
  }

  // 2. ÖNE ÇIKARMA (BOOST)
  Future<void> boostPost(String postId, int days) async {
    // Gerçek uygulamada burada ödeme kontrolü yapılır
    await _db.collection('posts').doc(postId).update({
      'isPromoted': true,
      'promotedUntil': DateTime.now().add(Duration(days: days)),
    });
  }

  // 3. Bir gönderinin yorum sayısını dinle
  Stream<int> getCommentCount(String postId) {
    return _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ==================================================
  // --- YENİ: OYUNLAŞTIRMA (XP SİSTEMİ) ---
  // ==================================================

  // Kullanıcıya XP Ekle
  Future<void> addXP(int amount) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = _db.collection('users').doc(user.uid);

    // Transaction ile güvenli artırma (Çakışmayı önler)
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);
      
      if (!snapshot.exists) {
        // İlk kez XP kazanıyorsa döküman oluştur
        transaction.set(userDoc, {'xp': amount});
      } else {
        int currentXP = snapshot.data().toString().contains('xp') ? snapshot.get('xp') : 0;
        transaction.update(userDoc, {'xp': currentXP + amount});
      }
    });
  }

  // Kullanıcının XP'sini Dinle
  Stream<int> getUserXP(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data().toString().contains('xp')) {
        return doc.get('xp') as int;
      }
      return 0; // Hiç puanı yoksa 0
    });
  }
}