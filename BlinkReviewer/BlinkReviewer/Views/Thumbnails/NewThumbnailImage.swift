import SwiftUI
import Photos

/// Render a single thumbnail image in the thumbnail picker.
///
/// Thumbnails are square, and they expand to fill the square.  This may
/// mean some information gets cropped out -- that's okay, these are only
/// small previews, not complete images.
struct NewThumbnailImage: View {
    @ObservedObject var assetImage: PHAssetImage
    var state: ReviewState?
    var isFocused: Bool
    var isFavorite: Bool
    
    private var size: CGFloat
    private var cornerRadius: CGFloat

    // Implementation note: the reason we pass in a bunch of individual
    // properties rather than the whole asset is because we need an
    // @EnvironmentObject (the PhotosLibrary) to create the PHAssetImage,
    // so we can stick the latter in an @ObservedObject.
    //
    // But EnvironmentObject values aren't passed down until you call the
    // `body` method, which is too late!  So instead we have the parent
    // view call into PhotosLibrary and pass in the relevant values here.
    init(_ assetImage: PHAssetImage, state: ReviewState?, isFavorite: Bool, isFocused: Bool) {
        self.assetImage = assetImage
        self.state = state
        self.isFavorite = isFavorite
        self.isFocused = isFocused
        
        self.size = isFocused ? 70 : 50
        self.cornerRadius = isFocused ? 7 : 5
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
            .favoriteHeartIcon(isFavorite)
    }
}
