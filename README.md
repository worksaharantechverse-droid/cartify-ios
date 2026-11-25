# Cartify

A programmatic UIKit e-commerce demo with a local catalogue, category filtering, product detail, cart management, promo codes and simulated checkout.

## Installation

```bash
cd 06-Cartify
brew install xcodegen
xcodegen generate
open Cartify.xcodeproj
```

## Build

```bash
xcodebuild -project Cartify.xcodeproj -scheme Cartify \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/CartifyDerived CODE_SIGNING_ALLOWED=NO build
```

## Architecture

- **Models**: `Product`, `CartItem`, `CartTotals`.
- **Catalogue**: `CatalogServicing` with an in-code 18-product catalogue.
- **Cart**: `CartStore` persists quantities to `UserDefaults`; `CartViewModel` calculates subtotal, discount and total.
- **Views**: `ShopViewController`, `ProductCell`, `ProductDetailViewController`, `CartViewController`, `CartItemCell`.

## Features

- Product grid with category chips and search.
- Product detail with price, description and add-to-cart.
- Cart with quantity steppers and remove actions.
- Promo code `SAVE10` for 10% off.
- Simulated checkout confirmation.
- Local cart persistence.
- Light and dark appearance.

## Verification

- Build: passed on Xcode 26.0.1, iOS 17.0 deployment target.
- Test targets compile via `build-for-testing`.
- Unit and UI tests authored; execution skipped at the user's request.
- Installed and launched on iPhone 17 (iOS 26.0); genuine light and dark screenshots captured.

## Known limitations

- The catalogue and checkout are local demos; no payments or account system are included.
- Cart data is local to one device.
