import UIKit
import Combine

final class CartViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()
    private let footer = UIView()
    private let promoField = UITextField()
    private let applyButton = UIButton(type: .system)
    private let promoStatusLabel = UILabel()
    private let subtotalLabel = UILabel()
    private let discountLabel = UILabel()
    private let totalLabel = UILabel()
    private let checkoutButton = UIButton(type: .system)
    private let viewModel: CartViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: CartViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cart"
        view.backgroundColor = CartifyTheme.background
        setupTable()
        setupFooter()
        setupEmptyState()
        bind()
        render()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeFooter()
    }

    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.rowHeight = 78
        tableView.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.reuseID)
        tableView.accessibilityIdentifier = "cart-table"
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupFooter() {
        promoField.placeholder = "Promo code"
        promoField.borderStyle = .roundedRect
        promoField.autocapitalizationType = .allCharacters
        promoField.autocorrectionType = .no
        promoField.returnKeyType = .done
        promoField.delegate = self
        promoField.accessibilityIdentifier = "promo-field"

        applyButton.setTitle("Apply", for: .normal)
        applyButton.titleLabel?.font = CartifyTheme.font(15, weight: .semibold)
        applyButton.addTarget(self, action: #selector(applyPromoTapped), for: .touchUpInside)
        applyButton.accessibilityIdentifier = "apply-promo"

        let promoRow = UIStackView(arrangedSubviews: [promoField, applyButton])
        promoRow.axis = .horizontal
        promoRow.spacing = 10

        promoStatusLabel.font = CartifyTheme.font(13, weight: .medium)
        promoStatusLabel.textColor = CartifyTheme.secondaryText
        promoStatusLabel.accessibilityIdentifier = "promo-status"

        subtotalLabel.accessibilityIdentifier = "subtotal-value"
        discountLabel.accessibilityIdentifier = "discount-value"
        totalLabel.accessibilityIdentifier = "total-value"
        totalLabel.font = CartifyTheme.font(18, weight: .bold)
        totalLabel.textColor = CartifyTheme.accent

        let subtotalRow = summaryRow(title: "Subtotal", value: subtotalLabel)
        let discountRow = summaryRow(title: "Discount", value: discountLabel)
        let totalRow = summaryRow(title: "Total", value: totalLabel)

        checkoutButton.setTitle("Checkout", for: .normal)
        checkoutButton.titleLabel?.font = CartifyTheme.font(17, weight: .semibold)
        checkoutButton.backgroundColor = CartifyTheme.accent
        checkoutButton.tintColor = .white
        checkoutButton.layer.cornerRadius = 12
        checkoutButton.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        checkoutButton.accessibilityIdentifier = "checkout-button"

        let stack = UIStackView(arrangedSubviews: [promoRow, promoStatusLabel, subtotalRow, discountRow, totalRow, checkoutButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        footer.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: footer.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: footer.bottomAnchor, constant: -20),
            checkoutButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        tableView.tableFooterView = footer
    }

    private func summaryRow(title: String, value: UILabel) -> UIStackView {
        let label = UILabel()
        label.text = title
        label.font = CartifyTheme.font(15, weight: .medium)
        label.textColor = CartifyTheme.secondaryText
        value.font = CartifyTheme.font(15, weight: .semibold)
        value.textAlignment = .right
        let row = UIStackView(arrangedSubviews: [label, value])
        row.axis = .horizontal
        return row
    }

    private func sizeFooter() {
        footer.layoutIfNeeded()
        let fitting = footer.systemLayoutSizeFitting(
            CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        var frame = footer.frame
        frame.size.height = fitting.height
        footer.frame = frame
        tableView.tableFooterView = footer
    }

    private func setupEmptyState() {
        emptyLabel.text = "Your cart is empty. Add something from Shop."
        emptyLabel.font = CartifyTheme.font(15, weight: .medium)
        emptyLabel.textColor = CartifyTheme.secondaryText
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.isHidden = true
        emptyLabel.accessibilityIdentifier = "cart-empty"
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    private func bind() {
        viewModel.storeDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.render() }
            .store(in: &cancellables)
    }

    private func render() {
        let totals = viewModel.totals
        tableView.reloadData()
        emptyLabel.isHidden = !viewModel.items.isEmpty
        if promoField.text?.isEmpty ?? true {
            promoField.text = viewModel.appliedPromo?.rawValue
        }
        promoStatusLabel.text = viewModel.appliedPromo == nil ? "Use SAVE10 for 10% off your order." : "SAVE10 applied — 10% off."
        subtotalLabel.text = Money.string(totals.subtotal)
        discountLabel.text = "-\(Money.string(totals.discount))"
        totalLabel.text = Money.string(totals.total)
        checkoutButton.isEnabled = totals.itemCount > 0
        sizeFooter()
    }

    @objc private func applyPromoTapped() {
        view.endEditing(true)
        let accepted = viewModel.applyPromo(promoField.text ?? "")
        render()
        promoStatusLabel.text = accepted ? "SAVE10 applied — 10% off." : "Invalid code. Try SAVE10."
    }

    @objc private func checkoutTapped() {
        let confirmation = viewModel.checkout()
        promoField.text = nil
        let alert = UIAlertController(
            title: "Order Placed",
            message: "Confirmation \(confirmation.number)\nTotal \(Money.string(confirmation.total)) for \(confirmation.itemCount) item(s).",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Done", style: .default))
        present(alert, animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CartItemCell.reuseID, for: indexPath) as! CartItemCell
        let item = viewModel.items[indexPath.row]
        cell.configure(item: item) { [weak self] quantity in
            self?.viewModel.setQuantity(productID: item.product.id, quantity: quantity)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let item = viewModel.items[indexPath.row]
        viewModel.setQuantity(productID: item.product.id, quantity: 0)
    }
}
