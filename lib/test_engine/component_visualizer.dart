import 'package:flutter/material.dart';
import 'package_coordinates.dart';

// ARTIK STATEFUL WIDGET OLDU (Animasyon İçin)
class ComponentVisualizer extends StatefulWidget {
  final String packageType; 
  final int? redPinIndex;
  final int? blackPinIndex;
  final bool isFlipped;
  final List<String> pinLabels; 

  const ComponentVisualizer({
    super.key,
    required this.packageType,
    this.redPinIndex,
    this.blackPinIndex,
    required this.isFlipped,
    this.pinLabels = const [],
  });

  @override
  State<ComponentVisualizer> createState() => _ComponentVisualizerState();
}

class _ComponentVisualizerState extends State<ComponentVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // NEFES ALMA EFEKTİ (PULSE) 🫀
    // Saniyede 1 kez büyüyüp küçülür
    _pulseController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true); // Sonsuz döngü

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coords = PackageCoordinates.data[widget.packageType] ?? PackageCoordinates.data['TO-220']!;

    Offset getTarget(Offset raw) {
      if (widget.isFlipped) return Offset(1.0 - raw.dx, raw.dy);
      return raw;
    }

    String getLabel(int index) {
      if (index >= widget.pinLabels.length) return "${index + 1}";
      return widget.pinLabels[index];
    }

    return Center(
      child: SizedBox(
        width: 300,
        height: 400, 
        child: Stack(
          children: [
            // 1. KATMAN: KILIF RESMİ
            Align(
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (child, anim) => RotationYTransition(turns: anim, child: child),
                child: widget.isFlipped
                    ? Image.asset(
                        'assets/packages/${widget.packageType.toLowerCase()}_bottom.png',
                        key: const ValueKey('bottom'),
                        width: 220,
                        errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                      )
                    : Image.asset(
                        'assets/packages/${widget.packageType.toLowerCase()}.png',
                        key: const ValueKey('top'),
                        width: 220,
                        errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                      ),
              ),
            ),

            // 2. KATMAN: NEFES ALAN AKILLI PINLER
            ...List.generate(coords.length, (index) {
              final target = getTarget(coords[index]);
              
              bool isRed = (widget.redPinIndex == index);
              bool isBlack = (widget.blackPinIndex == index);
              bool isActive = isRed || isBlack;

              Color bgColor = Colors.amber.withValues(alpha: 0.2); 
              Color borderColor = Colors.amber.withValues(alpha: 0.5);
              Color textColor = Colors.amber;
              
              // Gölge ve Renk Ayarları
              List<BoxShadow> shadows = [];

              if (isRed) {
                bgColor = Colors.redAccent;
                borderColor = Colors.red;
                textColor = Colors.white;
                shadows = [BoxShadow(color: Colors.redAccent.withValues(alpha: 0.8), blurRadius: 15, spreadRadius: 2)];
              } else if (isBlack) {
                bgColor = const Color(0xFF222222);
                borderColor = Colors.white; 
                textColor = Colors.white;
                shadows = [BoxShadow(color: Colors.white.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 1)];
              }

              // --- KONUM AYARLARI (SENİN AYARLARIN) ---
              double labelX = target.dx;
              double labelY = 0.92; 

              if (widget.packageType == 'TO-3' && index == 2) labelY = 0.20; 

              // 1. STANDART DİYOTLAR (DO-41)
              if (widget.packageType == 'DO-41') {
                 if (index == 0) {
                   labelY = 0.65;
                 } else if (index == 1) { 
                    labelX += 0.05; 
                    labelY = 0.65; 
                 }
              }

              // 2. ZENER DİYOTLAR (DO-35)
              if (widget.packageType == 'DO-35') {
                 if (index == 0) {
                   labelY = 0.75; // Senin ayarın
                 } else if (index == 1) { 
                    labelX += 0.00; 
                    labelY = 0.40; // Senin ayarın
                 }
              }

              // 3 Bacaklı Simetrik Hizalama (TO-3 Hariç)
              if (!widget.isFlipped && coords.length == 3 && widget.packageType != 'TO-3') {
                 if (index == 0) labelX = 0.35; 
                 if (index == 1) labelX = 0.50; 
                 if (index == 2) labelX = 0.65; 
              }

              // --- WIDGET OLUŞTURMA ---
              // Eğer aktifse ScaleTransition (Animasyon) kullan, değilse sabit dur.
              Widget pinWidget = Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6), 
                  border: Border.all(color: borderColor, width: isActive ? 2 : 1),
                  boxShadow: shadows,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      getLabel(index),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    if (isActive)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 5, height: 5, 
                        decoration: BoxDecoration(shape: BoxShape.circle, color: isRed ? Colors.white : Colors.grey),
                      )
                  ],
                ),
              );

              return Align(
                alignment: Alignment((labelX * 2) - 1, (labelY * 2) - 1),
                child: isActive 
                  ? ScaleTransition(scale: _pulseAnimation, child: pinWidget) // Animasyonlu
                  : pinWidget, // Sabit
              );
            }),
          ],
        ),
      ),
    );
  }
}

class RotationYTransition extends AnimatedWidget {
  const RotationYTransition({super.key, required Animation<double> turns, required this.child}) : super(listenable: turns);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final turns = listenable as Animation<double>;
    final Matrix4 transform = Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(turns.value * 3.14159);
    return Transform(transform: transform, alignment: Alignment.center, child: child);
  }
}
