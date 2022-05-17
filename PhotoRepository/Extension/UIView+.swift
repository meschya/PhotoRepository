import UIKit

extension UIView {
    func addSubviews(_ view: UIView...) {
        view.forEach(addSubview)
    }
    
    func addShadow() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 8
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 5
    }
}
