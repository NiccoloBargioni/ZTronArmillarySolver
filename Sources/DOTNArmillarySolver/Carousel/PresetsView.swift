import SwiftUI
import ZTronCarouselCore

public struct PresetsCarousel: UIViewControllerRepresentable {
    private var onPageChanged: (String, Int) -> Void
    
    public init(onPageChanged: @escaping (String, Int) -> Void) {
        self.onPageChanged = onPageChanged
    }
    
    public func makeUIViewController(context: Context) -> UINavigationController {
        let navController = UINavigationController(
            rootViewController: Carousel16_9Page(
                    with: BasicMediaFactory(),
                    medias: [
                        ZTronImageDescriptor(assetName: "8.45.35", in: .module),
                        ZTronImageDescriptor(assetName: "9.35.30", in: .module),
                        ZTronImageDescriptor(assetName: "9.45.45", in: .module),
                        ZTronImageDescriptor(assetName: "11.25.35", in: .module),
                        ZTronImageDescriptor(assetName: "11.45.40", in: .module),
                        ZTronImageDescriptor(assetName: "12.25.45", in: .module),
                    ],
                    onPageChanged: onPageChanged
                )
        )
        
        navController.isNavigationBarHidden = true
        
        return navController
    }
    
    public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }    
}
