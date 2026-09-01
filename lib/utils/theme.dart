import "package:flutter/material.dart";

// NOTE: Theme changes take effect after closing and reopening the app
class UITheme {
  static final UITheme instance = UITheme();
  static final Color bgColor = Colors.lightBlue;
  static final AssetImage _bgImageAsset = AssetImage('assets/bg1.jpg');
  static final DecorationImage bgImage = DecorationImage(
    image: _bgImageAsset,
    fit: BoxFit.cover,
  );
}
