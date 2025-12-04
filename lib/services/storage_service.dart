import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // 1. Galeriden veya Kameradan Resim Seç
  Future<XFile?> pickImage({bool fromCamera = false}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 70, // Boyut tasarrufu için kaliteyi düşürdük
      );
      return image;
    } catch (e) {
      print("Resim seçme hatası: $e");
      return null;
    }
  }

  // 2. Resmi Buluta Yükle ve Linkini Al
  Future<String?> uploadImage(XFile imageFile) async {
    try {
      print("📤 Yükleme başlıyor...");
      
      // Dosya uzantısını al (jpg, png, etc.)
      String fileExtension = imageFile.path.split('.').last.toLowerCase();
      if (fileExtension.isEmpty || !['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension)) {
        fileExtension = 'jpg'; // Varsayılan
      }
      
      // Dosya ismi benzersiz olmalı (zaman damgası + rastgele sayı)
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
      
      // Basit yol kullan: images/dosyaadi.jpg (project_images yerine images)
      String storagePath = 'images/$fileName.$fileExtension';
      print("📁 Yol: $storagePath");
      
      Reference ref = _storage.ref().child(storagePath);

      // Yükleme işlemi
      File file = File(imageFile.path);
      print("📦 Dosya boyutu: ${file.lengthSync()} bytes");
      
      UploadTask task = ref.putFile(file);
      
      // Yükleme ilerlemesini takip et (blocking'e neden olmayacak şekilde)
      task.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          print("⏳ Yükleme: ${progress.toStringAsFixed(1)}%");
        },
        onError: (dynamic error) {
          print("❌ Yükleme ilerlemesi hatası: $error");
        },
      );
      
      // Yükleme bitince linki al
      print("⏳ Yüklemenin bitmesini bekliyorum...");
      TaskSnapshot snapshot = await task;
      
      print("📥 Download URL alınıyor...");
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print("✅ Yükleme başarılı! URL: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("❌ Yükleme hatası: $e");
      print("❌ Hata tipi: ${e.runtimeType}");
      if (e.toString().contains('object-not-found')) {
        print("💡 İpucu: Firebase Storage'da 'images' klasörünün var olduğundan emin ol.");
      }
      return null;
    }
  }
}
