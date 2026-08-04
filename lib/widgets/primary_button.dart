import 'package:flutter/material.dart';
import '../main.dart';

class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final double height;
  final Color? color;

  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon, this.loading = false, this.height = 52, this.color});

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool hovering = false;
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final base = widget.color ?? kTeal2;
    final disabled = widget.onPressed == null || widget.loading;
    final displayColor = disabled ? base.withValues(alpha: 0.5) : (hovering ? Color.lerp(base, Colors.white, 0.12)! : base);

    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => pressed = true),
        onTapCancel: () => setState(() => pressed = false),
        onTapUp: (_) => setState(() => pressed = false),
        onTap: disabled ? null : widget.onPressed,
        child: AnimatedScale(
          scale: pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              color: displayColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: disabled
                  ? []
                  : [BoxShadow(color: base.withValues(alpha: hovering ? 0.42 : 0.28), blurRadius: hovering ? 18 : 12, offset: const Offset(0, 5))],
            ),
            alignment: Alignment.center,
            child: widget.loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[Icon(widget.icon, color: Colors.white, size: 18), const SizedBox(width: 8)],
                      Text(widget.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
