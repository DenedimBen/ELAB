import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// --- 1. KATEGORİ DETAY EKRANI (LİSTELEME) ---
class CategoryDetailScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;

  const CategoryDetailScreen({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2126),
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.orbitron(color: Colors.amber, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {
              // Direkt Evrensel Görüntüleyiciye Git
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UniversalViewerScreen(
                    title: item['name'],
                    filePath: item['path'], // path: 'assets/...'
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF2B2E36),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // PDF ise PDF ikonu, değilse Resim ikonu
                    child: Icon(
                      item['path'].toString().toLowerCase().endsWith('.pdf') ? Icons.picture_as_pdf : Icons.image,
                      color: item['path'].toString().toLowerCase().endsWith('.pdf') ? Colors.redAccent : Colors.cyanAccent
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        if (item['desc'] != null)
                          Text(item['desc'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- EVRENSEL GÖRÜNTÜLEYİCİ ---
class UniversalViewerScreen extends StatefulWidget {
  final String title;
  final String filePath; // assets/pinouts/dosya.pdf
  final bool isNetwork;

  const UniversalViewerScreen({super.key, required this.title, required this.filePath, this.isNetwork = false});

  @override
  State<UniversalViewerScreen> createState() => _UniversalViewerScreenState();
}

class _UniversalViewerScreenState extends State<UniversalViewerScreen> {
  bool _isSharing = false;

  Future<void> _shareFile() async {
    setState(() => _isSharing = true);
    try {
      final ByteData bytes = await rootBundle.load(widget.filePath);
      final Uint8List list = bytes.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final String fileName = widget.filePath.split('/').last;
      final File file = await File('${tempDir.path}/$fileName').create();
      await file.writeAsBytes(list);
      if (mounted) await Share.shareXFiles([XFile(file.path)], text: 'E-LAB: ${widget.title}');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Uzantı kontrolü (Büyük/Küçük harf duyarlı olmasın diye toLowerCase yaptık)
    bool isPdf = widget.filePath.toLowerCase().endsWith('.pdf');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            onPressed: _isSharing ? null : _shareFile,
            icon: _isSharing 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.download, color: Colors.white),
          )
        ],
      ),
      body: Center(
        child: isPdf
            // --- PDF İSE BURASI ÇALIŞIR ---
            ? SfPdfViewer.asset(
                widget.filePath, 
                enableDoubleTapZooming: true,
                // Hata olursa kullanıcıya göster
                onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                  print("PDF Hatası: ${details.error}");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("PDF Açılamadı: ${details.description}"), backgroundColor: Colors.red));
                },
              )
            // --- RESİM İSE BURASI ÇALIŞIR ---
            : InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.asset(
                  widget.filePath,
                  errorBuilder: (c, o, s) => Column(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [
                      const Icon(Icons.broken_image, color: Colors.grey, size: 50), 
                      const SizedBox(height: 10),
                      Text("Dosya Bulunamadı:\n${widget.filePath}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey))
                    ]
                  ),
                ),
              ),
      ),
    );
  }
}