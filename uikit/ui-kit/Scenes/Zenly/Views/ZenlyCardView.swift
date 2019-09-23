import UIKit
import CoreMotion

final class ZenlyCardView: UIView {
    private var initialXAxis: Double?
    private let motionManager: CMMotionManager = {
        let manager = CMMotionManager()
        return manager
    }()

    private let highlightView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private lazy var highlightViewTopConstraint = highlightView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0)

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

        highlightView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(highlightView)
        NSLayoutConstraint.activate([
            highlightView.leftAnchor.constraint(equalTo: leftAnchor),
            highlightView.rightAnchor.constraint(equalTo: rightAnchor),
            highlightView.heightAnchor.constraint(equalToConstant: 10),
            highlightViewTopConstraint
        ])

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
            guard let data = data else {
                if let error = error {
                    print(error)
                }
                return
            }
            self?.update(xAxis: data.attitude.pitch)
        }
    }

    private func update(xAxis rotation: Double) {
        if initialXAxis == nil {
            initialXAxis = rotation
        }
        guard let initialRotation = initialXAxis else { return }

        print(rotation)
        highlightViewTopConstraint.constant = frame.height * CGFloat(initialRotation - rotation)
    }
}
