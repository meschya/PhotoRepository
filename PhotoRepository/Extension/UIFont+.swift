import UIKit

enum FontWeight: String {
    case black = "BrutaProCompressed-Black"
    case bold = "BrutaProCompressed-Bold"
    case extraBold = "BrutaProCompressed-ExtraBold"
    case extraLight = "BrutaProCompressed-ExtraLight"
    case light = "BrutaProCompressed-Light"
    case regular = "BrutaProCompressed-Regular"
    case thin = "BrutaProCompressed-Thin"
}

extension UIFont {
    static func bruta(_ size: CGFloat, _ weight: FontWeight) -> UIFont {
        UIFont(name: weight.rawValue, size: size)!
    }
}
