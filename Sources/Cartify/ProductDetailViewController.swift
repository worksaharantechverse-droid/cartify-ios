import UIKit

final class ProductDetailViewController: UIViewController {
    private let product: Product
    private let store: CartStore
    private let catalog: CatalogServicing
    private let quantityLabel = UILabel()
    private let addButton = UIButton(type: .system)
    private let stepper = UIStepper()

    init(product: Product, store: CartStore, catalog: CatalogServicing) {
        self.product = product
        self.store = store
        self.catalog = catalog
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = product.name
        view.backgroundColor = CartifyTheme.background
        setupContent()
        updateQuantity()
    }

    private func setupContent() {
        let symbol = UILabel()
        symbol.text = product.symbol
        symbol.font = .systemFont(ofSize: 76)
        symbol.textAlignment = .center
        symbol.backgroundColor = CartifyTheme.accent.withAlphaComponent(0.12)
        symbol.layer.cornerRadius = 22
        symbol.clipsToBounds = true
        symbol.accessibilityIdentifier = "detail-symbol"

        let name = UILabel()
        name.text = product.name
        name.font = CartifyTheme.font(26, weight: .bold)
        name.numberOfLines = 2
        name.accessibilityIdentifier = "detail-name"

        let category = UILabel()
        category.text = "\(product.category.displayName)  ·  ★ \(String(format: "%.1f", product.rating))"
        category.font = CartifyTheme.font(14, weight: .medium)
        category.textColor = CartifyTheme.secondaryText

        let price = UILabel()
        price.text = product.formattedPrice
        price.font = CartifyTheme.font(30, weight: .bold)
        price.textColor = CartifyTheme.accent
        price.accessibilityIdentifier = "detail-price"

        let summary = UILabel()
        summary.text = product.summary
        summary.font = CartifyTheme.font(16)
        summary.textColor = CartifyTheme.secondaryText
        summary.numberOfLines = 0

        quantityLabel.font = CartifyTheme.font(17, weight: .semibold)
        quantityLabel.textAlignment = .center
        quantityLabel.accessibilityIdentifier = "detail-quantity"

        stepper.minimumValue = 0
        stepper.maximumValue = 20
        stepper.stepValue = 1
        stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
        stepper.accessibilityIdentifier = "detail-stepper"

        let quantityRow = UIStackView(arrangedSubviews: [quantityLabel, stepper])
        quantityRow.axis = .horizontal
        quantityRow.spacing = 16
        quantityRow.alignment = .center

        addButton.setTitle("Add to cart", for: .normal)
        addButton.titleLabel?.font = CartifyTheme.font(17, weight: .semibold)
        addButton.backgroundColor = CartifyTheme.accent
        addButton.tintColor = .white
        addButton.layer.cornerRadius = 12
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addButton.accessibilityIdentifier = "detail-add"

        let stack = UIStackView(arrangedSubviews: [symbol, name, category, price, summary, quantityRow, addButton])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            symbol.heightAnchor.constraint(equalToConstant: 140),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func updateQuantity() {
        let quantity = store.quantity(for: product.id)
        stepper.value = Double(quantity)
        quantityLabel.text = "\(quantity) in cart"
        addButton.setTitle(quantity == 0 ? "Add to cart" : "Add one more", for: .normal)
    }

    @objc private func stepperChanged() {
        store.setQuantity(productID: product.id, quantity: Int(stepper.value))
        updateQuantity()
    }

    @objc private func addTapped() {
        store.add(product: product)
        updateQuantity()
        let alert = UIAlertController(title: "Added to cart", message: "\(product.name) is in your cart.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
