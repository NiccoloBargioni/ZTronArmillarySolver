import SwiftUI
import BottomSheet
import LazyViewSwiftUI


public struct DOTNSolverView: View {
    @EnvironmentObject private var interfaceInfo: InterfaceTypeInfo

    @State private var isExpanded: Bool = true
    @State private var lastSolution: [AtlasButton: Int]?
    @State private var currentPreset: String = "9.45.45"

    @State private var onAngleChanged: ((CGFloat) -> Void)?
    @State private var onThumbReleased: (() -> Void)?
    @State private var onXTapped: (() -> Void)?
    @State private var onOTapped: (() -> Void)?
    @State private var onTTapped: (() -> Void)?
    
    @ObservedObject private var atlasModel: AtlasProblemModel
    @State private var sceneSize: CGSize = .zero

    @State private var solutionSheetPosition: BottomSheetPosition = .hidden

    
    public init(model: AtlasProblemModel) {
        self._atlasModel = ObservedObject(wrappedValue: model)
    }

    
    public var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 0) {
                ArmillaryVCRepresentable(
                    currentTime: self.$atlasModel.currentTime,
                    onAngleChanged: self.$onAngleChanged,
                    onThumbReleased: self.$onThumbReleased,
                    onXTapped: self.$onXTapped,
                    onOTapped: self.$onOTapped,
                    onTTapped: self.$onTTapped
                )
                .frame(width: geo.size.width, height: geo.size.height * 0.45)

                ScrollViewReader { scrollViewProxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .center) {
                            SceneCommandsAccordion(isExpanded: self.$isExpanded)
                                .onAngleChanged { angleDeg in
                                    self.onAngleChanged?(angleDeg)
                                }
                                .onThumbReleased {
                                    self.onThumbReleased?()
                                }
                                .onXTapped {
                                    self.onXTapped?()
                                }
                                .onOTapped {
                                    self.onOTapped?()
                                }
                                .onTTapped {
                                    self.onTTapped?()
                                }
                                .animation(.easeIn(duration: 0.25), value: self.isExpanded)

                            if self.lastSolution == nil {
                                Button {
                                    DispatchQueue.main.async {
                                        self.lastSolution = self.atlasModel.solve()

                                        if self.interfaceInfo.isIPhone() {
                                            withAnimation {
                                                self.isExpanded = false
                                            }
                                        }
                                    }
                                } label: {
                                    Text("bo4.dotn.easter.egg.armillary.solve.button")
                                        .font(.callout)
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, 10)
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(false)
                                .animation(.easeIn(duration: 0.25), value: self.isExpanded)
                                .frame(width: geo.size.width * 0.75)
                            } else {
                                VStack(alignment: .center) {
                                    GeometryReader { geo in
                                        CircularSolutionView(
                                            itemsCount: 6,
                                            minOuterRadius: 300,
                                            containerSize: geo.size
                                        ) { i in
                                            let count = self.lastSolution?[AtlasButton.fromIndex(i)] ?? 0
                                            
                                            VStack(alignment: .center, spacing: 5) {
                                                Circle()
                                                    .fill(.clear)
                                                    .background {
                                                        count <= 0 ?
                                                        Color(UIColor.systemOrange) :
                                                        Color(UIColor.systemGreen)
                                                    }
                                                    .overlay(alignment: .center) {
                                                        Text("\(AtlasButton.fromIndex(i).rawValue)")
                                                            .font(.subheadline.weight(.semibold))
                                                    }
                                                    .clipShape(Circle())
                                                
                                                Text("x\(self.lastSolution?[AtlasButton.fromIndex(i)] ?? 0)")
                                                    .font(.footnote.weight(.light))
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .animation(.easeIn(duration: 0.25), value: self.isExpanded)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
            .bottomSheet(
                bottomSheetPosition: self.$solutionSheetPosition,
                switchablePositions: [.hidden, .absolute(300), .relative(0.75)],
                headerContent: {
                    VStack(spacing: 10) {
                        Text("bo4.dotn.easter.egg.armillary.solution.title")
                            .font(.headline.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        Divider()
                    }
                
                }
            ) {
                GeometryReader { geo in
                    VStack(alignment: .center, spacing: 0) {
                        CircularSolutionView(itemsCount: 6, minOuterRadius: 300, containerSize: geo.size) { i in
                            let count = self.lastSolution?[AtlasButton.fromIndex(i)] ?? 0
                            
                            VStack(alignment: .center, spacing: 5) {
                                Circle()
                                    .fill(.clear)
                                    .background {
                                        count <= 0 ?
                                        Color(UIColor.systemOrange) :
                                        Color(UIColor.systemGreen)
                                    }
                                    .overlay(alignment: .center) {
                                        Text("\(AtlasButton.fromIndex(i).rawValue)")
                                            .font(.subheadline.weight(.semibold))
                                    }
                                    .clipShape(Circle())
                                
                                Text("x\(self.lastSolution?[AtlasButton.fromIndex(i)] ?? 0)")
                                    .font(.footnote.weight(.light))
                            }
                        }
                        .onClose { @Sendable in
                            self.solutionSheetPosition = .hidden
                        }
                        .padding(.top, 44 + 20)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .isResizable()
            .sheetWidth(.relative(1.0))
            .enableSwipeToDismiss()
            .enableBackgroundBlur()
            .backgroundBlurMaterial(.dark(.thick))
        }
        .onReceive(self.atlasModel.objectWillChange.receive(on: RunLoop.main)) { _ in
            self.lastSolution = nil
        }
        .mainActorOnChange(of: self.lastSolution?.count) {
            if self.lastSolution?.count ?? -1 > 0 {
                self.solutionSheetPosition = .relative(0.75)
            }
        }
    }
}


@MainActor public struct DOTNPresetsCarouselView: View {
    @State private var preset: [Int] = [5, -5, 6]

    public init() {  }
    
    public var body: some View {
        VStack(alignment: .leading) {
            PresetsCarousel { page, _ in
                switch page {
                case "8.45.35":
                    self.preset = [5, -5, 6]
                    
                case "9.35.30":
                    self.preset = [6, -5, 5]
                    
                case "9.45.45":
                    self.preset = [5, 6, -5]
                    
                case "11.25.35":
                    self.preset = [-5, 6, 5]
                    
                case "11.45.40":
                    self.preset = [6, 5, -5]
                    
                case "12.25.45":
                    self.preset = [-5, 5, 6]
                    
                default:
                    break
                }
            }
            .overlay(alignment: .bottom) {
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(self.preset, id: \.hashValue) { presetElement in
                        Text("\(presetElement)")
                            .font(.title.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .id("presets")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
