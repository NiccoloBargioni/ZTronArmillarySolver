import Foundation
import SceneKit

extension ArmillaryViewController {

    internal func angleChanged(to angleDeg: CGFloat) {
        // FIXME: Restart from here
        guard let scene = self.scene else { return }
        guard let hours = getNodeByID("hours", inScene: scene),
                let minutes = getNodeByID("minutes", inScene: scene),
                let seconds = getNodeByID("seconds", inScene: scene) else { return }

        let angleRadians = angleDeg.toRadians()
        self.lastRightThumbstickAngle = angleRadians

        if self.selectedAnulus == .blue {
            hours.rotation = SCNVector4(-1, 0, 0, angleRadians)

            let hour = (Int(round(hours.eulerAngles.x.toDegrees()/30.0) + 3) + 12) % 12
            currentTime.wrappedValue.setHour(hour > 0 ? hour : 12)
        } else {
            if self.selectedAnulus == .green {
                minutes.eulerAngles.z = Float(angleRadians)

                currentTime.wrappedValue.setMinute(
                    (
                        (
                            Int(-round((minutes.eulerAngles.z).toDegrees()/30.0) + 3) + 12
                        ) % 12
                    )*5
                )
            } else {
                seconds.rotation = SCNVector4(-1, 0, 0, angleRadians)

                currentTime.wrappedValue.setSecond(
                    (
                        (Int(round(seconds .eulerAngles.x.toDegrees()/30.0) + 3) + 12) % 12
                    )*5
                )
            }
        }
    }

    internal func thumbReleased() {
        if self.selectedAnulus == .blue {
            thumbReleasedOnBlue()
        } else {
            if self.selectedAnulus == .green {
                thumbReleasedOnGreen()
            } else {
                thumbReleasedOnRed()
            }
        }
    }

    private func thumbReleasedOnBlue() {
        guard let scene = self.scene else { return }
        guard let hours = getNodeByID("hours", inScene: scene) else { return }

        let targetHour = (Int(round(hours.eulerAngles.x.toDegrees()/30.0) + 3) + 12) % 12
        var targetAngleForHour = Int(-(CGFloat(targetHour-3)/12.0)*360.0 + 360) % 360

        if lastRightThumbstickAngle.toDegrees() >= 180 {
            targetAngleForHour -= 360
        }

        if targetAngleForHour == -360 && self.lastRightThumbstickAngle.toDegrees() > 330 {
            targetAngleForHour = 0
        }

        let action = SCNAction.rotateTo(x: -targetAngleForHour.toRadians(), y: 0, z: 0, duration: 0.25)
        hours.runAction(action) { @Sendable in
            let hour = targetHour
            Task(priority: .userInitiated) { @MainActor in
                self.currentTime.wrappedValue.setHour(hour > 0 ? hour : 12)
            }
        }
    }

    private func thumbReleasedOnGreen() {
        guard let scene = self.scene else { return }
        guard let minutes = getNodeByID("minutes", inScene: scene) else { return }

        let targetMinute = ((Int(-round((minutes.eulerAngles.z).toDegrees()/30.0) + 3) + 12) % 12)*5
        var targetAngleForMinute = (Int(-(CGFloat(targetMinute-15)/60.0)*360.0) + 360) % 360

        if targetAngleForMinute == 0 && self.lastRightThumbstickAngle.toDegrees() > 330 {
            targetAngleForMinute = 360
        }

        let action = SCNAction.rotateTo(
            x: CGFloat(minutes.eulerAngles.x),
            y: CGFloat(minutes.eulerAngles.y),
            z: targetAngleForMinute.toRadians(),
            duration: 0.25
        )

        minutes.runAction(action) {
            Task(priority: .userInitiated) { @MainActor in
                self.currentTime.wrappedValue.setMinute(targetMinute)
            }
        }
    }

    private func thumbReleasedOnRed() {
        guard let scene = self.scene else { return }
        guard let seconds = getNodeByID("seconds", inScene: scene) else { return }

        let targetSecond = ((Int(round(seconds.eulerAngles.x.toDegrees()/30.0) + 3) + 12) % 12)*5
        var targetAngleForSecond = Int(-(CGFloat(targetSecond-15)/60.0)*360.0 + 360) % 360

        if lastRightThumbstickAngle.toDegrees() >= 180 {
            targetAngleForSecond -= 360
        }

        if targetAngleForSecond == -360 && self.lastRightThumbstickAngle.toDegrees() > 330 {
            targetAngleForSecond = 0
        }

        let action = SCNAction.rotateTo(
            x: -CGFloat(targetAngleForSecond).toRadians(),
            y: 0,
            z: 0,
            duration: 0.25
        )

        seconds.runAction(action) {
            Task(priority: .userInitiated) { @MainActor in
                self.currentTime.wrappedValue.setSecond(targetSecond)
            }
        }
    }
}
