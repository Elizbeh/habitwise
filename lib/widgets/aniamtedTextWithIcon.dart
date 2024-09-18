import 'package:flutter/material.dart';

class CustomAnimatedSubtitle extends StatefulWidget {
  final Duration animationDuration;
  final String text;
  final IconData icon;
  final Color iconColor;
  final TextStyle textStyle;
  final double iconSize;

  CustomAnimatedSubtitle({
    required this.animationDuration,
    required this.text,
    required this.icon,
    required this.iconColor,
    required this.textStyle,
    required this.iconSize,
  });

  @override
  _CustomAnimatedSubtitleState createState() => _CustomAnimatedSubtitleState();
}

class _CustomAnimatedSubtitleState extends State<CustomAnimatedSubtitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _textAnimation;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat(reverse: true);

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return RichText(
          text: TextSpan(
            style: widget.textStyle,
            children: [
              TextSpan(
                text: widget.text,
                style: widget.textStyle.copyWith(
                  color: Color.lerp(Colors.white, Colors.amber, _textAnimation.value),
                ),
              ),
              WidgetSpan(
                child: Transform.translate(
                  offset: Offset(0, -5 * _iconAnimation.value),
                  child: Icon(
                    widget.icon,
                    color: widget.iconColor,
                    size: widget.iconSize,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
