import SwiftUI

internal extension View {
    @inlinable nonisolated func commonOnChange<V>(of value: V, perform action: @escaping @Sendable () -> Void) -> some View where V : Equatable {
        if #available(iOS 17.0, *) {
            return self.onChange(of: value, action)
        } else {
            return self.onChange(of: value, perform: { _ in
                action()
            })
        }
    }
}

internal extension View {
    @inlinable nonisolated func mainActorOnChange<V>(
        of value: V,
        actionPriority: TaskPriority = .userInitiated,
        perform action: @MainActor @escaping @Sendable () -> Void) -> some View where V : Equatable {
        if #available(iOS 17.0, *) {
            return self.onChange(of: value) {
                Task(priority: actionPriority) { @MainActor in
                    action()
                }
            }
        } else {
            return self.onChange(of: value, perform: { _ in
                Task(priority: actionPriority) { @MainActor in
                    action()
                }
            })
        }
    }
}
