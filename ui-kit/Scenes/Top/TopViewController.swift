import UIKit
import SwiftUI

final class TopViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }
}

extension TopViewController: View {
    var body: TopViewController {
        return self
    }
}

struct TopViewController_Previews: PreviewProvider {
    static var previews: some View {
        TopViewController()
    }
}
