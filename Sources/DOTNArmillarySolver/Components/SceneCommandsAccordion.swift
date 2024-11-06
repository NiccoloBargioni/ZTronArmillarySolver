import SwiftUI

struct SceneCommandsAccordion: View {
    private var isExpanded: Binding<Bool>

    private var onAngleChanged: ((CGFloat) -> Void)?
    private var onThumbReleased: (() -> Void)?
    private var onXTapped: (() -> Void)?
    private var onOTapped: (() -> Void)?
    private var onTTapped: (() -> Void)?

    init(isExpanded: Binding<Bool>) {
        self.isExpanded = isExpanded
    }

    var body: some View {
        Accordion(
            isExpanded: self.isExpanded) {
                Text("Scene commands".uppercased())
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color(UIColor.label).opacity(0.8))
            } content: {
                HStack {
                    ButtonsWheelView(diameter: 100)
                        .TButtonAction {
                            self.onTTapped?()
                        }
                        .OButtonAction {
                            self.onOTapped?()
                        }
                        .XButtonAction {
                            self.onXTapped?()
                        }

                    Spacer()

                    ThumbstickView(diameter: 100)
                        .onAngleChanged { anglesDeg in
                            self.onAngleChanged?(anglesDeg)
                        }
                        .onThumbReleased {
                            self.onThumbReleased?()
                        }
                }
            }
    }
}

#Preview {
    SceneCommandsAccordion(isExpanded: .constant(false))
}

extension SceneCommandsAccordion {
    func onAngleChanged(_ action: @escaping (CGFloat) -> Void) -> Self {
        var copy = self
        copy.onAngleChanged = action
        return copy
    }

    func onThumbReleased(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onThumbReleased = action
        return copy
    }

    func onTTapped(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onTTapped = action
        return copy
    }

    func onXTapped(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onXTapped = action
        return copy
    }

    func onOTapped(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onOTapped = action
        return copy
    }
}
