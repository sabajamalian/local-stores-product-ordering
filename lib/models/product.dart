class Product {
  const Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.priceCents,
    this.minimumOrderQuantity = 1,
    this.description = '',
    this.category = 'Other',
    this.imageAsset,
  });

  final String id;
  final String name;
  final String unit;
  final int priceCents;
  final int minimumOrderQuantity;
  final String description;
  final String category;
  final String? imageAsset;
}

const sampleCatalog = <Product>[
  Product(
    id: 'cola-600',
    name: 'Cola 600 ml',
    unit: 'case of 24',
    priceCents: 28800,
    minimumOrderQuantity: 2,
    category: 'Beverages',
    imageAsset: 'assets/products/cola.jpg',
    description:
        'Sparkling cola. Each case contains 24 bottles of 600 ml. '
        'Sold by the case.',
  ),
  Product(
    id: 'water-1l',
    name: 'Still Water 1 L',
    unit: 'case of 12',
    priceCents: 9600,
    minimumOrderQuantity: 3,
    category: 'Beverages',
    imageAsset: 'assets/products/water.jpg',
    description:
        'Still drinking water. Each case contains 12 bottles of 1 L. '
        'Sold by the case.',
  ),
  Product(
    id: 'juice-1l',
    name: 'Orange Juice 1 L',
    unit: 'case of 12',
    priceCents: 21600,
    minimumOrderQuantity: 1,
    category: 'Beverages',
    imageAsset: 'assets/products/juice.jpg',
    description:
        'Orange juice. Each case contains 12 cartons of 1 L. '
        'Sold by the case.',
  ),
  Product(
    id: 'chips-45',
    name: 'Potato Chips 45 g',
    unit: 'box of 30',
    priceCents: 15000,
    minimumOrderQuantity: 2,
    category: 'Snacks',
    imageAsset: 'assets/products/chips.jpg',
    description:
        'Potato chips in individually sealed 45 g bags. '
        'Each box contains 30 bags. Sold by the box.',
  ),
  Product(
    id: 'cookies-90',
    name: 'Chocolate Cookies 90 g',
    unit: 'box of 24',
    priceCents: 16800,
    minimumOrderQuantity: 1,
    category: 'Snacks',
    imageAsset: 'assets/products/cookies.jpg',
    description:
        'Chocolate cookies in individually packaged 90 g packs. '
        'Each box contains 24 packs. Sold by the box.',
  ),
];

String formatCents(int cents) {
  final whole = cents ~/ 100;
  final frac = (cents % 100).toString().padLeft(2, '0');
  return '\$$whole.$frac';
}
