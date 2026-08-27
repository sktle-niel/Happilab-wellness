import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Google's four-colour G, drawn as arcs.
///
/// This is a geometric approximation rather than the official artwork: it keeps
/// the app free of an SVG dependency and reads correctly at the ~19px the
/// design uses. Swap in the official asset before shipping a build that
/// actually offers Google sign-in.
class GoogleMark extends StatelessWidget {
  const GoogleMark({this.size = 19, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _GoogleMarkPainter()),
  );
}

class _GoogleMarkPainter extends CustomPainter {
  static const Color _yellow = Color(0xFFFFC107);
  static const Color _red = Color(0xFFFF3D00);
  static const Color _green = Color(0xFF4CAF50);
  static const Color _blue = Color(0xFF1976D2);

  // Angles run clockwise from 3 o'clock, matching Canvas.drawArc.
  static const List<(Color, double, double)> _segments = [
    (_green, 45, 90),
    (_yellow, 135, 60),
    (_red, 195, 105),
    (_blue, 300, 55),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.26;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (size.width - stroke) / 2,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    for (final (color, start, sweep) in _segments) {
      canvas.drawArc(
        rect,
        _radians(start),
        _radians(sweep),
        false,
        paint..color = color,
      );
    }

    // The bar that closes the G, level with the centre.
    canvas.drawRect(
      Rect.fromLTRB(
        size.width * 0.48,
        (size.height - stroke) / 2,
        size.width * 0.95,
        (size.height + stroke) / 2,
      ),
      Paint()..color = _blue,
    );
  }

  static double _radians(double degrees) => degrees * math.pi / 180;

  @override
  bool shouldRepaint(_GoogleMarkPainter oldDelegate) => false;
}
