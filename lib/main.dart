import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/product_list_screen.dart';
import 'state/cart.dart';

void main() {
  runApp(const LocalStoresApp());
}

class LocalStoresApp extends StatelessWidget {
  const LocalStoresApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Cart(),
      child: MaterialApp(
        title: 'Local Stores',
        debugShowCheckedModeBanner: false,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        home: const ProductListScreen(),
      ),
    );
  }
}

ThemeData _theme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF424242),
    brightness: brightness,
    primary: dark ? const Color(0xFFE6E6E6) : const Color(0xFF262626),
    onPrimary: dark ? const Color(0xFF171717) : const Color(0xFFFFFFFF),
    surface: dark ? const Color(0xFF171717) : const Color(0xFFFFFFFF),
    onSurface: dark ? const Color(0xFFE6E6E6) : const Color(0xFF262626),
    onSurfaceVariant: dark ? const Color(0xFFB6B6B6) : const Color(0xFF606060),
    outlineVariant: dark ? const Color(0xFF393939) : const Color(0xFFE3E3E3),
    surfaceContainer: dark ? const Color(0xFF202020) : const Color(0xFFF5F5F5),
    surfaceContainerLow: dark
        ? const Color(0xFF202020)
        : const Color(0xFFF8F8F8),
    surfaceContainerHighest: dark
        ? const Color(0xFF303030)
        : const Color(0xFFEEEEEE),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      centerTitle: false,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      side: BorderSide(color: scheme.outlineVariant),
      selectedColor: scheme.surfaceContainerHighest,
      labelStyle: TextStyle(color: scheme.onSurface),
      showCheckmark: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    ),
  );
}
