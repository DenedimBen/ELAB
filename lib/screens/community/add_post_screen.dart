import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Provider paketi
import 'package:image_picker/image_picker.dart'; // Resim seçme paketi
import 'package:firebase_storage/firebase_storage.dart'; // Resim yükleme
import '../../services/firestore_service.dart';
import '../../providers/pro_provider.dart'; // SENİN PRO PROVIDER DOSYAN

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  // Resim Seçme Fonksiyonu
  Future<void> _pickImage() async {
    final isPro = Provider.of<ProProvider>(context, listen: false).isPro;
    
    // EĞER PRO DEĞİLSE UYARI VER VE ÇIK
    if (!isPro) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Resim eklemek için PRO üye olmalısınız! 🔒"),
          backgroundColor: Colors.redAccent,
        )
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _submitPost() {
    // 1. Doğrulama
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen başlık ve içerik giriniz."))
      );
      return;
    }

    // Verileri yerel değişkenlere al (Ekran kapanınca controller dispose olabilir)
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final imageToUpload = _selectedImage; // Dosya referansını al

    // 2. KULLANICIYI BEKLETMEDEN EKRANI KAPAT 🚀
    Navigator.pop(context);

    // 3. BİLGİ VER (Snackbar)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.cloud_upload, color: Colors.white),
            SizedBox(width: 10),
            Expanded(child: Text("Gönderi arkaplanda yükleniyor...")),
          ],
        ),
        backgroundColor: Colors.blueGrey,
        duration: Duration(seconds: 2),
      )
    );

    // 4. ARKAPLAN İŞLEMİNİ BAŞLAT (Await kullanmıyoruz ki UI kilitlenmesin)
    // Not: Bu işlem context'e bağlı olmamalı çünkü ekran kapandı.
    _uploadInBackground(title, content, imageToUpload);
  }

  // UI'dan bağımsız çalışan fonksiyon
  Future<void> _uploadInBackground(String title, String content, File? imageFile) async {
    try {
      String? imageUrl;

      // Resim varsa yükle
      if (imageFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('post_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      // Firestore'a yaz
      await FirestoreService().addPost(title, content, imageUrl: imageUrl);
      
      // XP KAZANDIR: Gönderi Paylaşmak +50 XP
      await FirestoreService().addXP(50);

      // İŞLEM BİTTİ Mİ? GLOBAL BİR BİLDİRİM GÖSTER (ZORUNLU DEĞİL AMA ŞIK OLUR)
      // Bu kısım biraz ileri seviyedir, basit tutmak için log basabiliriz.
      debugPrint("✅ Yükleme arkaplanda başarıyla tamamlandı!");
      
    } catch (e) {
      debugPrint("❌ Yükleme Hatası: $e");
      // İleride buraya 'Hata oluştu, tekrar dene' bildirimi eklenebilir.
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPro = Provider.of<ProProvider>(context).isPro; // Anlık Pro durumu

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("YENİ KONU AÇ", style: GoogleFonts.orbitron(color: Colors.amber, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "Konu Başlığı (Örn: Kondansatör Patladı)",
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
              ),
            ),
            const SizedBox(height: 10),
            
            // RESİM EKLEME BUTONU (Sadece Pro'lara özel görünüm)
            Row(
              children: [
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image, color: isPro ? Colors.blue : Colors.grey),
                  label: Text(
                    isPro ? (_selectedImage == null ? "Resim Ekle" : "Resim Seçildi ✅") : "Resim Ekle (Pro)",
                    style: TextStyle(color: isPro ? Colors.blue : Colors.grey),
                  ),
                ),
                if (!isPro) const Icon(Icons.lock, size: 14, color: Colors.grey),
              ],
            ),

            Expanded(
              child: TextField(
                controller: _contentController,
                style: const TextStyle(color: Colors.white),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: "Detayları buraya yazın...",
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.black12,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                icon: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black))
                    : const Icon(Icons.send, color: Colors.black),
                label: Text(_isLoading ? "GÖNDERİLİYOR..." : "KONUYU AÇ", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
