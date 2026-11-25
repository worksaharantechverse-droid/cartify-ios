import Foundation

protocol CatalogServicing {
    var products: [Product] { get }
    var categories: [ProductCategory] { get }
    func filtered(category: ProductCategory?, query: String) -> [Product]
    func product(withID id: String) -> Product?
}

final class LocalCatalogService: CatalogServicing {
    let products: [Product] = [
        Product(id: "p01", name: "Studio Desk Lamp", category: .home, price: 79.50, summary: "Dimmable LED lamp with a wireless charging base.", symbol: "💡", rating: 4.7),
        Product(id: "p02", name: "Ceramic Pour-Over Set", category: .home, price: 39.00, summary: "Hand-finished dripper and carafe for slow mornings.", symbol: "☕", rating: 4.8),
        Product(id: "p03", name: "Linen Duvet Cover", category: .home, price: 129.00, summary: "Breathable washed linen in a relaxed everyday weave.", symbol: "🛏️", rating: 4.6),
        Product(id: "p04", name: "Minimal Wall Clock", category: .home, price: 49.00, summary: "Silent sweep movement with a matte aluminium case.", symbol: "🕰️", rating: 4.4),
        Product(id: "p05", name: "Everyday Backpack", category: .fashion, price: 119.00, summary: "Water-resistant 18-litre pack with a padded laptop sleeve.", symbol: "🎒", rating: 4.7),
        Product(id: "p06", name: "Merino Crew Socks", category: .fashion, price: 29.00, summary: "Three pairs of temperature-regulating merino blend socks.", symbol: "🧦", rating: 4.5),
        Product(id: "p07", name: "Canvas Field Jacket", category: .fashion, price: 199.00, summary: "Washed cotton jacket with four utility pockets.", symbol: "🧥", rating: 4.9),
        Product(id: "p08", name: "Leather Card Holder", category: .fashion, price: 45.00, summary: "Slim full-grain leather holder for eight cards.", symbol: "👛", rating: 4.6),
        Product(id: "p09", name: "Portable Bluetooth Speaker", category: .audio, price: 99.00, summary: "Pocket-sized speaker with 12 hours of playback.", symbol: "🔊", rating: 4.7),
        Product(id: "p10", name: "Wireless Earbuds", category: .audio, price: 149.00, summary: "Lightweight earbuds with adaptive noise cancellation.", symbol: "🎧", rating: 4.8),
        Product(id: "p11", name: "Turntable Mate", category: .audio, price: 179.00, summary: "Compact record player with a built-in phono preamp.", symbol: "🎵", rating: 4.5),
        Product(id: "p12", name: "USB-C Hub", category: .electronics, price: 69.00, summary: "Seven-port hub with 4K HDMI and 100W pass-through.", symbol: "🔌", rating: 4.6),
        Product(id: "p13", name: "Mechanical Keyboard", category: .electronics, price: 139.00, summary: "Compact 65% board with hot-swappable switches.", symbol: "⌨️", rating: 4.9),
        Product(id: "p14", name: "4K Web Camera", category: .electronics, price: 89.00, summary: "Sharp video with auto framing and a privacy cover.", symbol: "📷", rating: 4.4),
        Product(id: "p15", name: "MagSafe Power Bank", category: .electronics, price: 59.00, summary: "Slim 10,000mAh pack with a magnetic snap-on grip.", symbol: "🔋", rating: 4.7),
        Product(id: "p16", name: "Yoga Travel Mat", category: .fitness, price: 64.00, summary: "Foldable non-slip mat that packs into a carry case.", symbol: "🧘", rating: 4.6),
        Product(id: "p17", name: "Reusable Water Bottle", category: .fitness, price: 34.00, summary: "Insulated stainless steel bottle, 750ml capacity.", symbol: "💧", rating: 4.8),
        Product(id: "p18", name: "Resistance Band Kit", category: .fitness, price: 25.00, summary: "Five graded bands with handles and a door anchor.", symbol: "🏋️", rating: 4.5)
    ]

    var categories: [ProductCategory] { ProductCategory.allCases }

    func filtered(category: ProductCategory?, query: String) -> [Product] {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return products.filter { product in
            if let category, product.category != category { return false }
            guard !term.isEmpty else { return true }
            return product.name.lowercased().contains(term)
                || product.summary.lowercased().contains(term)
                || product.category.displayName.lowercased().contains(term)
        }
    }

    func product(withID id: String) -> Product? {
        products.first { $0.id == id }
    }
}
