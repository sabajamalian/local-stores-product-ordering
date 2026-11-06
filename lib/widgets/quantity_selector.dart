import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.label,
    required this.onIncrement,
    required this.onDecrement,
    this.decrementKey,
    this.incrementKey,
    this.quantityKey,
  });

  final int quantity;
  final String label;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;
  final Key? decrementKey;
  final Key? incrementKey;
  final Key? quantityKey;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: decrementKey,
            tooltip: 'Decrease quantity of $label',
            onPressed: onDecrement,
            icon: const Icon(Icons.remove, size: 20),
          ),
          Semantics(
            liveRegion: true,
            label: 'Quantity of $label',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '$quantity',
                key: quantityKey,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          IconButton(
            key: incrementKey,
            tooltip: 'Increase quantity of $label',
            onPressed: onIncrement,
            icon: const Icon(Icons.add, size: 20),
          ),
        ],
      ),
    );
  }
}
