import UIKit
import SceneKit

final class Text3DViewController: UIViewController {
    lazy var scnView = SCNView(frame: view.bounds)

    override func viewDidLoad() {
        view.addSubview(scnView)
        let text = SCNText(string: "Text", extrusionDepth: 3.0)
        let textMaterial = SCNMaterial()
        textMaterial.diffuse.contents = UIColor.red
        text.materials = [textMaterial]
        let textNode = SCNNode(geometry: text)
        textNode.scale = .init(0.01, 0.01, 0.01)

        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = UIColor.green
        box.materials = [boxMaterial]
        let boxNode = SCNNode(geometry: box)

//        boxNode.addChildNode(textNode)

        let camera = SCNCamera()

        UIView.animate(withDuration: 30) {
            camera.zFar = 1000
        }
//        boxNode.camera = camera


        let scene = SCNScene()
        scene.rootNode.addChildNode(textNode)
//        scene.rootNode.addChildNode(boxNode)

        scene.rootNode.camera = camera

        scnView.scene = scene
        scnView.allowsCameraControl = true
//        scnView.defaultCameraController.roll(by: 10, aroundScreenPoint: .init(x: 30, y: 30), viewport: .init(width: 100, height: 20))
//        scnView
    }
}
