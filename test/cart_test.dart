import 'package:flutter_test/flutter_test.dart';
import 'package:local_stores/models/product.dart';
import 'package:local_stores/state/cart.dart';

void main() {
  const a = Product(id: 'a', name: 'A', unit: 'each', priceCents: 250);
  const b = Product(id: 'b', name: 'B', unit: 'each', priceCents: 1000);
  const minimum = Product(
    id: 'minimum',
    name: 'Minimum',
    unit: 'case of 12',
    priceCents: 1000,
    minimumOrderQuantity: 3,
  );

  test('products default to a minimum order quantity of one', () {
    expect(a.minimumOrderQuantity, 1);
  });

  test('sample catalog has the requested minimum order quantities', () {
    expect(
      {
        for (final product in sampleCatalog)
          product.id: product.minimumOrderQuantity,
      },
      {
        'cola-600': 2,
        'water-1l': 3,
        'juice-1l': 1,
        'chips-45': 2,
        'cookies-90': 1,
      },
    );
  });

  test('rejects nonpositive product minimums without mutating the cart', () {
    final cart = Cart()..add(a, quantity: 2);
    var notifications = 0;
    cart.addListener(() => notifications++);
    for (final value in [0, -2]) {
      final invalid = Product(
        id: a.id,
        name: a.name,
        unit: a.unit,
        priceCents: a.priceCents,
        minimumOrderQuantity: value,
      );
      expect(() => cart.add(invalid), throwsArgumentError);
      expect(() => cart.decrement(invalid), throwsArgumentError);
      expect(() => cart.remove(invalid), throwsArgumentError);
      expect(cart.products, [a]);
      expect(cart.quantityOf(a), 2);
      expect(cart.itemCount, 2);
      expect(cart.totalCents, 500);
      expect(cart.meetsMinimumOrderQuantities, isTrue);
      expect(notifications, 0);
    }
  });

  test('first add raises a below-minimum request to the minimum', () {
    for (final requested in [1, 2, 3, 5]) {
      final cart = Cart()..add(minimum, quantity: requested);
      final expected = requested < 3 ? 3 : requested;
      expect(cart.quantityOf(minimum), expected);
      expect(cart.itemCount, expected);
      expect(cart.totalCents, expected * 1000);
    }
  });

  test('add merges quantities for an existing line', () {
    final cart = Cart()
      ..add(minimum)
      ..add(minimum)
      ..add(minimum, quantity: 2);
    expect(cart.quantityOf(minimum), 6);
    expect(cart.products, [minimum]);
    expect(cart.totalCents, 6000);
  });

  test('decrement removes a line at its minimum', () {
    final cart = Cart()..add(minimum);
    cart.decrement(minimum);
    expect(cart.isEmpty, isTrue);
    expect(cart.products, isEmpty);
    expect(cart.quantityOf(minimum), 0);
    expect(cart.totalCents, 0);
  });

  test('decrement preserves quantities above the minimum', () {
    final cart = Cart()..add(minimum, quantity: 5);
    cart.decrement(minimum);
    expect(cart.quantityOf(minimum), 4);
    cart.decrement(minimum);
    expect(cart.quantityOf(minimum), 3);
    expect(cart.totalCents, 3000);
  });

  test('same-ID arguments preserve the stored product and its minimum', () {
    for (final value in [1, 10]) {
      final alias = Product(
        id: minimum.id,
        name: 'Alias',
        unit: 'box of 24',
        priceCents: 1,
        minimumOrderQuantity: value,
      );
      final cart = Cart()..add(minimum);
      cart.add(alias);
      expect(cart.products, [minimum]);
      expect(cart.quantityOf(minimum), 4);
      expect(cart.totalCents, 4000);
      cart.decrement(alias);
      expect(cart.quantityOf(minimum), 3);
      cart.decrement(alias);
      expect(cart.isEmpty, isTrue);
    }
  });

  test('cart minimum validation reflects line quantities', () {
    final cart = Cart();
    expect(cart.meetsMinimumOrderQuantities, isTrue);
    cart.add(a);
    cart.add(minimum);
    expect(cart.meetsMinimumOrderQuantities, isTrue);
    cart.add(minimum);
    cart.decrement(minimum);
    expect(cart.meetsMinimumOrderQuantities, isTrue);
    cart.remove(minimum);
    cart.clear();
    expect(cart.meetsMinimumOrderQuantities, isTrue);
    expect(_CartSnapshot(minimum, 2).meetsMinimumOrderQuantities, isFalse);
    expect(_CartSnapshot(minimum, 3).meetsMinimumOrderQuantities, isTrue);
    expect(_CartSnapshot(minimum, 4).meetsMinimumOrderQuantities, isTrue);
    expect(_CartSnapshot(a, 0).meetsMinimumOrderQuantities, isFalse);
  });

  test('notifies once per change and not for absent lines or empty clear', () {
    final cart = Cart();
    var notifications = 0;
    cart.addListener(() => notifications++);
    cart.decrement(minimum);
    cart.remove(minimum);
    cart.clear();
    expect(notifications, 0);
    cart.add(minimum);
    expect(notifications, 1);
    cart.add(minimum);
    expect(notifications, 2);
    cart.decrement(minimum);
    expect(notifications, 3);
    cart.decrement(minimum);
    expect(notifications, 4);
    cart.add(a);
    cart.remove(a);
    expect(notifications, 6);
    cart.add(a);
    cart.clear();
    expect(notifications, 8);
  });

  test('totals quantities and prices across products', () {
    final cart = Cart()
      ..add(a)
      ..add(a)
      ..add(b);
    expect(cart.itemCount, 3);
    expect(cart.totalCents, 1500);
  });

  test('decrement removes the line when quantity reaches zero', () {
    final cart = Cart()
      ..add(a)
      ..add(a);
    cart.decrement(a);
    expect(cart.quantityOf(a), 1);
    cart.decrement(a);
    expect(cart.isEmpty, isTrue);
    expect(cart.products, isEmpty);
  });

  test('bulk additions merge quantities and preserve line totals', () {
    final cart = Cart()
      ..add(a, quantity: 5)
      ..add(a, quantity: 3)
      ..add(b, quantity: 2);
    expect(cart.quantityOf(a), 8);
    expect(cart.products.length, 2);
    expect(cart.itemCount, 10);
    expect(cart.totalCents, 4000);
    cart.decrement(a);
    expect(cart.totalCents, 3750);
    cart.remove(b);
    expect(cart.itemCount, 7);
    cart.clear();
    expect(cart.totalCents, 0);
    expect(cart.products, isEmpty);
  });

  test('rejects nonpositive bulk quantities without changing the cart', () {
    final cart = Cart()..add(a, quantity: 2);
    expect(() => cart.add(a, quantity: 0), throwsArgumentError);
    expect(() => cart.add(b, quantity: -1), throwsArgumentError);
    expect(cart.quantityOf(a), 2);
    expect(cart.quantityOf(b), 0);
    expect(cart.totalCents, 500);
  });

  test('formatCents pads cents', () {
    expect(formatCents(9605), r'$96.05');
    expect(formatCents(0), r'$0.00');
  });
}

// Read-only snapshot for defensive validation coverage, without mutation hooks.
class _CartSnapshot extends Cart {
  _CartSnapshot(this.product, this.quantity);

  final Product product;
  final int quantity;

  @override
  List<Product> get products => [product];

  @override
  int quantityOf(Product product) => quantity;
}
