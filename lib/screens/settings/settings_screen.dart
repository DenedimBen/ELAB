import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/providers/locale_provider.dart';
// DİL DOSYASI (KESİN YOL)
import 'package:flutter_application_1/l10n/generated/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dil dosyasına erişim
    final text = AppLocalizations.of(context)!;
    final provider = Provider.of<LocaleProvider>(context);
    final currentLang = provider.locale.languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(text.settingsTitle, style: GoogleFonts.orbitron(color: Colors.amber)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("GENEL", style: GoogleFonts.teko(color: Colors.grey, fontSize: 16, letterSpacing: 2)),
            const SizedBox(height: 10),

            // --- DİL DEĞİŞTİRME KARTI ---
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2126),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.language, color: Colors.blueAccent),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Text("Dil / Language", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  
                  // DİL SEÇİM BUTONLARI
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _buildLangButton(context, "TR", "tr", currentLang == "tr"),
                        _buildLangButton(context, "EN", "en", currentLang == "en"),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangButton(BuildContext context, String title, String code, bool isActive) {
    return GestureDetector(
      onTap: () {
        Provider.of<LocaleProvider>(context, listen: false).setLocale(Locale(code));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.amber : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}