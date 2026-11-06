---
applyTo: "lib/**/*.dart"
---
# Dart and Flutter code in `lib/`

- Follow `analysis_options.yaml` (`flutter_lints`). `flutter analyze` must report no issues.
- Prefer `const` constructors and `final` fields. Models are immutable.
- New `Product` fields need a sensible default so existing catalog entries and tests keep
  compiling. Set the value explicitly on every `sampleCatalog` entry when it matters for the
  feature.
- `Cart` methods that change state call `notifyListeners()` exactly once per change.
- Widgets read state with `context.watch<Cart>()` / `context.read<Cart>()` from
  `package:provider`; don't pass the cart down through constructors.
- Keep `QuantitySelector` generic: pass limits and callbacks in, don't import `Cart` into it.
- Disable a control (pass `null` to `onPressed`) instead of silently ignoring taps.
- Use `Theme.of(context)` colors and text styles; no hard-coded colors.
