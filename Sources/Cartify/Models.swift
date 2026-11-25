import Foundation

enum ProductCategory: String, CaseIterable, Codable {
    case electronics
    case home
    case fashion
    case audio
    case fitness

    var displayName: String {
        switch self {
        case .electronics: return "Electronics"
        case .home: return "Home"
        case .fashion: return "Fashion"
        case .audio: return "Audio"
        case .fitness: return "Fitness"
        }
    }
}

struct Product: Identifiable, Equatable, Codable {
    let id: String
    let name: String
    let category: ProductCategory
    let price: Double
    let summary: String
    let symbol: String
    let rating: Double

    var formattedPrice: String { Money.string(price) }
}

struct CartLine: Equatable, Codable {
    let productID: String
    var quantity: Int
}

struct CartItem: Equatable {
    let product: Product
    let quantity: Int

    var lineTotal: Double { product.price * Double(quantity) }
}

struct OrderTotals: Equatable {
    let subtotal: Double
    let discount: Double
    let total: Double
    let itemCount: Int
}

struct OrderConfirmation: Equatable {
    let number: String
    let total: Double
    let itemCount: Int
}

enum PromoCode: String, CaseIterable {
    case save10 = "SAVE10"

    var discountRate: Double { 0.10 }

    static func match(_ value: String) -> PromoCode? {
        PromoCode(rawValue: value.trimmingCharacters(in: .whitespacesAndNewlines).uppercased())
    }
}

enum Money {
    static func string(_ value: Double) -> String {
        String(format: "$%.2f", value)
    }

    static func rounded(_ value: Double) -> Double {
        (value * 100).rounded() / 100
    }
}
