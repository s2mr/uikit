import UIKit

final class ZenlyCardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        layer.masksToBounds = true
        layer.cornerRadius = 16
        backgroundColor = .blue
    }
}
