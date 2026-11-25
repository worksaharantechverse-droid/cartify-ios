# Architecture — Cartify

## Layers

| Layer | Types | Responsibility |
|-------|-------|----------------|
| Model | `Product`, `CartItem`, `CartTotals` | Value types for catalogue and pricing |
| Service | `CatalogServicing` | Local 18-product catalogue and filtering |
| Store | `CartStore` | Codable UserDefaults persistence |
| ViewModel | `ShopViewModel`, `CartViewModel` | Filtering, search and totals |
| Views | `ShopViewController`, `ProductDetailViewController`, `CartViewController` | Programmatic UIKit screens |

## Pricing flow

`CartViewModel` computes subtotal, applies the `SAVE10` discount and derives the final total as a pure value. Unit tests exercise these calculations without UIKit.

## Persistence

The cart is encoded to `UserDefaults`, so quantities survive relaunch without a database or account system.

## SOLID application

- Single responsibility: catalogue, cart storage and pricing are separate.
- Dependency inversion: view models depend on catalog and store abstractions.
- Liskov substitution: mock catalogues/stores can be injected in tests.
