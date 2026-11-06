import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../state/cart.dart';
import 'cart_screen.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key, this.catalog = sampleCatalog});

  final List<Product> catalog;

  @override
  Widget build(BuildContext context) {
    final itemCount = context.watch<Cart>().itemCount;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            key: const Key('open-cart'),
            tooltip: 'Cart',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CartScreen()),
            ),
            icon: Badge(
              isLabelVisible: itemCount > 0,
              label: Text('$itemCount', key: const Key('cart-count')),
              child: const Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: catalog.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final product = catalog[index];
          return ListTile(
            title: Text(product.name),
            subtitle: Text('${product.unit} - ${formatCents(product.priceCents)}'),
            trailing: FilledButton.tonal(
              key: Key('add-${product.id}'),
              onPressed: () {
                context.read<Cart>().add(product);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text('Added ${product.name}'),
                    duration: const Duration(seconds: 1),
                  ));
              },
              child: const Text('Add'),
            ),
          );
        },
      ),
    );
  }
}
