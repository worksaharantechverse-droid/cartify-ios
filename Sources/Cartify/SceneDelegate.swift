import UIKit
import Combine

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var cancellables = Set<AnyCancellable>()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)

        let arguments = ProcessInfo.processInfo.arguments
        let isMocked = arguments.contains("-UITestMock")
        let defaults: UserDefaults = isMocked
            ? (UserDefaults(suiteName: "CartifyUITests") ?? .standard)
            : .standard
        if isMocked && arguments.contains("-UITestReset") {
            defaults.removePersistentDomain(forName: "CartifyUITests")
        }

        let catalog: any CatalogServicing = LocalCatalogService()
        let cart = CartStore(defaults: defaults)

        let shop = UINavigationController(rootViewController: ShopViewController(
            viewModel: ShopViewModel(catalog: catalog),
            store: cart,
            catalog: catalog
        ))
        shop.tabBarItem = UITabBarItem(title: "Shop", image: UIImage(systemName: "bag"), tag: 0)

        let cartNavigation = UINavigationController(rootViewController: CartViewController(
            viewModel: CartViewModel(store: cart, catalog: catalog)
        ))
        cartNavigation.tabBarItem = UITabBarItem(title: "Cart", image: UIImage(systemName: "cart"), tag: 1)

        cart.$lines
            .receive(on: DispatchQueue.main)
            .sink { [weak cartNavigation] lines in
                let count = lines.reduce(0) { $0 + $1.quantity }
                cartNavigation?.tabBarItem.badgeValue = count > 0 ? "\(count)" : nil
            }
            .store(in: &cancellables)

        let tabs = UITabBarController()
        tabs.viewControllers = [shop, cartNavigation]
        tabs.tabBar.tintColor = CartifyTheme.accent

        window.rootViewController = tabs
        window.makeKeyAndVisible()
        self.window = window
    }
}
