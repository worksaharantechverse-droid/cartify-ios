import Foundation
import Combine

final class CartViewModel {
    private let store: CartStore
    private let catalog: CatalogServicing

    init(store: CartStore, catalog: CatalogServicing) {
        self.store = store
        self.catalog = catalog
    }

    var items: [CartItem] { store.items(using: catalog) }
    var totals: OrderTotals { store.totals(using: catalog) }
    var itemCount: Int { store.itemCount }
    var appliedPromo: PromoCode? { store.appliedPromo }
    var storeDidChange: AnyPublisher<Void, Never> { store.objectWillChange.eraseToAnyPublisher() }

    @discardableResult
    func applyPromo(_ code: String) -> Bool { store.applyPromo(code) }

    func setQuantity(productID: String, quantity: Int) {
        store.setQuantity(productID: productID, quantity: quantity)
    }

    @discardableResult
    func checkout() -> OrderConfirmation {
        let confirmation = OrderConfirmation(
            number: "CF-\(UUID().uuidString.prefix(8).uppercased())",
            total: totals.total,
            itemCount: totals.itemCount
        )
        store.clear()
        return confirmation
    }
}
