import Foundation
import SceneKit

extension ArmillaryViewController {
    internal func createGlobeNode() -> SCNNode {
        let globeNode = SCNNode()
        let sphere = SCNSphere(radius: 1.0)
        sphere.segmentCount = 100
        globeNode.geometry = sphere

        // Use default textures for diffuse and emission
        globeNode.geometry?.firstMaterial?.diffuse.contents = nil
        globeNode.geometry?.firstMaterial?.emission.contents = nil

        globeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        globeNode.geometry?.firstMaterial?.transparency = 0.5 // Set the transparency value (0.0 to 1.0)
        globeNode.geometry?.firstMaterial?.writesToDepthBuffer = false // Allow objects behind to be visible

        // Rotate to align with Earth's coordinates
        globeNode.rotation = SCNVector4(-1, 0, 0, Float.pi/12.0)

        // Add meridians and parallels
        makeHoursMinutesAndSeconds(to: globeNode)

        return globeNode
    }
}
