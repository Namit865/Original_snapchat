import 'package:flutter/material.dart';

class SpoilerText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const SpoilerText({required this.text, this.style, Key? key}) : super(key: key);

  @override
  _SpoilerTextState createState() => _SpoilerTextState();
}

class _SpoilerTextState extends State<SpoilerText> {
  bool _isRevealed = false;

  void _toggleSpoiler() {
    setState(() {
      _isRevealed = !_isRevealed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleSpoiler,
      child: Container(
        color: _isRevealed ? Colors.transparent : Colors.grey,
        child: Text(
          _isRevealed ? widget.text : 'Spoiler',
          style: widget.style,
        ),
      ),
    );
  }
}
