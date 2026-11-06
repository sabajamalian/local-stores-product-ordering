# local-stores-product-ordering

A simple Flutter app that lets local stores browse products, build a cart, and place an order.
It targets Android, iOS, and web.

**Live web preview:** https://sabajamalian.github.io/local-stores-product-ordering/

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
test/                            unit and widget tests
integration_test/app_test.dart   end-to-end flow run on emulator and simulator
test_driver/integration_test.dart  saves screenshots from flutter drive
```
