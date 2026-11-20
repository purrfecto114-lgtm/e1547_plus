import 'package:e1547/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    test('bottom sheets follow the $name theme like every other surface', () {
      final theme = M2ThemeData.from(
        colorScheme: ColorScheme.fromSwatch(brightness: brightness),
      );

      expect(theme.useMaterial3, isTrue);
      expect(theme.bottomSheetTheme.backgroundColor, theme.canvasColor);
      expect(theme.bottomSheetTheme.modalBackgroundColor, theme.canvasColor);
      expect(theme.bottomSheetTheme.surfaceTintColor, Colors.transparent);
      final shape = theme.bottomSheetTheme.shape! as RoundedRectangleBorder;
      expect(
        shape.borderRadius,
        const BorderRadius.vertical(top: Radius.circular(4)),
      );
    });
  }
}
