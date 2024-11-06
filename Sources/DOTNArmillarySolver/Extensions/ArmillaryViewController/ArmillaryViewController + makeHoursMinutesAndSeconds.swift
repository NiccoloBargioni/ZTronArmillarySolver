import Foundation
import SceneKit

extension ArmillaryViewController {
    // swiftlint:disable identifier_name
    internal func makeHoursMinutesAndSeconds(to globeNode: SCNNode) {
        let mirrorRadius: CGFloat = 0.08

        let hoursNode = createCircleNode(radius: 1.0)
        hoursNode.name = "hours"

        let hoursMirrorGeometry = SCNSphere(radius: mirrorRadius)
        let hoursMirrorNode = SCNNode(geometry: hoursMirrorGeometry)
        hoursMirrorNode.localTranslate(by: SCNVector3(x: -0.5, y: 0, z: sqrt(3)/2.0))
        hoursMirrorGeometry.firstMaterial?.diffuse.contents = UIImage(named: "blueTexture")
        hoursNode.addChildNode(hoursMirrorNode)

        hoursNode.simdOrientation = simd_quatf(angle: Float.pi/2.0, axis: SIMD3<Float>(-1, 0, 0))

        let minutesNode = createCircleNode(radius: 1.1)
        minutesNode.eulerAngles.z = Float.pi / 2.0
        minutesNode.eulerAngles.y = 0
        minutesNode.eulerAngles.x = Float.pi / 2.0
        minutesNode.name = "minutes"

        let minutesMirrorGeometry = SCNSphere(radius: mirrorRadius)
        let minutesMirrorNode = SCNNode(geometry: minutesMirrorGeometry)
        minutesMirrorNode.localTranslate(by: SCNVector3(x: 1.1, y: 0, z: 0))
        minutesMirrorGeometry.firstMaterial?.diffuse.contents = UIImage(named: "greenTexture")
        minutesNode.addChildNode(minutesMirrorNode)

        let secondsNode = createCircleNode(radius: 1.2)
        secondsNode.name = "seconds"

        let secondsMirrorGeometry = SCNSphere(radius: mirrorRadius)
        let secondsMirrorNode = SCNNode(geometry: secondsMirrorGeometry)
        secondsMirrorNode.localTranslate(by: SCNVector3(x: 0.0, y: 0, z: 1.2))
        secondsMirrorGeometry.firstMaterial?.diffuse.contents = UIImage(named: "redTexture")
        secondsNode.addChildNode(secondsMirrorNode)

        secondsNode.simdOrientation = simd_quatf(angle: Float.pi/2.0, axis: SIMD3<Float>(-1, 0, 0))

        let equatorNode = createCircleNode(radius: 1.4)
        equatorNode.eulerAngles.z = 0
        equatorNode.eulerAngles.x = 0

        let meridianNode = createCircleNode(radius: 1.35)
        meridianNode.eulerAngles.z = Float.pi / 2.0
        meridianNode.eulerAngles.y = 0
        meridianNode.eulerAngles.x = Float.pi / 2.0

        globeNode.addChildNode(hoursNode)
        globeNode.addChildNode(minutesNode)
        globeNode.addChildNode(secondsNode)
        globeNode.addChildNode(equatorNode)
        globeNode.addChildNode(meridianNode)

        hoursNode.runAction(
            SCNAction.rotateBy(
                x: (CGFloat.pi/6.0)*CGFloat(currentTime.wrappedValue.getHour()),
                y: 0,
                z: 0,
                duration: 0
            )
        )

        minutesNode.runAction(
            SCNAction.rotateBy(
                x: 0,
                y: 0,
                z: -(CGFloat.pi/6.0)*(CGFloat(currentTime.wrappedValue.getMinute())/5.0),
                duration: 0
            )
        )

        secondsNode.runAction(
            SCNAction.rotateBy(
                x: (CGFloat.pi/6.0)*(CGFloat(currentTime.wrappedValue.getSecond())/5.0),
                y: 0,
                z: 0,
                duration: 0
            )
        )
    }

    private func createCircleNode(radius: Float) -> SCNNode {
        let circleGeometry = SCNTorus(
            ringRadius: CGFloat(radius),
            pipeRadius: radius <= 1.2 ? 0.025 : 0.05
        )
        let circleNode = SCNNode(geometry: circleGeometry)

        if radius <= 1.2 {
            circleNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 27.0/255.0, green: 63.0/255.0, blue: 72.0/255.0, alpha: 1.0)
        } else {
            circleNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "iron")
        }
        return circleNode
    }
}
