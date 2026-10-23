import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/audio_service.dart';

/// A 3D cartoon arcade button with depth shadow, press animation, and click sound.
class CartoonButton extends StatefulWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color primaryColor;
  final Color shadowColor;
  final Color textColor;
  final double minWidth;
  final double height;
  final double fontSize;

  const CartoonButton({
    super.key,
    this.text,
    this.icon,
    required this.onPressed,
    this.primaryColor = const Color(0xFF4CAF50),
    this.shadowColor = const Color(0xFF2E7D32),
    this.textColor = Colors.white,
    this.minWidth = 140,
    this.height = 54,
    this.fontSize = 20,
  });

  @override
  State<CartoonButton> createState() => _CartoonButtonState();
}

class _CartoonButtonState extends State<CartoonButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double bevel = 6.0;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        AudioService.instance.playClick();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        margin: EdgeInsets.only(top: _isPressed ? bevel : 0),
        constraints: BoxConstraints(
          minWidth: widget.minWidth,
          minHeight: widget.height,
        ),
        decoration: BoxDecoration(
          color: widget.primaryColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF0F172A), width: 2.8),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.shadowColor,
                    offset: const Offset(0, bevel),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: const Color(0xFF0F172A),
                    offset: const Offset(0, bevel + 2.5),
                    blurRadius: 0,
                  ),
                ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                color: widget.textColor,
                size: widget.fontSize * 1.15,
                shadows: const [
                  Shadow(
                    offset: Offset(1, 1),
                    color: Colors.black45,
                    blurRadius: 2,
                  ),
                ],
              ),
              if (widget.text != null) const SizedBox(width: 8),
            ],
            if (widget.text != null)
              Text(
                widget.text!,
                style: GoogleFonts.poppins(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: widget.textColor,
                  shadows: const [
                    Shadow(
                      offset: Offset(1.5, 1.5),
                      color: Colors.black45,
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
