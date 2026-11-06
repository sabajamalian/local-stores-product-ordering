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

    await tester.ensureVisible(find.byKey(const Key('add-cola-600')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-cola-600')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('add-water-1l')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-water-1l')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('add-water-1l')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-water-1l')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-cart')));
    await tester.pumpAndSettle();

    // 288.00 + 2 * 96.00
    await tester.ensureVisible(find.byKey(const Key('cart-total')));
    await tester.pumpAndSettle();
    expect(find.text(r'Total: $480.00'), findsOneWidget);
    await binding.takeScreenshot('cart');

    await tester.tap(find.byKey(const Key('place-order')));
    await tester.pumpAndSettle();
    expect(find.text('Order placed'), findsOneWidget);
    expect(find.text(r'3 items, total $480.00.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('order-confirm-ok')));
    await tester.pumpAndSettle();
    expect(find.text('Products'), findsOneWidget);
    expect(find.byKey(const Key('cart-count')), findsNothing);
  });
}
