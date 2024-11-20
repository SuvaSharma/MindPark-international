import 'package:flutter/material.dart';

class FlipCard extends StatefulWidget {
  final Widget front;
  final String backText; // Text to display on the back side
  final bool isFlipping;
  final Duration duration;

  const FlipCard({
    Key? key,
    required this.front,
    required this.backText,
    this.isFlipping = false,
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  _FlipCardState createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isFlipping) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipping != oldWidget.isFlipping) {
      if (widget.isFlipping) {
        _controller.forward().then((_) {
          _controller.reverse();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        final rotateY = value * 3.14159; // Flip 180 degrees in radians

        return Center(
          child: Transform(
            transform: Matrix4.rotationY(rotateY)
              ..setEntry(3, 2, 0.002), // Add perspective
            alignment: Alignment.center,
            child: value < 0.5
                ? widget.front
                : Transform(
                    transform: Matrix4.rotationY(rotateY - 3.14159)
                      ..setEntry(3, 2, 0.002), // Add perspective
                    alignment: Alignment.center,
                    child: Container(
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          widget.backText,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
