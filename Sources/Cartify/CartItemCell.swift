import UIKit

final class CartItemCell: UITableViewCell {
    static let reuseID = "CartItemCell"

    private let symbolLabel = UILabel()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let quantityLabel = UILabel()
    private let stepper = UIStepper()
    private var quantityAction: ((Int) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        quantityAction = nil
    }

    private func setupViews() {
        symbolLabel.font = .systemFont(ofSize: 30)
        symbolLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true

        nameLabel.font = CartifyTheme.font(15, weight: .semibold)
        nameLabel.textColor = CartifyTheme.text

        priceLabel.font = CartifyTheme.font(13, weight: .medium)
        priceLabel.textColor = CartifyTheme.secondaryText

        quantityLabel.font = CartifyTheme.font(15, weight: .semibold)
        quantityLabel.textAlignment = .center
        quantityLabel.widthAnchor.constraint(equalToConstant: 28).isActive = true

        stepper.minimumValue = 0
        stepper.maximumValue = 20
        stepper.stepValue = 1
        stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)

        let details = UIStackView(arrangedSubviews: [nameLabel, priceLabel])
        details.axis = .vertical
        details.spacing = 4

        let controls = UIStackView(arrangedSubviews: [quantityLabel, stepper])
        controls.axis = .horizontal
        controls.spacing = 8
        controls.alignment = .center

        let row = UIStackView(arrangedSubviews: [symbolLabel, details, controls])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    func configure(item: CartItem, quantityChanged: @escaping (Int) -> Void) {
        symbolLabel.text = item.product.symbol
        nameLabel.text = item.product.name
        priceLabel.text = "\(item.product.formattedPrice) each  ·  \(Money.string(item.lineTotal))"
        quantityLabel.text = "\(item.quantity)"
        stepper.value = Double(item.quantity)
        quantityAction = quantityChanged
        accessibilityIdentifier = "cart-row-\(item.product.id)"
        nameLabel.accessibilityIdentifier = "cart-item-name-\(item.product.id)"
        quantityLabel.accessibilityIdentifier = "quantity-\(item.product.id)"
        stepper.accessibilityIdentifier = "stepper-\(item.product.id)"
    }

    @objc private func stepperChanged() {
        quantityAction?(Int(stepper.value))
    }
}
