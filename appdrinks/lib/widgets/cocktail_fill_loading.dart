import 'package:flutter/material.dart';

class CocktailFillLoading extends StatefulWidget {
  final Color color;
  final double size;

  const CocktailFillLoading({
    super.key,
    this.color = Colors.redAccent,
    this.size = 40,
  });

  @override
  State<CocktailFillLoading> createState() => _CocktailFillLoadingState();
}

class _CocktailFillLoadingState extends State<CocktailFillLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _fillAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fillAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _CocktailGlassPainter(
            fillLevel: _fillAnimation.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _CocktailGlassPainter extends CustomPainter {
  final double fillLevel;
  final Color color;

  _CocktailGlassPainter({
    required this.fillLevel,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final glassPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path glassPath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.2)
      ..lineTo(size.width * 0.65, size.height * 0.9)
      ..lineTo(size.width * 0.35, size.height * 0.9)
      ..close();

    canvas.drawPath(glassPath, glassPaint);
    canvas.drawPath(glassPath, paint);

    if (fillLevel > 0) {
      final fillHeight = size.height * 0.7 * fillLevel;
      final fillPath = Path()
        ..moveTo(size.width * 0.35, size.height * 0.9)
        ..lineTo(size.width * 0.65, size.height * 0.9)
        ..lineTo(size.width * 0.72, size.height * 0.9 - fillHeight)
        ..lineTo(size.width * 0.28, size.height * 0.9 - fillHeight)
        ..close();

      canvas.drawPath(fillPath, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CocktailGlassPainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel;
  }
}
