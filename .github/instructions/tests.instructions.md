---
applyTo: "test/**,integration_test/**,test_driver/**"
---
# Tests

- Unit tests for `Cart` and models go in `test/cart_test.dart` (or a new
  `test/<area>_test.dart` for a new area). Widget tests go in `test/widget_test.dart`.
- Use small local fixtures (`const Product(id: 'a', ...)`) in unit tests rather than relying
  on `sampleCatalog` values that may change.
- Find widgets by `Key` or tooltip, not by text that's likely to be reworded.
- Name tests by behavior: `'rejects quantities below the minimum'`, not `'test 3'`.
- The integration test must still capture `catalog`, `product-details`, `cart`, and
  `order-confirmation` screenshots in that order. CI fails if any are missing.
- Call `ensureVisible` and `pumpAndSettle` before every tap in integration tests; the catalog
  scrolls on small simulators.
