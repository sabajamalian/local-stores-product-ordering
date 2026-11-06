import 'package:flutter/foundation.dart';

import '../models/product.dart';

class Cart extends ChangeNotifier {
  final Map<String, int> _quantities = {};
  final Map<String, Product> _products = {};

  List<Product> get products => _products.values.toList(growable: false);

  int quantityOf(Product product) => _quantities[product.id] ?? 0;

  int get itemCount => _quantities.values.fold(0, (sum, q) => sum + q);

  int get totalCents => _products.values
      .fold(0, (sum, p) => sum + p.priceCents * quantityOf(p));

  bool get isEmpty => _quantities.isEmpty;

  void add(Product product) {
    _products[product.id] = product;
    _quantities.update(product.id, (q) => q + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void decrement(Product product) {
    final current = quantityOf(product);
    if (current <= 1) {
      remove(product);
      return;
    }
    _quantities[product.id] = current - 1;
    notifyListeners();
  }

  void remove(Product product) {
    _quantities.remove(product.id);
    _products.remove(product.id);
    notifyListeners();
  }

  void clear() {
    _quantities.clear();
    _products.clear();
    notifyListeners();
  }
}
