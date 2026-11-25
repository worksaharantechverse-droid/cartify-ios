import UIKit

enum CartifyTheme {
    static let accent = UIColor.systemOrange
    static let background = UIColor.systemBackground
    static let surface = UIColor.secondarySystemBackground
    static let text = UIColor.label
    static let secondaryText = UIColor.secondaryLabel

    static func font(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: weight)
    }
}
