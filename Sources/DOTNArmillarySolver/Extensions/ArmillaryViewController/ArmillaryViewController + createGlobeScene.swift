import Foundation
import SceneKit.ModelIO

extension ArmillaryViewController {

    internal func createGlobeScene() -> SCNScene {
        let scene = SCNScene()

        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: -0.1, z: 3) // Adjust the z-coordinate to move the camera back

        scene.rootNode.addChildNode(cameraNode)

        scene.background.contents = UIColor.clear

        let globeNode = createGlobeNode()
        globeNode.name = "globe"

        guard let url = Bundle.module.url(
         forResource: "uploads_files_4779603_DIAMOND",
         withExtension: "usdz"
        )
        else { fatalError("Failed to find model file.") }

        let diamondModel = MDLAsset(url: url)
        diamondModel.loadTextures()

        let asset = diamondModel.object(at: 0) // extract first object
        let node = SCNNode(mdlObject: asset)

        let upsideDownNode = SCNNode(mdlObject: asset)

        for children in node.childNodes {
            children.scale = SCNVector3(x: 0.0025, y: 0.005, z: 0.0025)
        }

        for children in upsideDownNode.childNodes {
            children.scale = SCNVector3(x: 0.0025, y: 0.005, z: 0.0025)
        }

        let diamondNode = SCNNode()
        diamondNode.position = SCNVector3(x: 0, y: 0, z: 0)
        diamondNode.simdOrientation = simd_quatf(angle: Float.pi/6.0, axis: SIMD3(0, 0, 1))

        node.position = SCNVector3(x: 0.0, y: 0, z: 0)
        node.localTranslate(by: SCNVector3(0, -0.5, 0))

        upsideDownNode.position = SCNVector3(x: 0, y: 0, z: 0)
        upsideDownNode.rotation = SCNVector4(0, 0, 1, Float.pi)
        upsideDownNode.localTranslate(by: SCNVector3(x: 0.1, y: -0.5, z: 0))

        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor(white: 0.5, alpha: 1.0) // Adjust the color and intensity as needed

        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)

        diamondNode.addChildNode(upsideDownNode)
        diamondNode.addChildNode(node)
        globeNode.addChildNode(diamondNode)
        scene.rootNode.addChildNode(globeNode)

        return scene
    }
}
