import UIKit

final class ProductCell: UICollectionViewCell {
    static let reuseID = "ProductCell"

    private let symbolLabel = UILabel()
    private let nameLabel = UILabel()
    private let categoryLabel = UILabel()
    private let priceLabel = UILabel()
    private let addButton = UIButton(type: .system)
    private var addAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = CartifyTheme.surface
        contentView.layer.cornerRadius = 16
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        addAction = nil
    }

    private func setupViews() {
        symbolLabel.font = .systemFont(ofSize: 34)
        symbolLabel.textAlignment = .center
        symbolLabel.backgroundColor = CartifyTheme.accent.withAlphaComponent(0.14)
        symbolLabel.layer.cornerRadius = 14
        symbolLabel.clipsToBounds = true

        nameLabel.font = CartifyTheme.font(14, weight: .semibold)
        nameLabel.textColor = CartifyTheme.text
        nameLabel.numberOfLines = 2

        categoryLabel.font = CartifyTheme.font(12, weight: .medium)
        categoryLabel.textColor = CartifyTheme.secondaryText

        priceLabel.font = CartifyTheme.font(16, weight: .bold)
        priceLabel.textColor = CartifyTheme.accent

        addButton.setTitle("Add", for: .normal)
        addButton.titleLabel?.font = CartifyTheme.font(13, weight: .semibold)
        addButton.backgroundColor = CartifyTheme.accent
        addButton.tintColor = .white
        addButton.layer.cornerRadius = 10
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addButton.accessibilityIdentifier = "add-button"

        let stack = UIStackView(arrangedSubviews: [symbolLabel, nameLabel, categoryLabel, priceLabel, addButton])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            symbolLabel.heightAnchor.constraint(equalToConstant: 72),
            addButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    func configure(product: Product, quantity: Int, add: @escaping () -> Void) {
        symbolLabel.text = product.symbol
        nameLabel.text = product.name
        categoryLabel.text = product.category.displayName
        priceLabel.text = product.formattedPrice
        addButton.setTitle(quantity > 0 ? "Add (\(quantity) in cart)" : "Add to cart", for: .normal)
        addAction = add
        accessibilityIdentifier = "product-cell-\(product.id)"
        nameLabel.accessibilityIdentifier = "product-name-\(product.id)"
        addButton.accessibilityIdentifier = "add-\(product.id)"
    }

    @objc private func addTapped() { addAction?() }
}
