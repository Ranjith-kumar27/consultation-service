import 'package:flutter/material.dart';

class WaveDotLoader extends StatefulWidget {
  final double size;
  final Color color;

  const WaveDotLoader({super.key, this.size = 30.0, this.color = Colors.white});

  @override
  State<WaveDotLoader> createState() => _WaveDotLoaderState();
}

class _WaveDotLoaderState extends State<WaveDotLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.2;
              final relativeValue = (_controller.value - delay) % 1.0;
              final bounce = (relativeValue < 0.5)
                  ? relativeValue * 2
                  : (1.0 - relativeValue) * 2;

              return Transform.translate(
                offset: Offset(0, -bounce * (widget.size / 2)),
                child: Container(
                  width: widget.size / 4,
                  height: widget.size / 4,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.6 + (bounce * 0.4)),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
