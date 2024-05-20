import 'package:flutter/material.dart';

class CustomTextButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final TextStyle textStyle;
  final double padding;

  const CustomTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.textStyle,
    this.padding = 8.0,
  });

  @override
  _CustomTextButtonState createState() => _CustomTextButtonState();
}

class _CustomTextButtonState extends State<CustomTextButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widget.padding),
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
          });
        },
        child: TextButton(
          onPressed: widget.onPressed,
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith<Color>(
              (states) {
                return Colors.grey; // Couleur de texte sombre prédéfinie
              },
            ),
            textStyle: WidgetStateProperty.resolveWith<TextStyle>(
              (states) {
                return widget.textStyle.copyWith(
                  decoration: _isHovered
                      ? TextDecoration.underline
                      : TextDecoration.none,
                );
              },
            ),
            overlayColor: WidgetStateProperty.resolveWith<Color>(
              (states) {
                return Colors.transparent; // Transparent background on overlay
              },
            ),
          ),
          child: Text(widget.text),
        ),
      ),
    );
  }
}
