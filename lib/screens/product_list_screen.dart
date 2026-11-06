import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../state/cart.dart';
import '../widgets/product_image.dart';
import '../widgets/quantity_selector.dart';
import 'cart_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key, this.catalog = sampleCatalog});

  final List<Product> catalog;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _query = '';
  String? _category;

  void _openCart() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const CartScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<Cart>();
    final theme = Theme.of(context);
    final categories = widget.catalog.map((p) => p.category).toSet();
    final products = widget.catalog.where((p) {
      final matchesQuery = '${p.name} ${p.description} ${p.category}'
          .toLowerCase()
          .contains(_query);
      return matchesQuery && (_category == null || p.category == _category);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Stores'),
        actions: [
          IconButton(
            key: const Key('open-cart'),
            tooltip: 'Cart',
            onPressed: _openCart,
            icon: Badge(
              isLabelVisible: cart.itemCount > 0,
              label: Text('${cart.itemCount}', key: const Key('cart-count')),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Products', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Prices per case or box.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('product-search'),
                    decoration: const InputDecoration(
                      hintText: 'Search products',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) =>
                        setState(() => _query = value.trim().toLowerCase()),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All products'),
                        selected: _category == null,
                        onSelected: (_) => setState(() => _category = null),
                      ),
                      for (final category in categories)
                        ChoiceChip(
                          label: Text(category),
                          selected: _category == category,
                          onSelected: (selected) => setState(
                            () => _category = selected ? category : null,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${products.length} products',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 12),
                  if (products.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.search_off, size: 40),
                            SizedBox(height: 12),
                            Text('No products found'),
                            SizedBox(height: 4),
                            Text('Try another search or category.'),
                          ],
                        ),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = (constraints.maxWidth / 260)
                            .floor()
                            .clamp(1, 4);
                        final width =
                            (constraints.maxWidth - (columns - 1) * 24) /
                            columns;
                        return Wrap(
                          spacing: 24,
                          runSpacing: 32,
                          children: [
                            for (final product in products)
                              SizedBox(
                                width: width,
                                child: _ProductCard(
                                  key: ValueKey(product.id),
                                  product: product,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                  Text(
                    'Demo catalog. Photos show the product type, not the exact '
                    'brand, packaging, or pack size.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
                    constraints: const BoxConstraints(maxWidth: 1140),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${cart.itemCount} in cart\n${formatCents(cart.totalCents)}',
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        FilledButton(
                          key: const Key('review-cart'),
                          onPressed: _openCart,
                          child: const Text('View cart'),
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

class _ProductCard extends StatefulWidget {
  const _ProductCard({super.key, required this.product});

  final Product product;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  int _quantity = 1;

  void _add(int quantity) {
    final product = widget.product;
    context.read<Cart>().add(product, quantity: quantity);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Added $quantity x ${product.name} to your cart'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _showDetails() {
    var quantity = _quantity;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 600),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: 'Close product details',
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
                ProductImage(product: widget.product, height: 240),
                const SizedBox(height: 20),
                Text(
                  widget.product.category,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.product.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '${formatCents(widget.product.priceCents)} / ${widget.product.unit}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.product.description.isEmpty
                      ? 'No description available.'
                      : widget.product.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                const Text('Quantity (cases / boxes)'),
                const SizedBox(height: 8),
                QuantitySelector(
                  quantity: quantity,
                  label: widget.product.name,
                  quantityKey: Key('detail-qty-${widget.product.id}'),
                  incrementKey: Key('detail-increment-${widget.product.id}'),
                  decrementKey: Key('detail-decrement-${widget.product.id}'),
                  onIncrement: () => setSheetState(() => quantity++),
                  onDecrement: quantity > 1
                      ? () => setSheetState(() => quantity--)
                      : null,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: Key('detail-add-${widget.product.id}'),
                    onPressed: () {
                      _add(quantity);
                      setState(() => _quantity = quantity);
                      Navigator.of(sheetContext).pop();
                    },
                    child: Text(
                      'Add to cart / ${formatCents(widget.product.priceCents * quantity)}',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Representative photo. Brand, packaging, and pack size may differ.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);
    final inCart = context.watch<Cart>().quantityOf(product);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _showDetails,
          borderRadius: BorderRadius.circular(4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: ProductImage(product: product, height: 180),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                product.unit,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    formatCents(product.priceCents),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    key: Key('details-${product.id}'),
                    onPressed: _showDetails,
                    child: const Text('View details'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  QuantitySelector(
                    quantity: _quantity,
                    label: product.name,
                    quantityKey: Key('select-qty-${product.id}'),
                    incrementKey: Key('select-increment-${product.id}'),
                    decrementKey: Key('select-decrement-${product.id}'),
                    onIncrement: () => setState(() => _quantity++),
                    onDecrement: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  FilledButton(
                    key: Key('add-${product.id}'),
                    onPressed: () => _add(_quantity),
                    child: const Text('Add'),
                  ),
                  if (inCart > 0) ...[
                    const SizedBox(height: 8),
                    Text('$inCart in cart', style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
