import SwiftUI
import Photos

/// Render a single thumbnail image in the thumbnail picker.
///
/// Thumbnails are square, and they expand to fill the square.  This may
/// mean some information gets cropped out -- that's okay, these are only
/// small previews, not complete images.
struct NewThumbnailImage: View {
    @EnvironmentObject var photosLibrary: PhotosLibrary
    
    var asset: PHAsset
    var isFocused: Bool
    
    private var size: CGFloat
    private var cornerRadius: CGFloat
    
    @ObservedObject var assetImage: PHAssetImage
    
    init(_ asset: PHAsset, isFocused: Bool) {
        self.asset = asset
        self.isFocused = isFocused
        
        self.size = isFocused ? 70 : 50
        self.cornerRadius = isFocused ? 7 : 5
        
        self.assetImage = PHAssetImage(
            asset,
            size: CGSize(width: self.size, height: self.size),
            deliveryMode: .fastFormat
        )
    }
    
    private var state: ReviewState? {
        photosLibrary.state(for: asset)
    }
    
    var body: some View {
        Image(nsImage: assetImage.image)
            .resizable()
            .scaledToFill()
            .clipped()
            .frame(width: self.size, height: self.size, alignment: .center)
            .cornerRadius(cornerRadius)
            .reviewStateBorder(for: state, with: cornerRadius)
            .reviewStateIcon(for: state)
            .reviewStateColor(isRejected: state == .Rejected)
            .favoriteHeartIcon(for: asset)
    }
}

struct NewThumbnailImage_Previews: PreviewProvider {
    static var asset: PHAsset = PHAsset.fetchAssets(with: nil).firstObject!
    
    static var previews: some View {
        NewThumbnailImage(asset, isFocused: false)
            .environmentObject(PhotosLibrary())
            .previewDisplayName("thumbnail, not focused")
        
        NewThumbnailImage(asset, isFocused: true)
            .environmentObject(PhotosLibrary())
            .previewDisplayName("thumbnail, focused")
    }
}
