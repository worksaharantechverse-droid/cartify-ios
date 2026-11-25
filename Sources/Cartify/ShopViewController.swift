import UIKit
import Combine

final class ShopViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchResultsUpdating {
    private let collectionView: UICollectionView
    private let viewModel: ShopViewModel
    private let store: CartStore
    private let catalog: CatalogServicing
    private let searchController = UISearchController(searchResultsController: nil)
    private let emptyLabel = UILabel()
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: ShopViewModel, store: CartStore, catalog: CatalogServicing) {
        self.viewModel = viewModel
        self.store = store
        self.catalog = catalog
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 14
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Shop"
        view.backgroundColor = CartifyTheme.background
        setupSearch()
        setupFilter()
        setupCollection()
        setupEmptyState()
        bind()
        render()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search products"
        searchController.searchBar.accessibilityIdentifier = "product-search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func setupFilter() {
        let button = UIBarButtonItem(title: "Category: All", style: .plain, target: self, action: #selector(showCategories))
        button.accessibilityIdentifier = "category-filter"
        navigationItem.rightBarButtonItem = button
    }

    private func setupCollection() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.reuseID)
        collectionView.accessibilityIdentifier = "product-grid"
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupEmptyState() {
        emptyLabel.text = "No products match your filters."
        emptyLabel.font = CartifyTheme.font(15, weight: .medium)
        emptyLabel.textColor = CartifyTheme.secondaryText
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        emptyLabel.accessibilityIdentifier = "shop-empty"
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func bind() {
        viewModel.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.render() }
            .store(in: &cancellables)
    }

    private func render() {
        collectionView.reloadData()
        emptyLabel.isHidden = !viewModel.products.isEmpty
        navigationItem.rightBarButtonItem?.title = "Category: \(viewModel.selectedCategory?.displayName ?? "All")"
    }

    @objc private func showCategories() {
        let sheet = UIAlertController(title: "Choose a category", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "All", style: .default) { [weak self] _ in
            self?.viewModel.selectedCategory = nil
        })
        for category in viewModel.categories {
            sheet.addAction(UIAlertAction(title: category.displayName, style: .default) { [weak self] _ in
                self?.viewModel.selectedCategory = category
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(sheet, animated: true)
    }

    func updateSearchResults(for searchController: UISearchController) {
        viewModel.query = searchController.searchBar.text ?? ""
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCell.reuseID, for: indexPath) as! ProductCell
        let product = viewModel.products[indexPath.item]
        cell.configure(product: product, quantity: store.quantity(for: product.id)) { [weak self] in
            guard let self else { return }
            store.add(product: product)
            collectionView.reloadItems(at: [indexPath])
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = viewModel.products[indexPath.item]
        let detail = ProductDetailViewController(product: product, store: store, catalog: catalog)
        navigationController?.pushViewController(detail, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = traitCollection.horizontalSizeClass == .regular ? 3 : 2
        let spacing: CGFloat = 12
        let insets: CGFloat = 32
        let width = (collectionView.bounds.width - insets - spacing * (columns - 1)) / columns
        return CGSize(width: width, height: 228)
    }
}
