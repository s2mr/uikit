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
        view.backgroundColor = #colorLiteral(red: 0.568627451, green: 0.9019607843, blue: 1, alpha: 1)
        view.layer.masksToBounds = false
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
        while starPathes.count < 100 {
            let (path, vertexes): (path: UIBezierPath, vertexes: [CGPoint]) = {
                let x: CGFloat = .random(in: 0...frame.width)
                let y: CGFloat = .random(in: 0...frame.height)
                let width = CGFloat.random(in: 5...30)
                let height = CGFloat.random(in: 5...30)
                switch starPathes.count % 3 {
                case 0:
                    return UIBezierPath.star(
                        center: CGPoint(x: x, y: y),
                        radius: width
                    )
                case 1:
                    return UIBezierPath.rectangle(
                        rect: CGRect(x: x, y: y, width: width, height: height)
                    )
                default:
                    return UIBezierPath.circle(origin: CGPoint(x: x, y: y), radius: width)
                }
            }()
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
        starLayer.fillColor = #colorLiteral(red: 0.007843137255, green: 0.7607843137, blue: 1, alpha: 1)
        starLayer.fillRule = .evenOdd
        starView.layer.addSublayer(starLayer)

        addSubview(highlightView)
        addSubview(starView)

        starAdded = true
    }

    private func configure() {
        layer.masksToBounds = true
        layer.cornerRadius = 16
        backgroundColor = #colorLiteral(red: 0.3176470588, green: 0.8431372549, blue: 1, alpha: 1)

        let xEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        xEffect.minimumRelativeValue = -30
        xEffect.maximumRelativeValue = 30
        let yEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        yEffect.minimumRelativeValue = -60
        yEffect.maximumRelativeValue = 60

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
}

private extension UIBezierPath {
    static func star(center: CGPoint, radius: CGFloat) -> (path: UIBezierPath, vertexes: [CGPoint]) {
        let roundness: CGFloat = 0.5
        let vertexes = 5 * 2
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

    static func rectangle(rect: CGRect) -> (path: UIBezierPath, vertexes: [CGPoint]) {
        let path = UIBezierPath(rect: rect)
        return (
            path: path,
            vertexes: [
                .init(x: rect.minX, y: rect.minY),
                .init(x: rect.maxX, y: rect.minY),
                .init(x: rect.maxX, y: rect.maxY),
                .init(x: rect.minX, y: rect.maxY)
            ]
        )
    }

    static func circle(origin: CGPoint, radius: CGFloat) -> (path: UIBezierPath, vertexes: [CGPoint]) {
        let path = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: radius/2, height: radius/2)))
        return (
            path: path,
            vertexes: [
                .init(x: origin.x + radius, y: origin.y),
                .init(x: origin.x + 2 * radius, y: origin.y + radius),
                .init(x: origin.x + radius, y: origin.y + 2 * radius),
                .init(x: origin.x, y: origin.y * radius)
            ]
        )
    }
}
