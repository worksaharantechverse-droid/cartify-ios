import Foundation
import Combine

final class ShopViewModel: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published var selectedCategory: ProductCategory? {
        didSet { applyFilter() }
    }
    @Published var query: String = "" {
        didSet { applyFilter() }
    }

    private let catalog: CatalogServicing

    init(catalog: CatalogServicing) {
        self.catalog = catalog
        self.products = catalog.products
    }

    var categories: [ProductCategory] { catalog.categories }

    func applyFilter() {
        products = catalog.filtered(category: selectedCategory, query: query)
    }
}
