class Product {
  const Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.priceCents,
  });

  final String id;
  final String name;
  final String unit;
  final int priceCents;
}

const sampleCatalog = <Product>[
  Product(id: 'cola-600', name: 'Cola 600 ml', unit: 'case of 24', priceCents: 28800),
  Product(id: 'water-1l', name: 'Still Water 1 L', unit: 'case of 12', priceCents: 9600),
  Product(id: 'juice-1l', name: 'Orange Juice 1 L', unit: 'case of 12', priceCents: 21600),
  Product(id: 'chips-45', name: 'Potato Chips 45 g', unit: 'box of 30', priceCents: 15000),
  Product(id: 'cookies-90', name: 'Chocolate Cookies 90 g', unit: 'box of 24', priceCents: 16800),
];

String formatCents(int cents) {
  final whole = cents ~/ 100;
  final frac = (cents % 100).toString().padLeft(2, '0');
  return '\$$whole.$frac';
}
