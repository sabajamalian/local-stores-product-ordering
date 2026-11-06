import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../state/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _placeOrder(BuildContext context) async {
    final cart = context.read<Cart>();
    final total = formatCents(cart.totalCents);
    final items = cart.itemCount;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Order placed'),
        content: Text('$items items, total $total.'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView(
              children: [
                for (final product in cart.products)
                  ListTile(
                    title: Text(product.name),
                    subtitle: Text(formatCents(product.priceCents * cart.quantityOf(product))),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          key: Key('decrement-${product.id}'),
                          tooltip: 'Remove one',
                          onPressed: () => cart.decrement(product),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('${cart.quantityOf(product)}', key: Key('qty-${product.id}')),
                        IconButton(
                          key: Key('increment-${product.id}'),
                          tooltip: 'Add one',
                          onPressed: () => cart.add(product),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Total: ${formatCents(cart.totalCents)}',
                  key: const Key('cart-total'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FilledButton(
                key: const Key('place-order'),
                onPressed: cart.isEmpty ? null : () => _placeOrder(context),
                child: const Text('Place order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
