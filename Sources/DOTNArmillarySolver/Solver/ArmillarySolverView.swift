import SwiftUI
import BottomSheet
import LazyViewSwiftUI

/// - Description: Use as follows:
/// ```
/// ArmillarySolverView()
///     .environmentObject(self.interfaceInfo)
///     .environmentObject(self.orientationInfo)
/// ```
public struct ArmillarySolverView: View {
    @EnvironmentObject private var interfaceInfo: InterfaceTypeInfo
    @EnvironmentObject private var orientationInfo: OrientationInfo

    @State private var isExpanded: Bool = true
    @State private var lastSolution: [AtlasButton: Int]?
    @State private var currentPreset: String = "9.45.45"

    @State private var onAngleChanged: ((CGFloat) -> Void)?
    @State private var onThumbReleased: (() -> Void)?
    @State private var onXTapped: (() -> Void)?
    @State private var onOTapped: (() -> Void)?
    @State private var onTTapped: (() -> Void)?
    
    @State private var preset: [Int] = [0, 0, 0]
    
    @State private var solutionSheetPosition: BottomSheetPosition = .hidden

    @State private var sceneSize: CGSize = .zero
    @StateObject private var atlasModel = AtlasProblemModel(currentTime: Time(hour: 8, minute: 45, second: 35))

    
    public init() { }

    public var body: some View {
        LazyViewSwiftUI.LazyView(
            TabView {
                GeometryReader { geo in
                    VStack(alignment: .leading, spacing: 0) {
                        ArmillaryVCRepresentable(
                            currentTime: self.$atlasModel.currentTime,
                            sceneSize: self.$sceneSize,
                            onAngleChanged: self.$onAngleChanged,
                            onThumbReleased: self.$onThumbReleased,
                            onXTapped: self.$onXTapped,
                            onOTapped: self.$onOTapped,
                            onTTapped: self.$onTTapped
                        )
                        .frame(width: geo.size.width, height: sceneSize.height)

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
                                            Text("Compute solution")
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
                                Text("Soluzione")
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
                .tabItem {
                    Label("Solver", systemImage: "puzzlepiece")
                }
                
                
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
                                Text(presetElement)
                                    .font(.title.weight(.bold))
                                    .layoutPriority(1)
                            }
                        }
                    }
                    .id("presets")
                    
                    HStack(alignment: .top, spacing: 0) {
                        
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .tabItem {
                    Label("Presets", systemImage: "photo.on.rectangle.angled")
                }

            }
            .navigationTitle("Armillary Solver")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance

            }
        )
    }
}
