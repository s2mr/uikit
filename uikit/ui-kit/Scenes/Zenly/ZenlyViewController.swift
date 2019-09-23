import UIKit
import SwiftUI

final class ZenlyViewController: UIViewController {
    private let cardView = ZenlyCardView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            cardView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2/3)
        ])
    }
}

extension ZenlyViewController: View {
    var body: ZenlyViewController {
        return self
    }
}

struct ZenlyViewController_Previews: PreviewProvider {
    static var previews: some View {
        ZenlyViewController()
    }
}
