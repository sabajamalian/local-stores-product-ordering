import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_stores/main.dart';
import 'package:local_stores/models/product.dart';
import 'package:local_stores/screens/cart_screen.dart';
import 'package:local_stores/screens/product_list_screen.dart';
import 'package:local_stores/state/cart.dart';
import 'package:provider/provider.dart';

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
    expect(tester.widget<Text>(find.byKey(const Key('cart-count'))).data, '4');

    await tester.tap(find.byKey(const Key('open-cart')));
    await tester.pumpAndSettle();
    expect(find.text(r'Total: $1152.00'), findsOneWidget);

    await tester.tap(find.byKey(const Key('decrement-cola-600')));
    await tester.pump();
    expect(find.text(r'Total: $864.00'), findsOneWidget);
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
      '4',
    );
    await tester.tap(find.byKey(const Key('add-cola-600')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-cart')));
    await tester.pumpAndSettle();
    expect(find.text(r'Total: $1152.00'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('qty-cola-600'))).data,
      '4',
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
    expect(tester.widget<Text>(find.byKey(const Key('cart-count'))).data, '3');
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

  testWidgets('valid cart can be checked out and clears quantities', (
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
    expect(find.text(r'2 items, total $576.00.'), findsOneWidget);
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
      expect(find.text(r'Total: $576.00'), findsOneWidget);
    });
  }

  const cases = Product(
    id: 'cases',
    name: 'Test Cases',
    unit: 'case of 12',
    priceCents: 1000,
    minimumOrderQuantity: 3,
    imageAsset: 'assets/products/water.jpg',
  );
  const boxes = Product(
    id: 'boxes',
    name: 'Test Boxes',
    unit: 'box of 24',
    priceCents: 500,
    minimumOrderQuantity: 2,
    imageAsset: 'assets/products/chips.jpg',
  );
  const single = Product(
    id: 'single',
    name: 'Test Single',
    unit: 'case of 6',
    priceCents: 100,
    imageAsset: 'assets/products/juice.jpg',
  );

  Future<void> pumpCatalog(WidgetTester tester, List<Product> catalog) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => Cart(),
        child: MaterialApp(home: ProductListScreen(catalog: catalog)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'shows minimum order quantities on product cards and details only when above one',
    (tester) async {
      for (final product in [cases, boxes, single]) {
        await pumpCatalog(tester, [product]);
        final copy = product.unit.startsWith('box')
            ? 'Minimum order: 2 boxes'
            : 'Minimum order: 3 cases';
        expect(
          find.text(copy),
          product == single ? findsNothing : findsOneWidget,
        );
        expect(find.text('Minimum order: 1 cases'), findsNothing);
        await reveal(tester, Key('details-${product.id}'));
        await tester.tap(find.byKey(Key('details-${product.id}')));
        await tester.pumpAndSettle();
        final sheet = find.byType(BottomSheet);
        expect(
          find.descendant(of: sheet, matching: find.text(copy)),
          product == single ? findsNothing : findsOneWidget,
        );
        expect(
          find.descendant(
            of: sheet,
            matching: find.text('Minimum order: 1 cases'),
          ),
          findsNothing,
        );
        await tester.tap(
          find.byTooltip('Close product details for ${product.name}'),
        );
        await tester.pumpAndSettle();
      }
    },
  );

  testWidgets('card quantity starts at the minimum and cannot go below it', (
    tester,
  ) async {
    for (final product in [cases, boxes, single]) {
      await pumpCatalog(tester, [product]);
      final decrement = find.byKey(Key('select-decrement-${product.id}'));
      final quantity = find.byKey(Key('select-qty-${product.id}'));
      expect(
        tester.widget<Text>(quantity).data,
        '${product.minimumOrderQuantity}',
      );
      expect(tester.widget<IconButton>(decrement).onPressed, isNull);
      await reveal(tester, Key('select-increment-${product.id}'));
      await tester.tap(find.byKey(Key('select-increment-${product.id}')));
      await tester.pump();
      expect(tester.widget<IconButton>(decrement).onPressed, isNotNull);
      await tester.tap(decrement);
      await tester.pump();
      expect(
        tester.widget<Text>(quantity).data,
        '${product.minimumOrderQuantity}',
      );
      expect(tester.widget<IconButton>(decrement).onPressed, isNull);
    }
  });

  testWidgets(
    'detail quantity starts at the minimum and cannot be decreased below it',
    (tester) async {
      for (final product in [cases, single]) {
        await pumpCatalog(tester, [product]);
        await reveal(tester, Key('select-increment-${product.id}'));
        await tester.tap(find.byKey(Key('select-increment-${product.id}')));
        await tester.pump();
        await tester.tap(find.byKey(Key('details-${product.id}')));
        await tester.pumpAndSettle();
        final quantity = find.byKey(Key('detail-qty-${product.id}'));
        final decrement = find.byKey(Key('detail-decrement-${product.id}'));
        expect(
          tester.widget<Text>(quantity).data,
          '${product.minimumOrderQuantity}',
        );
        expect(tester.widget<IconButton>(decrement).onPressed, isNull);
        await reveal(tester, Key('detail-increment-${product.id}'));
        await tester.tap(find.byKey(Key('detail-increment-${product.id}')));
        await tester.pump();
        await tester.tap(decrement);
        await tester.pump();
        expect(
          tester.widget<Text>(quantity).data,
          '${product.minimumOrderQuantity}',
        );
        expect(tester.widget<IconButton>(decrement).onPressed, isNull);
        await reveal(tester, Key('detail-add-${product.id}'));
        await tester.tap(find.byKey(Key('detail-add-${product.id}')));
        await tester.pumpAndSettle();
        expect(
          tester.widget<Text>(find.byKey(const Key('cart-count'))).data,
          '${product.minimumOrderQuantity}',
        );
      }
    },
  );

  testWidgets('cart lines show the minimum order quantity', (tester) async {
    final cart = Cart()
      ..add(cases)
      ..add(boxes)
      ..add(single);
    addTearDown(cart.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider<Cart>.value(
        value: cart,
        child: const MaterialApp(home: CartScreen()),
      ),
    );
    expect(find.text('Minimum order: 3 cases'), findsOneWidget);
    expect(find.text('Minimum order: 2 boxes'), findsOneWidget);
    expect(find.text('Minimum order: 1 cases'), findsNothing);
  });

  testWidgets('decrementing a cart line at its minimum removes it', (
    tester,
  ) async {
    await pumpCatalog(tester, [cases]);
    await reveal(tester, const Key('add-cases'));
    await tester.tap(find.byKey(const Key('add-cases')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-cart')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('increment-cases')));
    await tester.pump();
    expect(tester.widget<Text>(find.byKey(const Key('qty-cases'))).data, '4');
    await tester.tap(find.byKey(const Key('decrement-cases')));
    await tester.pump();
    expect(tester.widget<Text>(find.byKey(const Key('qty-cases'))).data, '3');
    await tester.tap(find.byKey(const Key('decrement-cases')));
    await tester.pumpAndSettle();
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.byKey(const Key('place-order')), findsNothing);
  });

  testWidgets(
    'checkout blocks an invalid cart and announces the minimum message',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final cart = _InvalidCart(cases);
      addTearDown(cart.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider<Cart>.value(
          value: cart,
          child: const MaterialApp(home: CartScreen()),
        ),
      );
      await tester.tap(find.byKey(const Key('place-order')));
      await tester.pumpAndSettle();
      const message =
          'Some products are below their minimum order quantity. '
          'Update or remove them before checkout.';
      expect(find.text(message), findsOneWidget);
      final announcement = tester.getSemantics(find.text(message));
      expect(announcement.label, message);
      expect(
        announcement.getSemanticsData().flagsCollection.isLiveRegion,
        isTrue,
      );
      expect(find.text('Order placed'), findsNothing);
      expect(cart.wasCleared, isFalse);
      expect(cart.quantityOf(cases), 2);
      semantics.dispose();
    },
  );

  testWidgets(
    'touched product controls have product-specific accessible labels',
    (tester) async {
      await pumpCatalog(tester, [cases]);
      expect(find.byTooltip('View details for Test Cases'), findsNWidgets(2));
      expect(find.byTooltip('Add Test Cases to cart'), findsOneWidget);
      expect(find.byTooltip('Decrease quantity of Test Cases'), findsOneWidget);
      expect(find.byTooltip('Increase quantity of Test Cases'), findsOneWidget);
      await reveal(tester, const Key('details-cases'));
      await tester.tap(find.byKey(const Key('details-cases')));
      await tester.pumpAndSettle();
      expect(
        find.byTooltip('Close product details for Test Cases'),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byTooltip('Add Test Cases to cart'),
        ),
        findsOneWidget,
      );
      await reveal(tester, const Key('detail-add-cases'));
      await tester.tap(find.byKey(const Key('detail-add-cases')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('open-cart')));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Remove Test Cases from cart'), findsOneWidget);
    },
  );
}

// Simulate a stale, invalid cart without adding production mutation hooks.
class _InvalidCart extends Cart {
  _InvalidCart(this.product);

  final Product product;
  bool wasCleared = false;

  @override
  List<Product> get products => [product];

  @override
  int quantityOf(Product product) => 2;

  @override
  int get itemCount => 2;

  @override
  int get totalCents => product.priceCents * itemCount;

  @override
  bool get isEmpty => false;

  @override
  void clear() {
    wasCleared = true;
  }
}
