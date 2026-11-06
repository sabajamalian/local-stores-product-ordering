import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:local_stores/main.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('browse, add to cart, and place an order', (tester) async {
    await tester.pumpWidget(const LocalStoresApp());
    await tester.pumpAndSettle();
    if (!kIsWeb && Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
    }

    await binding.takeScreenshot('catalog');
    await tester.ensureVisible(find.byKey(const Key('details-cola-600')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('details-cola-600')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('detail-add-cola-600')), findsOneWidget);
    await binding.takeScreenshot('product-details');
    await tester.ensureVisible(
      find.byTooltip('Close product details for Cola 600 ml'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close product details for Cola 600 ml'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('add-cola-600')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-cola-600')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('add-water-1l')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-water-1l')));
    await tester.pumpAndSettle();

    expect(tester.widget<Text>(find.byKey(const Key('cart-count'))).data, '5');
    await tester.ensureVisible(find.byKey(const Key('open-cart')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-cart')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byKey(const Key('qty-cola-600'))).data,
      '2',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('qty-water-1l'))).data,
      '3',
    );
    expect(find.text('2 products / 5 cases and boxes'), findsOneWidget);
    // 2 * 288.00 + 3 * 96.00
    await tester.ensureVisible(find.byKey(const Key('cart-total')));
    await tester.pumpAndSettle();
    expect(find.text(r'Total: $864.00'), findsOneWidget);
    await binding.takeScreenshot('cart');

    await tester.ensureVisible(find.byKey(const Key('place-order')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('place-order')));
    await tester.pumpAndSettle();
    expect(find.text('Order placed'), findsOneWidget);
    expect(find.text(r'5 items, total $864.00.'), findsOneWidget);
    await binding.takeScreenshot('order-confirmation');

    await tester.ensureVisible(find.byKey(const Key('order-confirm-ok')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('order-confirm-ok')));
    await tester.pumpAndSettle();
    expect(find.text('Products'), findsOneWidget);
    expect(find.byKey(const Key('cart-count')), findsNothing);
  });
}
