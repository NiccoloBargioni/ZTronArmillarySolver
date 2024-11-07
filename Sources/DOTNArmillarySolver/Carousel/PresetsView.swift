import SwiftUI
import ZTronCarouselCore

internal struct PresetsCarousel: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UINavigationController {
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
                    ]
                )
        )
        
        navController.isNavigationBarHidden = true
        
        return navController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
    
    typealias UIViewControllerType = UINavigationController    
}
