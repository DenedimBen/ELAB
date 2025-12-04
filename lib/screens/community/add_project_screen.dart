import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  XFile? _selectedImage;
  bool _isLoading = false;

  // Resim Seçme Penceresi
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF25282F),
      builder: (context) => SizedBox(
        height: 150,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.amber),
              title: const Text("Kamera", style: TextStyle(color: Colors.white)),
              onTap: () => _pickImage(true),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.amber),
              title: const Text("Galeri", style: TextStyle(color: Colors.white)),
              onTap: () => _pickImage(false),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage(bool fromCamera) async {
    Navigator.pop(context); // Menüyü kapat
    final image = await StorageService().pickImage(fromCamera: fromCamera);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  void _shareProject() async {
    if (_titleController.text.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen bir resim ve başlık ekleyin!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;

      // 1. Resmi Yükle
      print("📤 Resim yükleniyor...");
      imageUrl = await StorageService().uploadImage(_selectedImage!);
      
      if (imageUrl == null) {
        throw Exception("Resim yüklenemedi!");
      }

      // 2. Veritabanına Kaydet
      print("💾 Firestore'a kaydediliyor...");
      await FirestoreService().addPost(
        _titleController.text.trim(),
        _contentController.text.trim(),
        imageUrl: imageUrl,
      );

      print("✅ Başarıyla kaydedildi!");

      if (mounted) {
        Navigator.pop(context); // Ekranı kapat
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Proje Vitrine Eklendi! 🚀"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("❌ Hata: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Hata oluştu: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      // HER DURUMDA loading'i kapat
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("YENİ PROJE", style: GoogleFonts.orbitron(color: Colors.amber, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RESİM ALANI
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                  image: _selectedImage != null 
                    ? DecorationImage(image: FileImage(File(_selectedImage!.path)), fit: BoxFit.cover)
                    : null
                ),
                child: _selectedImage == null 
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("Fotoğraf Ekle", style: TextStyle(color: Colors.grey))
                      ],
                    )
                  : null,
              ),
            ),
            
            const SizedBox(height: 20),

            // BAŞLIK
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "Proje Başlığı",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none
              ),
            ),

            const Divider(color: Colors.grey),

            // AÇIKLAMA
            TextField(
              controller: _contentController,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Bu devrede ne yaptın? Hangi malzemeleri kullandın?",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none
              ),
            ),

            const SizedBox(height: 30),

            // BUTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _shareProject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                icon: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : const Icon(Icons.rocket_launch, color: Colors.black),
                label: Text(_isLoading ? "YÜKLENİYOR..." : "VİTRİNDE PAYLAŞ", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
