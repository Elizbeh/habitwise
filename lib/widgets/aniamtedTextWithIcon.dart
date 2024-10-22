import 'package:flutter/material.dart';

class CustomAnimatedSubtitle extends StatefulWidget {
  final Duration animationDuration;
  final String text;
  final IconData icon;
  final Color? iconColor; // Made iconColor optional to adjust for theme
  final TextStyle? textStyle; // Made textStyle optional to adjust for theme
  final double iconSize;

  CustomAnimatedSubtitle({
    required this.animationDuration,
    required this.text,
    required this.icon,
    this.iconColor,
    this.textStyle,
    required this.iconSize, required MaterialColor lightbulbColor,
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
    // Use theme-based styles for text and icon colors
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textStyle = widget.textStyle ?? Theme.of(context).textTheme.displaySmall!;
    final iconColor = widget.iconColor ?? (isDarkMode ? Colors.white : Colors.black);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return RichText(
          text: TextSpan(
            style: textStyle,
            children: [
              TextSpan(
                text: widget.text,
                style: textStyle.copyWith(
                  // Animate text color from white to amber, adapting for dark mode
                  color: Color.lerp(
                    isDarkMode ? Colors.grey[300] : Colors.black, 
                    Colors.amber, 
                    _textAnimation.value,
                  ),
                ),
              ),
              WidgetSpan(
                child: Transform.translate(
                  offset: Offset(0, -5 * _iconAnimation.value),
                  child: Icon(
                    widget.icon,
                    color: iconColor, // Use theme-based icon color
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
