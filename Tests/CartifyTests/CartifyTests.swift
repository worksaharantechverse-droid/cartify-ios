import XCTest
@testable import Cartify

final class CartTotalsTests: XCTestCase {
    private func makeStore() -> (CartStore, UserDefaults) {
        let suite = "CartifyTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        return (CartStore(defaults: defaults), defaults)
    }

    func testSubtotalsUseQuantityAndCatalogPrice() throws {
        let (store, _) = makeStore()
        let catalog = LocalCatalogService()
        let lamp = try XCTUnwrap(catalog.product(withID: "p01"))
        let bottle = try XCTUnwrap(catalog.product(withID: "p17"))

        store.add(product: lamp)
        store.setQuantity(productID: bottle.id, quantity: 2)

        let totals = store.totals(using: catalog)
        XCTAssertEqual(totals.subtotal, Money.rounded(lamp.price + bottle.price * 2))
        XCTAssertEqual(totals.discount, 0)
        XCTAssertEqual(totals.total, totals.subtotal)
        XCTAssertEqual(totals.itemCount, 3)
    }

    func testSAVE10AppliesTenPercent() throws {
        let (store, _) = makeStore()
        let catalog = LocalCatalogService()
        let speaker = try XCTUnwrap(catalog.product(withID: "p09"))
        store.setQuantity(productID: speaker.id, quantity: 2)

        XCTAssertTrue(store.applyPromo(" save10 "))
        let totals = store.totals(using: catalog)
        XCTAssertEqual(totals.subtotal, 198)
        XCTAssertEqual(totals.discount, 19.80)
        XCTAssertEqual(totals.total, 178.20)
    }

    func testInvalidPromoKeepsExistingPromo() throws {
        let (store, _) = makeStore()
        let catalog = LocalCatalogService()
        let speaker = try XCTUnwrap(catalog.product(withID: "p09"))
        store.add(product: speaker)

        XCTAssertTrue(store.applyPromo("SAVE10"))
        XCTAssertFalse(store.applyPromo("NOPE"))
        XCTAssertEqual(store.appliedPromo, .save10)
        XCTAssertEqual(store.totals(using: catalog).discount, 9.90)
    }

    func testClearingPromoRemovesDiscount() throws {
        let (store, _) = makeStore()
        let catalog = LocalCatalogService()
        let speaker = try XCTUnwrap(catalog.product(withID: "p09"))
        store.add(product: speaker)
        store.applyPromo("SAVE10")
        store.clearPromo()
        XCTAssertEqual(store.totals(using: catalog).discount, 0)
    }

    func testCartPersistsAcrossStoreInstances() throws {
        let (store, defaults) = makeStore()
        let catalog = LocalCatalogService()
        let lamp = try XCTUnwrap(catalog.product(withID: "p01"))
        store.add(product: lamp)
        store.setQuantity(productID: lamp.id, quantity: 3)
        store.applyPromo("SAVE10")

        let reloaded = CartStore(defaults: defaults)
        XCTAssertEqual(reloaded.quantity(for: lamp.id), 3)
        XCTAssertEqual(reloaded.appliedPromo, .save10)
        XCTAssertEqual(reloaded.totals(using: catalog).itemCount, 3)

        reloaded.remove(productID: lamp.id)
        reloaded.clearPromo()
        XCTAssertEqual(CartStore(defaults: defaults).itemCount, 0)
    }
}

final class CatalogFilteringTests: XCTestCase {
    func testCatalogHasAtLeastSixteenProductsAcrossCategories() {
        let catalog = LocalCatalogService()
        XCTAssertGreaterThanOrEqual(catalog.products.count, 16)
        XCTAssertEqual(Set(catalog.products.map(\.id)).count, catalog.products.count)
        XCTAssertEqual(catalog.categories.count, ProductCategory.allCases.count)
        for category in catalog.categories {
            XCTAssertTrue(catalog.products.contains { $0.category == category })
        }
    }

    func testFilterByCategory() {
        let catalog = LocalCatalogService()
        let results = catalog.filtered(category: .fitness, query: "")
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0.category == .fitness })
    }

    func testFilterByQueryIsCaseInsensitiveAndSearchesSummary() throws {
        let catalog = LocalCatalogService()
        let byName = catalog.filtered(category: nil, query: "  earbuds  ")
        XCTAssertFalse(byName.isEmpty)
        XCTAssertTrue(byName.allSatisfy { $0.name.lowercased().contains("earbuds") || $0.summary.lowercased().contains("earbuds") })

        let bySummary = catalog.filtered(category: nil, query: "LAMP")
        XCTAssertEqual(bySummary.map(\.id), ["p01"])
        XCTAssertTrue(catalog.filtered(category: nil, query: "not-a-product").isEmpty)
    }

    func testCategoryAndQueryCombine() {
        let catalog = LocalCatalogService()
        let results = catalog.filtered(category: .home, query: "linen")
        XCTAssertEqual(results.map(\.id), ["p03"])
        XCTAssertNil(catalog.product(withID: "missing"))
    }
}
