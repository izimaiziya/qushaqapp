import 'package:flutter/material.dart';

class QushaqLogo extends StatelessWidget {
  final double size;
  final bool white;

  const QushaqLogo({super.key, this.size = 34, this.white = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.16),
      decoration: BoxDecoration(
        color: white ? Colors.white : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
    );
  }
}
