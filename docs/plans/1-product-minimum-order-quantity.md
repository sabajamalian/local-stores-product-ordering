# Plan: Enforce minimum order quantity per product

- **Issue:** #1
- **Author:** planner agent
- **Status:** Approved
- **Business-rule impact:** Yes — minimum quantities change the quantities and order totals stores can submit. The product owner approved the MOQ values specified in the issue.

## 1. Problem and goal
Some suppliers require a minimum number of cases or boxes per product, but the storefront currently allows a single case or box. Add a per-product minimum (default 1), show higher minimums before ordering, and enforce them in the cart and at checkout. Done means products begin at their minimum, lines cannot remain below it, and checkout cannot confirm an invalid cart.

## 2. Current behavior
`lib/models/product.dart` defines immutable `Product` data and `sampleCatalog`; there is no minimum quantity field. `ProductListScreen` in `lib/screens/product_list_screen.dart` keeps a card quantity initialized to 1, and its product-detail sheet also starts at 1. Both use `QuantitySelector` from `lib/widgets/quantity_selector.dart`, which accepts its decrement callback from the caller.

`Cart` in `lib/state/cart.dart` stores quantities by product ID. `Cart.add` adds the requested positive amount (default 1), and `Cart.decrement` removes a line only when its quantity reaches 0. `CartScreen` in `lib/screens/cart_screen.dart` lets users decrement lines and `_placeOrder` confirms and clears the cart without validating minimum quantities. Existing unit and widget coverage is in `test/cart_test.dart` and `test/widget_test.dart`; `integration_test/app_test.dart` exercises checkout and captures all four required screenshots.

Baseline: `flutter pub get` succeeded; `flutter test` passed all 12 tests.

## 3. Assumptions
- MOQ is a positive integer count of cases or boxes, not an individual-unit count or a pack-size multiple.
- The default MOQ is 1. Set the sample catalog values explicitly to Cola 600 ml = 2 cases, Still Water 1 L = 3 cases, Potato Chips 45 g = 2 boxes, and 1 for the remaining products.
- The product card's quantity selector starts at the MOQ, just like the detail sheet.
- When a line reaches its MOQ, another decrement removes the whole line. An add to an existing line adds to its current quantity; a first add below the MOQ is raised to the MOQ.
- Checkout validation is a defensive state-layer guard even though supported cart operations should keep quantities valid.
- Cart lines with MOQ > 1 show “Minimum order: N cases” or “Minimum order: N boxes” so the removal behavior is clear.
- If checkout validation fails, show: “Some products are below their minimum order quantity. Update or remove them before checkout.”
- No backend, per-store overrides, or case-pack increments are in scope.

## 4. Proposed design
- Model (`lib/models/`): Add an immutable `minimumOrderQuantity` integer to `Product`, defaulting to 1. Assign the specified values in `sampleCatalog`.
- State and business rules (`lib/state/`): Make first-time `Cart.add` use at least the product MOQ, and make `Cart.decrement` remove a line when the next decrement would put it below the MOQ. Expose a state-level minimum-quantity validity check for checkout. Keep notification behavior to one notification for each state change.
- UI (`lib/screens/`, `lib/widgets/`): Initialize card and detail selector quantities to each product's MOQ, and disable their decrement control at the MOQ. Show “Minimum order: N cases” or “Minimum order: N boxes” on cards, in the detail sheet, and under cart lines only when MOQ > 1. Show the exact agreed checkout validation message in an accessible live region and block confirmation if cart validation fails. Keep the `QuantitySelector` generic and preserve all existing widget keys.
- Docs (`README.md`): Explain that products may have minimum order quantities and that they are shown before adding to the cart.

## 5. Alternatives considered
- Enforce MOQ only in the selectors: rejected because callers can use `Cart` directly and would bypass the business rule.
- Apply MOQ to every product as a global constant: rejected because supplier requirements vary by product and the catalog needs a default for products without a special MOQ.
- Add case-pack multiples: out of scope and not needed to meet this issue.

## 6. Files to change
| File | Change |
| --- | --- |
| `lib/models/product.dart` | Add the defaulted MOQ field and set the sample catalog values. |
| `lib/state/cart.dart` | Enforce MOQ on additions/decrements and provide checkout validity state. |
| `lib/screens/product_list_screen.dart` | Show applicable MOQ text and initialize card/detail quantities and decrement limits from the product MOQ. |
| `lib/screens/cart_screen.dart` | Show applicable MOQ under each cart line; decrement at MOQ removes the line; guard checkout and announce the agreed validation message if invalid. |
| `test/cart_test.dart` | Cover default/sample MOQs, add and decrement boundaries, and state validity. |
| `test/widget_test.dart` | Cover MOQ copy on cards, details, and cart lines; starting quantities and limits; line removal; and blocked/valid checkout behavior. |
| `integration_test/app_test.dart` | Update the checkout flow to order products at their MOQ and assert the resulting quantity and total while retaining all four screenshot names and order. |
| `README.md` | Document visible per-product minimums and their effect on ordering. |

