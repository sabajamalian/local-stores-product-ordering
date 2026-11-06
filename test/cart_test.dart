import 'package:flutter_test/flutter_test.dart';
import 'package:local_stores/models/product.dart';
import 'package:local_stores/state/cart.dart';

void main() {
  const a = Product(id: 'a', name: 'A', unit: 'each', priceCents: 250);
  const b = Product(id: 'b', name: 'B', unit: 'each', priceCents: 1000);

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
