import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_stores/main.dart';
import 'package:local_stores/models/product.dart';

void main() {
  Future<void> reveal(WidgetTester tester, Key key) async {
    await tester.ensureVisible(find.byKey(key));
    await tester.pumpAndSettle();
  }

  testWidgets('adding a product updates the cart badge and cart screen', (
    tester,
  ) async {
    await tester.pumpWidget(const LocalStoresApp());

    expect(find.text('Cola 600 ml'), findsOneWidget);
    expect(find.byKey(const Key('cart-count')), findsNothing);

    await reveal(tester, const Key('add-cola-600'));
    await tester.tap(find.byKey(const Key('add-cola-600')));
    await tester.pumpAndSettle();
    await reveal(tester, const Key('add-cola-600'));
    await tester.tap(find.byKey(const Key('add-cola-600')));
    await tester.pump();
    expect(tester.widget<Text>(find.byKey(const Key('cart-count'))).data, '2');

    await tester.tap(find.byKey(const Key('open-cart')));
    await tester.pumpAndSettle();
    expect(find.text(r'Total: $576.00'), findsOneWidget);

    await tester.tap(find.byKey(const Key('decrement-cola-600')));
    await tester.pump();
    expect(find.text(r'Total: $288.00'), findsOneWidget);
  });

  testWidgets('selecting multiple cases adds the chosen quantity at once', (
    tester,
  ) async {
    await tester.pumpWidget(const LocalStoresApp());
    await reveal(tester, const Key('select-increment-cola-600'));
    await tester.tap(find.byKey(const Key('select-increment-cola-600')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('select-increment-cola-600')));
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const Key('select-qty-cola-600'))).data,
      '3',
    );
    await tester.tap(find.byKey(const Key('add-cola-600')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-cart')));
    await tester.pumpAndSettle();
    expect(find.text(r'Total: $864.00'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('qty-cola-600'))).data,
      '3',
    );
    await tester.tap(find.byKey(const Key('remove-cola-600')));
    await tester.pumpAndSettle();
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.byKey(const Key('place-order')), findsNothing);
  });

  testWidgets('details show the full description and allow bulk adding', (
    tester,
  ) async {
    await tester.pumpWidget(const LocalStoresApp());
    await reveal(tester, const Key('details-cola-600'));
    await tester.tap(find.byKey(const Key('details-cola-600')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text(sampleCatalog.first.description),
      ),
      findsOneWidget,
    );
    await reveal(tester, const Key('detail-increment-cola-600'));
    await tester.tap(find.byKey(const Key('detail-increment-cola-600')));
    await tester.pump();
    await reveal(tester, const Key('detail-add-cola-600'));
    await tester.tap(find.byKey(const Key('detail-add-cola-600')));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(tester.widget<Text>(find.byKey(const Key('cart-count'))).data, '2');
  });

  testWidgets('search and category filters combine and show an empty state', (
    tester,
  ) async {
    await tester.pumpWidget(const LocalStoresApp());
    await reveal(tester, const Key('product-search'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Snacks'));
    await tester.pumpAndSettle();
    expect(find.text('Cola 600 ml'), findsNothing);
    expect(find.text('Potato Chips 45 g'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('product-search')),
      'chocolate',
    );
    await tester.pumpAndSettle();
    expect(find.text('Potato Chips 45 g'), findsNothing);
    expect(find.text('Chocolate Cookies 90 g'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('product-search')),
      'nonexistent',
    );
    await tester.pumpAndSettle();
    expect(find.text('No products found'), findsOneWidget);
  });

  testWidgets('checkout confirms the demo order and clears quantities', (
    tester,
  ) async {
    await tester.pumpWidget(const LocalStoresApp());
    await reveal(tester, const Key('add-cola-600'));
    await tester.tap(find.byKey(const Key('add-cola-600')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-cart')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('place-order')));
    await tester.pumpAndSettle();
    expect(find.text('Order placed'), findsOneWidget);
    expect(find.text(r'1 item, total $288.00.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('order-confirm-ok')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cart-count')), findsNothing);
  });

  for (final width in [320.0, 1200.0]) {
    testWidgets('catalog and cart fit width $width with large text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(const LocalStoresApp());
      await reveal(tester, const Key('add-cola-600'));
      await tester.tap(find.byKey(const Key('add-cola-600')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('open-cart')));
      await tester.pumpAndSettle();
      await reveal(tester, const Key('cart-total'));
      expect(tester.takeException(), isNull);
      expect(find.text(r'Total: $288.00'), findsOneWidget);
    });
  }
}
