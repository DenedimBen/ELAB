import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/generated/app_localizations.dart'; // DIL PAKETI
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

  void _pickImage(bool fromCamera) async {
    Navigator.pop(context);
    final image = await StorageService().pickImage(fromCamera: fromCamera);
    if (image != null) setState(() => _selectedImage = image);
  }

  void _submitProject(AppLocalizations text) async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Eksik bilgi!")));
      return;
    }
    setState(() => _isLoading = true);
    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await StorageService().uploadImage(_selectedImage!);
      }
      await FirestoreService().addPost(_titleController.text.trim(), _contentController.text.trim(), imageUrl: imageUrl);
      
      // XP KAZANDIR: Gönderi Paylaşmak +50 XP
      await FirestoreService().addXP(50);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Başarılı! +50 XP"), backgroundColor: Colors.green));
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(text.btnAddProject, style: GoogleFonts.orbitron(color: Colors.amber, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF25282F),
                builder: (ctx) => SizedBox(height: 150, child: Column(children: [
                  ListTile(leading: const Icon(Icons.camera_alt, color: Colors.amber), title: Text(text.camera, style: const TextStyle(color: Colors.white)), onTap: () => _pickImage(true)),
                  ListTile(leading: const Icon(Icons.photo_library, color: Colors.amber), title: Text(text.gallery, style: const TextStyle(color: Colors.white)), onTap: () => _pickImage(false)),
                ]))
              ),
              child: Container(
                height: 250, width: double.infinity,
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24), image: _selectedImage != null ? DecorationImage(image: FileImage(File(_selectedImage!.path)), fit: BoxFit.cover) : null),
                child: _selectedImage == null ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.add_a_photo, size: 50, color: Colors.grey), const SizedBox(height: 10), Text(text.addPhoto, style: const TextStyle(color: Colors.grey))]) : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(controller: _titleController, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), decoration: InputDecoration(hintText: text.postTitleHint, hintStyle: const TextStyle(color: Colors.grey), border: InputBorder.none)),
            const Divider(color: Colors.grey),
            TextField(controller: _contentController, style: const TextStyle(color: Colors.white70, fontSize: 16), maxLines: 5, decoration: InputDecoration(hintText: text.postContentHint, hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)), border: InputBorder.none)),
            const SizedBox(height: 30),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _isLoading ? null : () => _submitProject(text), style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black)) : const Icon(Icons.rocket_launch, color: Colors.black), label: Text(_isLoading ? text.btnSharing : text.btnShare, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)))),
          ],
        ),
      ),
    );
  }
}
