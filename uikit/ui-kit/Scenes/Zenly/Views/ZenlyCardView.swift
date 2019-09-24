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
        backgroundColor = .systemBlue

        highlightView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(highlightView)
        NSLayoutConstraint.activate([
            highlightView.leftAnchor.constraint(equalTo: leftAnchor),
            highlightView.rightAnchor.constraint(equalTo: rightAnchor),
            highlightView.heightAnchor.constraint(equalToConstant: 20),
            highlightViewTopConstraint
        ])

        let xEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        xEffect.minimumRelativeValue = -30
        xEffect.maximumRelativeValue = 30
        let yEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongHorizontalAxis)
        yEffect.minimumRelativeValue = -30
        yEffect.maximumRelativeValue = 30

        let effectGroup = UIMotionEffectGroup()
        effectGroup.motionEffects = [xEffect, yEffect]
        addMotionEffect(effectGroup)

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

    override func draw(_ rect: CGRect) {
        var starPathes: [UIBezierPath] = []

        while starPathes.count < 30 {
            let (path, vertexes) = starVertexes(
                radius: 20,
                center: CGPoint(
                    x: CGFloat(arc4random_uniform(UInt32(rect.width))),
                    y: CGFloat(arc4random_uniform(UInt32(rect.height)))
                )
            )
            var contains = false
            for existsPath in starPathes {
                guard !contains else { break }
                contains = vertexes.compactMap { vertex in existsPath.contains(vertex) ? true : nil }.first ?? false
            }
            if !contains {
                starPathes.append(path)
            }
        }

        UIColor.white.withAlphaComponent(0.3).setFill()
        starPathes.forEach { path in
            path.fill()
        }
    }

    private func update(xAxis rotation: Double) {
        if initialXAxis == nil {
            initialXAxis = rotation
        }
        guard let initialRotation = initialXAxis else { return }

        highlightViewTopConstraint.constant = frame.height * CGFloat(initialRotation - rotation)
    }

    /// 星型正多角形の頂点
    ///
    /// - Parameters:
    ///   - radius: 外接円の半径
    ///   - center: 中心の座標
    ///   - roundness: 外接円と内接円の比（min:0, max:1）
    ///   - vertexes: 外接正多角形の頂点の数
    func starVertexes(
        radius: CGFloat, center: CGPoint, roundness: CGFloat = 0.5, numberOfVertexes vertexes: Int = 5
    ) -> (path: UIBezierPath, vertexes: [CGPoint]) {
        let vertexes = (vertexes * 2)
        let points = [Int](0...vertexes).map { offset -> CGPoint in
            let r = (offset % 2 == 0) ? radius : roundness * radius
            let θ = CGFloat(offset)/CGFloat(vertexes) * (2 * CGFloat.pi) - CGFloat.pi/2
            return CGPoint(x: r * cos(θ) + center.x, y: r * sin(θ) + center.y)
        }

        let path = UIBezierPath()
        path.move(to: points[0])
        points.forEach { path.addLine(to: $0) }
        path.close()

        return (path: path, vertexes: points)
    }
}
