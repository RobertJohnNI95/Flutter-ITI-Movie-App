import "package:flutter/material.dart";

// NOTE: Theme changes take effect after closing and reopening the app
class UITheme {
  static final UITheme instance = UITheme();
  static final Color _bgColor = Colors.teal;

  Color get bgColor => _bgColor;
}
