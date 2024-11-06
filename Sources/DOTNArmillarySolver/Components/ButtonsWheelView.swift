import SwiftUI

struct ButtonsWheelView: View {
    private var diameter: CGFloat

    init(diameter: CGFloat) {
        self.diameter = diameter
    }

    internal var buttonsActions: [ ButtonType: GameButton ] = [
        .X: GameButton(action: nil, symbol: "xmark", fill: .blue, position: 0),
        .O: GameButton(action: nil, symbol: "circle", fill: .red, position: 1),
        .T: GameButton(action: nil, symbol: "triangle", fill: .green, position: 2)
    ]

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(UIColor.label).opacity(0.45))
                .frame(width: self.diameter, height: self.diameter)
                .overlay {
                    Circle()
                        .stroke(Color(UIColor.systemBackground).opacity(0.2), lineWidth: 1.5)
                        .frame(width: self.diameter/2.0, height: self.diameter/2.0)
                }
                .overlay {
                    Circle()
                        .stroke(Color(UIColor.systemBackground), lineWidth: 0.75)
                        .frame(width: self.diameter, height: self.diameter)
                }
            // swiftlint:disable identifier_name
            ForEach(buttonsActions.sorted(by: {
                return $0.value.getPosition() <= $1.value.getPosition()
            }), id: \.key) { _, buttonInfo in
                SwiftUI.Button {
                    (buttonInfo.getAction())?()
                } label: {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                        .background {
                            Color.black
                                .clipShape(Circle())
                        }
                        .frame(width: diameter*0.4, height: diameter*0.4)
                        .overlay {
                            Image(systemName: buttonInfo.getSymbol())
                                .font(.headline.weight(.black))
                                .foregroundStyle(buttonInfo.getFillColor())
                                .rotationEffect(.degrees(-CGFloat(buttonInfo.getPosition()*90)))
                        }
                }
                .offset(y: diameter*0.4)
                .rotationEffect(.degrees(-CGFloat(buttonInfo.getPosition()*90)))

            }
        }
        .frame(width: diameter*1.2, height: diameter*1.2)
    }

    class GameButton {
        private var action: (() -> Void)?
        private var symbol: String
        private var fill: Color
        private var position: Int

        init(action: (() -> Void)? = nil, symbol: String, fill: Color, position: Int) {
            self.action = action
            self.symbol = symbol
            self.fill = fill
            self.position = position
        }

        func setAction(_ action: @escaping () -> Void) {
            self.action = action
        }

        func getAction() -> (() -> Void)? {
            return self.action
        }

        func getSymbol() -> String {
            return self.symbol
        }

        func getFillColor() -> Color {
            return self.fill
        }

        func getPosition() -> Int {
            return self.position
        }
    }

    enum ButtonType: CaseIterable {
        case X
        case O
        case T
    }
}

extension ButtonsWheelView {
    func XButtonAction(_ action: @escaping () -> Void) -> Self {
        let copy = self
        copy.buttonsActions[.X]?.setAction {
            action()
        }
        return copy
    }

    func OButtonAction(_ action: @escaping () -> Void) -> Self {
        let copy = self
        copy.buttonsActions[.O]?.setAction {
            action()
        }
        return copy
    }

    func TButtonAction(_ action: @escaping () -> Void) -> Self {
        let copy = self
        copy.buttonsActions[.T]?.setAction {
            action()
        }
        return copy
    }
}


#Preview {
    ButtonsWheelView(diameter: 100)
}
