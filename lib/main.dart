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
        theme: ThemeData(colorSchemeSeed: Colors.red, useMaterial3: true),
        home: const ProductListScreen(),
      ),
    );
  }
}
