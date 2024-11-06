import SwiftUI

public final class InterfaceTypeInfo: ObservableObject {
    @Published private var interface: UIUserInterfaceIdiom

    @MainActor
    public init() {
        self.interface = UIDevice.current.userInterfaceIdiom
    }

    public final func isIpad() -> Bool {
        return interface == .pad
    }

    public final func isIPhone() -> Bool {
        return interface == .phone
    }

    public final func interfaceDidChangeTo(_ interface: UIUserInterfaceIdiom) {
        self.interface = interface
    }
}
