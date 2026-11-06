import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_stores/main.dart';

void main() {
  testWidgets('adding a product updates the cart badge and cart screen', (tester) async {
    await tester.pumpWidget(const LocalStoresApp());

    expect(find.text('Cola 600 ml'), findsOneWidget);
    expect(find.byKey(const Key('cart-count')), findsNothing);

    await tester.tap(find.byKey(const Key('add-cola-600')));
    await tester.tap(find.byKey(const Key('add-cola-600')));
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const Key('cart-count'))).data,
      '2',
    );

    await tester.tap(find.byKey(const Key('open-cart')));
    await tester.pumpAndSettle();
    expect(find.text(r'Total: $576.00'), findsOneWidget);

    await tester.tap(find.byKey(const Key('decrement-cola-600')));
    await tester.pump();
    expect(find.text(r'Total: $288.00'), findsOneWidget);
  });
}
