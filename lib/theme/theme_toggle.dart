import 'package:flutter/material.dart';

class ThemeToggleScope extends InheritedWidget {
  final VoidCallback toggle;
  const ThemeToggleScope({
    super.key,
    required this.toggle,
    required super.child,
  });

  static ThemeToggleScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeToggleScope>()!;
  }

  @override
  bool updateShouldNotify(ThemeToggleScope oldWidget) => false;
}
