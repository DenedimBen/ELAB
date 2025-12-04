import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/pro_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final proProvider = Provider.of<ProProvider>(context);
    final text = AppLocalizations.of(context)!; // Çeviri nesnesi

    return Scaffold(
      backgroundColor: const Color(0xFF2E3239),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          text.settings,
          style: GoogleFonts.orbitron(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- PRO ÜYELİK KARTI ---
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)]), // Altın Rengi
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.4), blurRadius: 15)]
              ),
              child: Row(
                children: [
                  Icon(proProvider.isPro ? Icons.verified : Icons.diamond, size: 40, color: Colors.black),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proProvider.isPro ? "PRO ÜYESİNİZ" : "PRO SÜRÜME GEÇ",
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        proProvider.isPro ? "Reklamlar Kapalı 🚀" : "Reklamları Kaldır & Destekle",
                        style: const TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (!proProvider.isPro)
                    ElevatedButton(
                      onPressed: () => proProvider.activatePro(), // Satın Al (Simülasyon)
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                      child: const Text("AL"),
                    )
                  else
                    // Test Amaçlı: İptal Et Butonu (Normalde kullanıcıda olmaz)
                    IconButton(
                       icon: const Icon(Icons.restore, color: Colors.black54),
                       onPressed: () => proProvider.deactivatePro(),
                    )
                ],
              ),
            ),
            // -----------------------

            // DİL SEÇİM KUTUSU
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF353A40),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language, color: Colors.amber),
                      const SizedBox(width: 10),
                      Text(
                        text.language,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 30),

                  // Dil Listesi
                  _buildLanguageOption(context, provider, 'Türkçe', const Locale('tr'), '🇹🇷'),
                  _buildLanguageOption(context, provider, 'English', const Locale('en'), '🇺🇸'),
                  _buildLanguageOption(context, provider, 'Español', const Locale('es'), '🇪🇸'),
                  _buildLanguageOption(context, provider, '中文 (Chinese)', const Locale('zh'), '🇨🇳'),
                  _buildLanguageOption(context, provider, 'हिन्दी (Hindi)', const Locale('hi'), '🇮🇳'),
                  _buildLanguageOption(context, provider, 'العربية (Arabic)', const Locale('ar'), '🇸🇦'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    LocaleProvider provider,
    String name,
    Locale locale,
    String flag,
  ) {
    final isSelected = provider.locale == locale;
    return GestureDetector(
      onTap: () => provider.setLocale(locale),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.amber.withValues(alpha: 0.5)) : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 15),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.amber : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.amber, size: 18),
          ],
        ),
      ),
    );
  }
}
