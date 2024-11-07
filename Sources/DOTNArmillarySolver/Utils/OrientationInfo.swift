@preconcurrency import SwiftUI

@MainActor
public final class OrientationInfo: ObservableObject {
    public enum Orientation {
        case portrait
        case landscape
    }

    @Published private(set) public var orientation: Orientation

    private var _observer: NSObjectProtocol?

    public init() {
        // fairly arbitrary starting value for 'flat' orientations
        if UIDevice.current.orientation.isLandscape {
            self.orientation = .landscape
        } else {
            self.orientation = .portrait
        }

        // unowned self because we unregister before self becomes invalid
        _observer = NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: nil) { [unowned self] note in
            guard let device = note.object as? UIDevice else {
                return
            }
            
            Task(priority: .userInitiated) { @MainActor in
                if device.orientation.isPortrait {
                    if device.orientation.rawValue == 2 {
                        self.orientation = .landscape
                    } else {
                        self.orientation = .portrait
                    }
                } else if device.orientation.isLandscape {
                    self.orientation = .landscape
                }
            }
        }
    }

    deinit {
        if let observer = _observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
