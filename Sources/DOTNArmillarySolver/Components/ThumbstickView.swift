import SwiftUI
import SwiftUIJoystick

/// A view that displays a circular joystick onscreen, and provides callbacks for joystick actions.
///
/// - Parameter diameter: The diameter/width of the joystick.
/// - Parameter onAngleChange: A callback that's invoked every time that the joystick thumb is moved. The parameter represents an angle that's 0 at 3 PM and increases clockwise.
/// - Parameter onThumbstickReleased: A callback that's invoked when the joystick thumb is released.
struct ThumbstickView: View {
    @StateObject private var joystickMonitor: JoystickMonitor
    private var diameter: CGFloat
    private var onAngleChange: ((CGFloat) -> Void)?
    private var onThumbstickReleased: (() -> Void)?
    private var highlightColor = Color(UIColor(red: 253.0/255.0, green: 185.0/255.0, blue: 21.0/255.0, alpha: 1.0))

    @State private var thumbMoved = false
    @State private var litIndicator: Int = -1

    init(diameter: CGFloat, onAngleChange: ((CGFloat) -> Void)? = nil, onThumbstickReleased: (() -> Void)? = nil) {
        self.diameter = diameter
        self.onAngleChange = onAngleChange
        self.onThumbstickReleased = onThumbstickReleased

        self._joystickMonitor = StateObject(wrappedValue: JoystickMonitor())
    }

    var body: some View {
        JoystickBuilder(
            monitor: self.joystickMonitor,
            width: self.diameter,
            shape: .circle,
            background: {
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
                    .overlay {
                        ZStack(alignment: .center) {
                            // swiftlint:disable identifier_name

                            // lays out triangles counterclockwise starting from 270 deg
                            ForEach(Array(0..<12), id: \.self) { i in
                                Triangle()
                                    .fill(i == self.litIndicator ? highlightColor : Color(UIColor.systemBackground))
                                    .frame(width: 4, height: 4)
                                    .offset(y: self.diameter/2.5)
                                    .rotationEffect(.degrees(-CGFloat(i*30)))
                            }
                        }
                    }
            },
            foreground: {
                // Example Thumb
                Circle()
                    .fill(Color(UIColor.systemGroupedBackground))
                    .overlay {
                        Circle()
                            .stroke(Color(UIColor.label).opacity(0.8), lineWidth: 0.75)
                            .padding(1.5)
                    }
                    .opacity(0.5)
            },
            locksInPlace: false)
            .mainActorOnChange(of: self.joystickMonitor.xyPoint, actionPriority: .userInitiated) {
                
                if !equals(
                    self.joystickMonitor.xyPoint.x,
                    self.joystickMonitor.xyPoint.y,
                    eps: sqrt(Double(1).ulp)
                ) {
                    var angle = atan2(self.joystickMonitor.xyPoint.x, self.joystickMonitor.xyPoint.y) * 180.0 / Double.pi
                    
                    if angle < 0 {
                        angle += 360
                    }
                    
                    self.litIndicator = Int(round(angle / 30.0)) % 12

                    // Turn the zero reference to 3 PM, clockwise
                    angle = angle - 90 + 360
                    
                    if angle < 0 {
                        angle += 360
                    } else {
                        while angle > 360 {
                            angle -= 360
                        }
                    }
                    
                    self.onAngleChange?(
                        CGFloat(angle)
                    )
                } else {
                    self.litIndicator = -1
                    self.onThumbstickReleased?()
                }
            }
    }
}

#Preview {
    ThumbstickView(diameter: 75)
}

extension ThumbstickView {
    func onAngleChanged(_ action: @escaping (CGFloat) -> Void) -> Self {
        var copy = self
        copy.onAngleChange = action
        return copy
    }

    func onThumbReleased(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onThumbstickReleased = action
        return copy
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        return path
    }
}


fileprivate func equals(_ lhs: Double, _ rhs: Double, eps: Double) -> Bool {
    return abs(lhs - rhs) < eps
}
