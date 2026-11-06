import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.product, this.height = 192});

  final Product product;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final asset = product.imageAsset;
    return Semantics(
      label: '${product.name}, representative photo',
      image: true,
      child: Container(
        height: height,
        width: double.infinity,
        color: colors.surfaceContainerHighest,
        child: asset == null
            ? _placeholder(context)
            : Image.asset(
                asset,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                errorBuilder: (_, error, stack) {
                  FlutterError.reportError(
                    FlutterErrorDetails(
                      exception: error,
                      stack: stack,
                      library: 'product image',
                      context: ErrorDescription('loading $asset'),
                    ),
                  );
                  return _placeholder(context);
                },
              ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.inventory_2_outlined,
          size: 40,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 8),
        const Text('Image unavailable'),
      ],
    );
  }
}
