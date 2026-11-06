import 'package:flutter/foundation.dart';

import '../models/product.dart';

class Cart extends ChangeNotifier {
  final Map<String, int> _quantities = {};
  final Map<String, Product> _products = {};

  List<Product> get products => _products.values.toList(growable: false);

  int quantityOf(Product product) => _quantities[product.id] ?? 0;

  int get itemCount => _quantities.values.fold(0, (sum, q) => sum + q);

  int get totalCents =>
      _products.values.fold(0, (sum, p) => sum + p.priceCents * quantityOf(p));

  bool get isEmpty => _quantities.isEmpty;

  bool get meetsMinimumOrderQuantities => products.every(
    (product) =>
        product.minimumOrderQuantity > 0 &&
        quantityOf(product) >= product.minimumOrderQuantity,
  );

  void _validateMinimum(Product product) {
    if (product.minimumOrderQuantity <= 0) {
      throw ArgumentError.value(
        product.minimumOrderQuantity,
        'minimumOrderQuantity',
        'Must be positive',
      );
    }
  }

  void add(Product product, {int quantity = 1}) {
    _validateMinimum(product);
    if (quantity <= 0) {
      throw ArgumentError.value(quantity, 'quantity', 'Must be positive');
    }
    // Keep the product (and its MOQ) that established the line.
    _products.putIfAbsent(product.id, () => product);
    _quantities.update(
      product.id,
      (q) => q + quantity,
      ifAbsent: () => quantity < product.minimumOrderQuantity
          ? product.minimumOrderQuantity
          : quantity,
    );
    notifyListeners();
  }

  void decrement(Product product) {
    _validateMinimum(product);
    final storedProduct = _products[product.id];
    if (storedProduct == null) return;
    final current = quantityOf(product);
    if (current - 1 < storedProduct.minimumOrderQuantity) {
      remove(product);
      return;
    }
    _quantities[product.id] = current - 1;
    notifyListeners();
  }

  void remove(Product product) {
    _validateMinimum(product);
    if (!_quantities.containsKey(product.id)) return;
    _quantities.remove(product.id);
    _products.remove(product.id);
    notifyListeners();
  }

  void clear() {
    if (isEmpty) return;
    _quantities.clear();
    _products.clear();
    notifyListeners();
  }
}
