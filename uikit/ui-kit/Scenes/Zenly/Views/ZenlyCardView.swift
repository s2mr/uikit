import UIKit
import CoreMotion

final class ZenlyCardView: UIView {
    private var initialXAxis: Double?

    private let motionManager: CMMotionManager = {
        let manager = CMMotionManager()
        return manager
    }()

    private var starAdded: Bool = false

    private let highlightView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !starAdded else { return }

        highlightView.frame = CGRect(x: 0, y: frame.midY, width: frame.width, height: 20)

        var starPathes: [UIBezierPath] = []
        while starPathes.count < 30 {
            let (path, vertexes) = starVertexes(
                radius: 20,
                center: CGPoint(
                    x: CGFloat(arc4random_uniform(UInt32(frame.width))),
                    y: CGFloat(arc4random_uniform(UInt32(frame.height)))
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

        let starView = UIView(frame: bounds)
        let starLayer = CAShapeLayer()
        starLayer.frame = starView.bounds
        starLayer.path = {
            let path = UIBezierPath(rect: starLayer.bounds)
            starPathes.forEach { path.append($0) }
            path.usesEvenOddFillRule = true
            return path.cgPath
        }()
        starLayer.fillColor = UIColor.systemBlue.cgColor
        starLayer.fillRule = .evenOdd
        starView.layer.addSublayer(starLayer)

        addSubview(highlightView)
        addSubview(starView)

        starAdded = true
    }

    private func configure() {
        layer.masksToBounds = true
        layer.cornerRadius = 16

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

    private func update(xAxis rotation: Double) {
        if initialXAxis == nil {
            initialXAxis = rotation
        }
        guard let initialRotation = initialXAxis else { return }

        highlightView.center.y = center.y / 2 + center.y * CGFloat(initialRotation - rotation)
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
