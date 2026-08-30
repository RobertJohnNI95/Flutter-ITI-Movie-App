import "package:flutter/material.dart";

class WideButton extends StatelessWidget {
  const WideButton({
    super.key,
    required this.onPressed,
    required this.buttonLabel,
    this.icon,
    this.bgColor,
    this.textColor,
  });
  final VoidCallback onPressed;
  final String buttonLabel;
  final IconData? icon;
  final Color? bgColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: (bgColor == null)
            ? null
            : WidgetStatePropertyAll<Color>(bgColor!),
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
