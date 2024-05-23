import 'dart:math';
import 'package:flutter/material.dart';

class DustParticles extends StatefulWidget {
  final Widget child;
  final bool showParticles;

  const DustParticles({
    required this.child,
    required this.showParticles,
    Key? key,
  }) : super(key: key);

  @override
  _DustParticlesState createState() => _DustParticlesState();
}

class _DustParticlesState extends State<DustParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showParticles)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: DustPainter(_animation.value),
                );
              },
            ),
          ),
      ],
    );
  }
}

class DustPainter extends CustomPainter {
  final double value;

  DustPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final particleRadius = 2.0;
    final particleCount = 5;
    final random = Random();

    for (var i = 0; i < particleCount; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final offset = Offset(dx, dy);
      canvas.drawCircle(offset, particleRadius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
