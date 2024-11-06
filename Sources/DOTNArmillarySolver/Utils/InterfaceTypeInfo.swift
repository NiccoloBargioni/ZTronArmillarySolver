import SwiftUI

class InterfaceTypeInfo: ObservableObject {
    @Published private var interface: UIUserInterfaceIdiom

    @MainActor
    init() {
        self.interface = UIDevice.current.userInterfaceIdiom
    }

    func isIpad() -> Bool {
        return interface == .pad
    }

    func isIPhone() -> Bool {
        return interface == .phone
    }

    func interfaceDidChangeTo(_ interface: UIUserInterfaceIdiom) {
        self.interface = interface
    }
}
