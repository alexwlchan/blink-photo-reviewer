import SwiftUI
import Photos

/// Render the big image that gets shown in the main view.
struct FocusedImage: View, Identifiable {
    var id: String {
        asset.localIdentifier
    }
    
    var asset: PHAsset
    @ObservedObject var focusedAssetImage: PHAssetImage
    
    var body: some View {
        Image(nsImage: focusedAssetImage.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .albumInfo(for: asset)
            .loadingIndicator(isLoading: focusedAssetImage.isDegraded)
    }
}
