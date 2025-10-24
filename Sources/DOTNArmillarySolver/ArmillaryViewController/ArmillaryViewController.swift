//
//  ArmillaryViewController.swift
//  ArmillarySwiftUI
//
//  Created by Niccolò Della Rocca on 03/11/24.
//

import SceneKit
import SnapKit
import SwiftUI

class ArmillaryViewController: UIViewController {
    internal var sceneSize: Binding<CGSize>
    internal var currentTime: Binding<Time>

    internal var lastRightThumbstickAngle: CGFloat = .zero
    private var lastPanAngle: CGFloat = .zero

    internal var selectedAnulus: SelectedAnulus = .blue

    internal var scene: SCNScene?
    weak internal var sceneView: UIView?

    init(currentTime: Binding<Time>, sceneSize: Binding<CGSize>, scene: SCNScene? = nil) {
        assert(currentTime.wrappedValue.getMinute() % 5 == 0 && currentTime.wrappedValue.getSecond() % 5 == 0)
        assert(
            currentTime.wrappedValue.getHour() > 0 &&
            currentTime.wrappedValue.getMinute() >= 0 &&
            currentTime.wrappedValue.getSecond() >= 0
        )

        self.currentTime = currentTime

        self.scene = scene
        self.sceneSize = sceneSize

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.currentTime = Binding<Time>(projectedValue: .constant(Time(hour: 9, minute: 45, second: 45)))

        self.sceneSize = Binding<CGSize>.constant(.zero)
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let wallView = UIView()
        
        wallView.backgroundColor = UIColor(patternImage: UIImage(named: "brick", in: .module, with: nil)!)
        self.view.addSubview(wallView)
        
        wallView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
        }

        let sceneView = SCNView()
        sceneView.backgroundColor = .clear
        sceneView.scene = createGlobeScene()
        sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = true

        self.view.addSubview(sceneView)
                
        sceneView.dropShadow()

        sceneView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:))))

        sceneView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.height.equalTo(self.view.safeAreaLayoutGuide.snp.height)
        }

        self.scene = sceneView.scene!
        self.sceneView = sceneView
    }

    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let scene = scene else { return }
        guard let globe = getNodeByID("globe", inScene: scene) else { return }

        switch gestureRecognizer.state {
        case .began, .changed:

            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {

                let translation = gestureRecognizer.translation(in: self.view)
                let rotationAngle = (0...2*Float.pi).lerp(Float(translation.x/self.view.bounds.size.width))

                let rotationQuaternion = simd_quatf(angle: rotationAngle - Float(lastPanAngle), axis: SIMD3(0, 1, 0))

                globe.simdOrientation *= rotationQuaternion
                self.lastPanAngle = CGFloat(rotationAngle)
            }

        case .ended, .cancelled, .failed:
            self.lastPanAngle = .zero
            let rotateBackAction = SCNAction.rotateTo(
                x: -CGFloat(Float.pi)/12.0,
                y: 0,
                z: 0,
                duration: 0.25,
                usesShortestUnitArc: true
            )

            globe.runAction(rotateBackAction)

        default:
            break
        }

    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        self.sceneSize.wrappedValue = CGSize(width: size.width, height: size.height)
        self.sceneView?.snp.remakeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.height.equalTo(size.height*0.4)
        }

        coordinator.animate(alongsideTransition: nil) { _ in
            self.view.layoutIfNeeded()
        }
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        Task(priority: .userInitiated) {
            self.sceneSize.wrappedValue = CGSize(
                width: self.sceneView?.bounds.size.width ?? self.view.bounds.size.width,
                height: self.sceneView?.bounds.size.height ?? self.view.bounds.size.height

            )
            
        }
    }

    func getNodeByID(_ id: String, inScene scene: SCNScene) -> SCNNode? {
        return scene.rootNode.childNode(withName: id, recursively: true)
    }

    @objc internal func handleBlueAnulusSelected() {
        self.selectedAnulus = .blue
    }

    @objc internal func handleGreenAnulusSelected() {
        self.selectedAnulus = .green
    }

    @objc internal func handleRedAnulusSelected() {
        self.selectedAnulus = .red
    }
}

internal enum SelectedAnulus {
    case red
    case green
    case blue
}
