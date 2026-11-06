# local-stores-product-ordering

A Flutter storefront that lets local stores browse products and build wholesale orders.
It targets Android, iOS, and web.

**Live web preview:** https://sabajamalian.github.io/local-stores-product-ordering/

## Storefront

The responsive catalog has bundled product photos, searchable descriptions,
category filters, and a product-detail sheet. Choose a quantity before adding to the cart,
then adjust quantities or remove products from the cart. Prices and quantities are per
case or box, not per individual bottle or pack.

The five product photos in `assets/products/` work offline and don't
depend on an external image service at runtime. They show product types, not the exact
brand, packaging, or pack size being ordered.
Add `description`, `category`, and `imageAsset` to a catalog entry in
`lib/models/product.dart` to supply its details and image.

### Photo sources

The catalog photos are from Unsplash and used under the
[Unsplash License](https://unsplash.com/license).
These are bundled editorial examples, not supplier-provided product photography.

| Asset | Source |
| --- | --- |
| Cola | [Original photo](https://images.unsplash.com/photo-1622483767028-3f66f32aef97) |
| Water | [Original photo](https://images.unsplash.com/photo-1523362628745-0c100150b504) |
| Orange juice | [Original photo](https://images.unsplash.com/photo-1600271886742-f049cd451bba) |
| Snacks | [Original photo](https://images.unsplash.com/photo-1566478989037-eec170784d0b) |
| Cookies | [Original photo](https://images.unsplash.com/photo-1499636136210-6f4ee915583e) |

This is an in-memory demo. Checkout shows a confirmation and clears the cart; it doesn't
send orders, take payment, or arrange delivery. Cart contents reset when the app restarts.

## What happens on every push to `main`

The [CI workflow](.github/workflows/ci.yml) runs these jobs on GitHub-hosted runners:

| Job | Runner | What it does |
| --- | --- | --- |
| Analyze and unit tests | Ubuntu | `flutter analyze` and `flutter test` |
| Android emulator | Ubuntu (KVM) | Builds a debug APK, boots an Android 14 emulator, runs the integration test |
| iOS simulator | macOS | Builds for the iOS Simulator, boots an iPhone simulator, runs the integration test |
| Web build | Ubuntu | `flutter build web` |
| Deploy web preview | Ubuntu | Publishes the web build to GitHub Pages once every other job passes |

Pull requests run the same checks but don't deploy.

### Where to find results

Open a run under the **Actions** tab. The run summary has these artifacts:

- `android-build`: `app-debug.apk` (install with `adb install`) and screenshots taken on the emulator
- `ios-simulator-build`: `Runner-simulator.zip` (unzip, then `xcrun simctl install booted Runner.app`) and screenshots taken on the simulator

### Limits

GitHub can build the apps and run tests on an emulator or simulator, but it can't stream an
interactive Android or iOS device to your browser. The GitHub Pages site is the web build of the
same Flutter code, so use it to click through the app. Platform-specific behavior still needs
the emulator/simulator test results or a real device.

The iOS build is unsigned and runs only in the Simulator. Installing on a physical iPhone or
shipping to TestFlight requires an Apple Developer account and code-signing secrets.

## Run locally

```sh
flutter pub get
flutter test                      # unit and widget tests
flutter run                       # pick a device or emulator
flutter run -d chrome             # web

# Integration test with screenshots saved to build/screenshots/
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart -d <device-id>
```

## Project layout

```
lib/
  main.dart                      app entry, provides the Cart
  models/product.dart            Product model and sample catalog
  state/cart.dart                Cart (ChangeNotifier)
  screens/product_list_screen.dart
  screens/cart_screen.dart
  widgets/                       shared product images and quantity controls
assets/products/                 bundled representative product photos
test/                            unit and widget tests
integration_test/app_test.dart   end-to-end flow run on emulator and simulator
test_driver/integration_test.dart  saves screenshots from flutter drive
```
