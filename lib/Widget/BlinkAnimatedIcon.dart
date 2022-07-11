import 'package:flutter/material.dart';

class BlinkAnimatedIcon extends StatefulWidget {
  const BlinkAnimatedIcon({
    Key? key,
    required this.icon,
    required this.startColor,
    required this.endColor,
    this.size,
  }) : super(key: key);

  final IconData icon;
  final Color startColor;
  final Color endColor;
  final double? size;

  @override
  _BlinkAnimatedIconState createState() => _BlinkAnimatedIconState();
}

class _BlinkAnimatedIconState extends State<BlinkAnimatedIcon> {
  late Color _firstColor;
  late Color _secondColor;

  @override
  void initState() {
    _firstColor = widget.startColor;
    _secondColor = widget.endColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 800),
      tween: ColorTween(begin: _firstColor, end: _secondColor),
      onEnd: () {
        setState(() {
          Color temp = _firstColor;
          _firstColor = _secondColor;
          _secondColor = temp;
        });
      },
      builder: (context, value, child) {
        return Icon(
          widget.icon,
          color: value as Color,
          size: widget.size ?? 24.0,
        );
      },
    );
  }
}
