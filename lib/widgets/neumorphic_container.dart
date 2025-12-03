import 'package:flutter/material.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color color;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(12.0),
    this.color = const Color(0xFFE6E9EF), // Açık Gri (Light Neumorphism)
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Sağ alt köşe (Karanlık Gölge)
          BoxShadow(
            color: const Color(0xFFB8C0CC),
            offset: const Offset(6, 6),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          // Sol üst köşe (Aydınlık Gölge - Işık Vuruyor)
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-6, -6),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}
