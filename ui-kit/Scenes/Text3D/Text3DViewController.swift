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

        boxNode.addChildNode(textNode)

//        scene.rootNode.addChildNode(textNode)

        let scene = SCNScene()
        scene.rootNode.addChildNode(boxNode)

        scnView.scene = scene
        scnView.camera
        scnView.allowsCameraControl = true
    }
}
