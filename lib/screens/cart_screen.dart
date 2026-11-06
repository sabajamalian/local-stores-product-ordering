import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../state/cart.dart';
import '../widgets/product_image.dart';
import '../widgets/quantity_selector.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _placeOrder(BuildContext context) async {
    final cart = context.read<Cart>();
    final total = formatCents(cart.totalCents);
    final items = cart.itemCount;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Order placed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$items ${items == 1 ? 'item' : 'items'}, total $total.'),
            const SizedBox(height: 12),
            const Text(
              'This is a demo confirmation. No order has been sent '
              'and no payment has been taken.',
            ),
          ],
        ),
        actions: [
          TextButton(
            key: const Key('order-confirm-ok'),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    cart.clear();
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<Cart>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your cart is empty',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add a few essentials to start your next order.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Browse products'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${cart.products.length} ${cart.products.length == 1 ? 'product' : 'products'} / '
                          '${cart.itemCount} cases and boxes',
                        ),
                        const Divider(height: 32),
                        for (final product in cart.products)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final details = Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${formatCents(product.priceCents)} / ${product.unit}',
                                        ),
                                        const SizedBox(height: 16),
                                        Wrap(
                                          spacing: 16,
                                          runSpacing: 12,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            QuantitySelector(
                                              quantity: cart.quantityOf(
                                                product,
                                              ),
                                              label: product.name,
                                              quantityKey: Key(
                                                'qty-${product.id}',
                                              ),
                                              decrementKey: Key(
                                                'decrement-${product.id}',
                                              ),
                                              incrementKey: Key(
                                                'increment-${product.id}',
                                              ),
                                              onDecrement: () =>
                                                  cart.decrement(product),
                                              onIncrement: () =>
                                                  cart.add(product),
                                            ),
                                            Text(
                                              formatCents(
                                                product.priceCents *
                                                    cart.quantityOf(product),
                                              ),
                                              style:
                                                  theme.textTheme.titleMedium,
                                            ),
                                            TextButton.icon(
                                              key: Key('remove-${product.id}'),
                                              onPressed: () =>
                                                  cart.remove(product),
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                size: 18,
                                              ),
                                              label: const Text('Remove'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                    if (constraints.maxWidth < 400) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ProductImage(
                                            product: product,
                                            height: 120,
                                          ),
                                          const SizedBox(height: 16),
                                          details,
                                        ],
                                      );
                                    }
                                    return Row(
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          child: ProductImage(
                                            product: product,
                                            height: 100,
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        Expanded(child: details),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total: ${formatCents(cart.totalCents)}',
                                  key: const Key('cart-total'),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Demo checkout. No payment or delivery is processed.',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilledButton(
                          key: const Key('place-order'),
                          onPressed: () => _placeOrder(context),
                          child: const Text('Place order'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
