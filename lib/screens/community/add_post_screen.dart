import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firestore_service.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  void _submitPost() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) return;

    setState(() => _isLoading = true);

    await FirestoreService().addPost(
      _titleController.text.trim(), 
      _contentController.text.trim()
    );

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context); // Ekranı kapat ve listeye dön
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gönderi paylaşıldı! 🚀"), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("YENİ GÖNDERİ", style: GoogleFonts.orbitron(color: Colors.amber, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Başlık Alanı
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "Başlık (Örn: IRF3205 Isınma Sorunu)",
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
              ),
            ),
            const SizedBox(height: 20),
            
            // İçerik Alanı
            Expanded(
              child: TextField(
                controller: _contentController,
                style: const TextStyle(color: Colors.white),
                maxLines: null, // Çok satırlı
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: "Detayları buraya yazın...",
                  hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.black12,
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // Paylaş Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                icon: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Icon(Icons.send, color: Colors.black),
                label: Text(_isLoading ? "PAYLAŞILIYOR..." : "PAYLAŞ", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
