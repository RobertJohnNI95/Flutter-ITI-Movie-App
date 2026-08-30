import "package:flutter/material.dart";

class WideButton extends StatelessWidget {
  const WideButton({
    super.key,
    required this.onPressed,
    required this.buttonLabel,
    this.icon,
    this.bgColor,
    this.textColor,
    this.style,
  });
  final VoidCallback onPressed;
  final String buttonLabel;
  final IconData? icon;
  final Color? bgColor;
  final Color? textColor;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        backgroundColor: (bgColor == null) ? null : bgColor!,
      ),
      onPressed: onPressed,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (icon == null) ? Text("") : Icon(icon, color: textColor),
          SizedBox(width: 5),
          Text(
            buttonLabel,
            style: TextStyle(color: textColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
