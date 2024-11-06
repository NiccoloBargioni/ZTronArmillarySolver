import SwiftUI

internal struct CircularSolutionView<V>: View where V: View {
    private let padding: CGFloat = 20
    private let itemsCount: Int
    private let minOuterRadius: CGFloat
    private let containerSize: CGSize
    
    private let circleView: (_ i: Int) -> V
    internal var onClose: (@MainActor @Sendable () -> Void)? = nil
    
    init(
        itemsCount: Int,
        minOuterRadius: CGFloat = .infinity,
        containerSize: CGSize,
        @ViewBuilder circleView: @escaping (Int) -> V,
        onClose: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.itemsCount = itemsCount
        self.minOuterRadius = minOuterRadius
        self.circleView = circleView
        self.onClose = onClose
        self.containerSize = containerSize
    }

    internal var body: some View {
        let viewportMin = max(300, min(containerSize.width, containerSize.height))

        ZStack(alignment: .bottom) {
            let items = max(1, Double(self.itemsCount - 1))
            let angleSpacing = 180.0 / items
            

            let distance = self.computeDistance(
                outerRadius: (viewportMin - padding) / 2.0,
                innerRadius: 25,
                spacingAngle: angleSpacing
            )
            

            ForEach(0..<self.itemsCount, id: \.self) { index in
                // Convert types explicitly to avoid complex type inference
                let currentIndex = Double(index)
                let angle = angleSpacing * currentIndex
                
                // Convert the angle to radians for the trigonometric functions
                let angleInRadians = angle * Double.pi / 180
                
                let cosx = CGFloat(cos(angleInRadians))
                let sinx = CGFloat(sin(angleInRadians))
                
                let radius = viewportMin / 2.0 - padding - 25
                let adjustedRadius = CGFloat(radius)
                
                let offsetX = -adjustedRadius * cosx
                let offsetY = -adjustedRadius * sinx
                
                circleView(index)
                    .frame(width: distance/sqrt(2), height: distance/sqrt(2))
                    .offset(x: offsetX, y: offsetY)
                
            }
        }
        .frame(
            width: viewportMin <= 0 ? nil : (viewportMin + padding),
            height: viewportMin <= 0 ? nil : viewportMin / 2.0 + padding,
            alignment: .bottom
        )
        .overlay(alignment: .bottom) {
            if let onClose = self.onClose {
                Button {
                    Task(priority: .userInitiated) { @MainActor in
                        onClose()
                    }
                } label: {
                    Image(systemName: "x.circle")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            }
        }
    }
    
    private func computeDistance(
        outerRadius: CGFloat,
        innerRadius: CGFloat,
        spacingAngle: CGFloat
    ) -> Double {
        let centerA = CGPoint(
            x: -(outerRadius - innerRadius),
            y: 0
        )
        
        let centerB = CGPoint(
            x: -(outerRadius - innerRadius) * cos(Double(spacingAngle) * Double.pi / 180.0),
            y: -(outerRadius - innerRadius) * sin(Double(spacingAngle) * Double.pi / 180.0)
        )
        
        return Double(centerA.distance(to: centerB))
    }
}


#Preview {
    GeometryReader { geo in
        CircularSolutionView(itemsCount: 5, containerSize: geo.size) { _ in
            VStack(alignment: .leading, spacing: 0) {
                Rectangle()
                    .fill(.red)
                
                
                Circle()
                    .frame(width: 50, height: 50)
                    .opacity(0.5)
                
            }
        }
    }
}

internal extension CircularSolutionView {
    func onClose(_ onCloseTapped: (@MainActor @escaping @Sendable () -> Void)) -> Self {
        var copy = self
        copy.onClose = onCloseTapped
        return copy
    }
}