## 7. Implementation steps
1. Add the Product field with a default of 1 and set all sample catalog entries, including explicit values of 1 where no special MOQ applies.
2. Update `Cart.add` and `Cart.decrement` to preserve the minimum-quantity invariant, then expose a read-only check for checkout validation.
3. Update product cards and the detail sheet to show minimums above 1 and initialize/limit their selectors using the MOQ.
4. Update cart rendering to show the applicable MOQ under each cart line, remove a line at the decrement boundary, and block invalid checkout with the agreed live-region message.
5. Add focused model/state and widget tests, update the integration scenario and its expected totals, and document the user-visible behavior in `README.md`.
6. Run `flutter pub get`, `flutter analyze`, `flutter test`, and the Android/iOS integration flow per CI; confirm screenshots remain `catalog`, `product-details`, `cart`, `order-confirmation` in that order.

## 8. Test plan
| Acceptance criterion | Test (file and name) | Type (unit / widget / integration) |
| --- | --- | --- |
| Each product has an MOQ; products without one default to 1. | `test/cart_test.dart`: `products default to a minimum order quantity of one`; verify each sample value in `sample catalog has the requested minimum order quantities`. | unit |
| Sample catalog MOQs match the issue; other products remain at 1. | `test/cart_test.dart`: `sample catalog has the requested minimum order quantities`. | unit |
| Cards and detail sheet show “Minimum order: N cases/boxes” only when MOQ > 1. | `test/widget_test.dart`: `shows minimum order quantities on product cards and details only when above one`. | widget |
| Detail selector starts at MOQ and cannot go lower. | `test/widget_test.dart`: `detail quantity starts at the minimum and cannot be decreased below it`. | widget |
| First add adds at least MOQ; existing additions continue to merge. | `test/cart_test.dart`: `first add raises a below-minimum request to the minimum`; `add merges quantities for an existing line`. | unit |
| Decrementing below MOQ removes the line; cart lines show the MOQ when it is above 1. | `test/cart_test.dart`: `decrement removes a line at its minimum`; `decrement preserves quantities above the minimum`; `test/widget_test.dart`: `decrementing a cart line at its minimum removes it` and `cart lines show the minimum order quantity`. | unit / widget |
| Cart enforces the rule and checkout is blocked with the agreed clear message if a line is below MOQ. | `test/cart_test.dart`: `cart minimum validation reflects line quantities`; `test/widget_test.dart`: `checkout blocks an invalid cart and announces the minimum message` and `valid cart can be checked out`. | unit / widget |
| Unit, widget, integration tests cover the rule; CI screenshots still pass. | The unit and widget tests above; `integration_test/app_test.dart`: update `browse, add to cart, and place an order` to order Cola x2 and Water x3 and assert 5 cases/boxes and `$864.00`; retain screenshot calls/names and ordering. | unit / widget / integration |

Baseline before changes: `flutter pub get` succeeded and `flutter test` passed all 12 tests.

## 9. Accessibility
Retain the product-specific labels and tooltips on quantity controls. Give any changed add control a product-specific accessible label where needed. The checkout validation uses the agreed readable message in a live region; do not rely on color alone.

## 10. Risks and rollout
Minimums increase requested order quantities and order totals, including the seeded sample cart behavior; the product owner has approved the MOQ values in the issue. Existing widget and integration assertions that assume one case per add or the old total must be updated. Keep the four screenshot calls and their ordering unchanged so Android/iOS CI screenshot verification continues to pass. The change is in-memory only and can be reverted without data migration.

## 11. Open questions
N/A — review decisions resolved the questions about the card selector and checkout message.

## 12. Review decisions
- **Status:** Approved.
- The product card quantity selector starts at the MOQ, the same as the detail-sheet selector.
- The checkout validation message is: “Some products are below their minimum order quantity. Update or remove them before checkout.”
- Cart lines with MOQ > 1 show “Minimum order: N cases” or “Minimum order: N boxes”; add a widget test for this behavior.
- The product owner approves the MOQ values specified in the issue.
