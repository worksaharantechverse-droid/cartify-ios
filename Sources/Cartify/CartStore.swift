import Foundation
import Combine

final class CartStore: ObservableObject {
    @Published private(set) var lines: [CartLine] = []
    @Published private(set) var appliedPromo: PromoCode?

    private let defaults: UserDefaults
    private let linesKey = "cartify.lines.v1"
    private let promoKey = "cartify.promo.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: linesKey),
           let decoded = try? JSONDecoder().decode([CartLine].self, from: data) {
            self.lines = decoded
        }
        if let raw = defaults.string(forKey: promoKey) {
            self.appliedPromo = PromoCode.match(raw)
        }
    }

    var itemCount: Int { lines.reduce(0) { $0 + $1.quantity } }

    func quantity(for productID: String) -> Int {
        lines.first { $0.productID == productID }?.quantity ?? 0
    }

    func add(product: Product) {
        setQuantity(productID: product.id, quantity: quantity(for: product.id) + 1)
    }

    func setQuantity(productID: String, quantity: Int) {
        guard quantity > 0 else {
            lines.removeAll { $0.productID == productID }
            persist()
            return
        }
        if let index = lines.firstIndex(where: { $0.productID == productID }) {
            lines[index].quantity = quantity
        } else {
            lines.append(CartLine(productID: productID, quantity: quantity))
        }
        persist()
    }

    func decrement(productID: String) {
        setQuantity(productID: productID, quantity: quantity(for: productID) - 1)
    }

    func remove(productID: String) {
        setQuantity(productID: productID, quantity: 0)
    }

    @discardableResult
    func applyPromo(_ code: String) -> Bool {
        guard let promo = PromoCode.match(code) else { return false }
        appliedPromo = promo
        defaults.set(promo.rawValue, forKey: promoKey)
        return true
    }

    func clearPromo() {
        appliedPromo = nil
        defaults.removeObject(forKey: promoKey)
    }

    func clear() {
        lines = []
        clearPromo()
        persist()
    }

    func items(using catalog: CatalogServicing) -> [CartItem] {
        lines.compactMap { line in
            guard let product = catalog.product(withID: line.productID) else { return nil }
            return CartItem(product: product, quantity: line.quantity)
        }
    }

    func totals(using catalog: CatalogServicing) -> OrderTotals {
        let subtotal = Money.rounded(items(using: catalog).reduce(0) { $0 + $1.lineTotal })
        let discount = appliedPromo.map { Money.rounded(subtotal * $0.discountRate) } ?? 0
        return OrderTotals(
            subtotal: subtotal,
            discount: discount,
            total: Money.rounded(subtotal - discount),
            itemCount: itemCount
        )
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(lines) else { return }
        defaults.set(data, forKey: linesKey)
    }
}
