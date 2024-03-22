import 'dart:ui';

extension DrawRotated on Canvas {
  void drawRotated(
    Offset center,
    double angle,
    VoidCallback drawFunction,
  ) {
    save();
    translate(center.dx, center.dy);
    rotate(angle);
    translate(-center.dx, -center.dy);
    drawFunction();
    restore();
  }
}
