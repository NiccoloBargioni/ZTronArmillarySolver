import SwiftUI

struct ArmillaryVCRepresentable: UIViewControllerRepresentable {
    @State private var controller: ArmillaryViewController?
    @Binding private var sceneSize: CGSize
    @MainActor @Binding private var currentTime: Time

    @Binding private var onAngleChanged: ((CGFloat) -> Void)?
    @Binding private var onThumbReleased: (() -> Void)?
    @Binding private var onXTapped: (() -> Void)?
    @Binding private var onOTapped: (() -> Void)?
    @Binding private var onTTapped: (() -> Void)?

    init(
        currentTime: Binding<Time>,
        sceneSize: Binding<CGSize>,
        onAngleChanged: Binding<((CGFloat) -> Void)?>,
        onThumbReleased: Binding<(() -> Void)?>,
        onXTapped: Binding<(() -> Void)?>,
        onOTapped: Binding<(() -> Void)?>,
        onTTapped: Binding<(() -> Void)?>
    ) {
        self._currentTime = currentTime
        self._sceneSize = sceneSize
        self._onAngleChanged = onAngleChanged
        self._onThumbReleased = onThumbReleased
        self._onXTapped = onXTapped
        self._onOTapped = onOTapped
        self._onTTapped = onTTapped
    }

    func makeUIViewController(context: Context) -> ArmillaryViewController {
        let controller = ArmillaryViewController(currentTime: self.$currentTime, sceneSize: self.$sceneSize)

        Task(priority: .userInitiated) { @MainActor in
            self.controller = controller
            
            self.onAngleChanged = { [weak controller] angle in
                guard let controller = controller else { return }
                controller.angleChanged(to: angle)
            }
            
            self.onThumbReleased = { [weak controller] in
                guard let controller = controller else { return }
                controller.thumbReleased()
            }
            
            self.onXTapped = { [weak controller] in
                guard let controller = controller else { return }
                controller.handleBlueAnulusSelected()
            }
            
            self.onOTapped = { [weak controller] in
                guard let controller = controller else { return }
                controller.handleRedAnulusSelected()
            }
            
            self.onTTapped = { [weak controller] in
                guard let controller = controller else { return }
                controller.handleGreenAnulusSelected()
            }
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: ArmillaryViewController, context: Context) {
        Task(priority: .userInitiated) { @MainActor in
            self.controller = uiViewController

            self.onAngleChanged = { [weak uiViewController] angle in
                guard let controller = uiViewController else { return }
                controller.angleChanged(to: angle)
            }

            self.onThumbReleased = { [weak uiViewController] in
                guard let controller = uiViewController else { return }
                controller.thumbReleased()
            }

            self.onXTapped = { [weak uiViewController] in
                guard let controller = uiViewController else { return }
                controller.handleBlueAnulusSelected()
            }

            self.onOTapped = { [weak uiViewController] in
                guard let controller = uiViewController else { return }
                controller.handleRedAnulusSelected()
            }

            self.onTTapped = { [weak uiViewController] in
                guard let controller = uiViewController else { return }
                controller.handleGreenAnulusSelected()
            }
        }
    }
}
