# Copilot instructions: local-stores-product-ordering

Flutter app (Android, iOS, web) that lets local stores browse a wholesale catalog and build
orders. It's an in-memory demo: there is no backend, payment, or persistence.

Organization-wide engineering standards live in
`.github/instructions/org-standards.instructions.md` and apply to every change in this repo.
Read them before planning or writing code.

## Architecture
- `lib/models/`: immutable data classes (`const` constructors, `final` fields) and the
  `sampleCatalog`. Money is always integer cents (`priceCents`); format with `formatCents`.
- `lib/state/`: app state as `ChangeNotifier` classes (today: `Cart`), provided from
  `lib/main.dart` with `package:provider`. Business rules and validation belong here,
  not in widgets.
- `lib/screens/`: full screens. `lib/widgets/`: reusable widgets with no business rules.
- Products are sold by the case or box. Quantities are counts of cases/boxes, never
  individual units. Keep `unit` text (for example `case of 24`) visible wherever a
  quantity is shown.

## Build and validate
Run these before you finish any change:

```sh
flutter pub get
flutter analyze
flutter test
```

The integration test (`integration_test/app_test.dart`) runs in CI on an Android emulator
and an iOS simulator. CI requires four screenshots: `catalog`, `product-details`, `cart`,
`order-confirmation`. Don't rename or remove those `takeScreenshot` calls, and update the
test when you change the flow it drives.

## Conventions
- Widget keys used by tests follow `<action>-<productId>`, for example `add-cola-600`,
  `details-cola-600`, `detail-add-cola-600`. Keep existing keys stable; add new keys in the
  same style.
- Every interactive control needs a `tooltip` or `Semantics` label that names the product.
- Don't add packages to `pubspec.yaml` unless the plan approves it.
- Update `README.md` when behavior a user or reviewer would notice changes.
- CI is defined in `.github/workflows/ci.yml`. Pages deploy only runs from `main`.
