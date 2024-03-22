import 'dart:ui';

extension DrawRotated on Canvas {
  void drawRotated(
    final Offset center,
    final double angle,
    final VoidCallback drawFunction,
  ) {
    save();
    translate(center.dx, center.dy);
    rotate(angle);
    translate(-center.dx, -center.dy);
    drawFunction();
    restore();
  }
}
