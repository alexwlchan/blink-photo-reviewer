import SwiftUI
import Photos

struct ThumbnailImageInner: View {
    @ObservedObject var assetImage: PHAssetImage
    var size: CGFloat
    
    var body: some View {
        Image(nsImage: assetImage.image)
            .resizable()
            .scaledToFill()
            .clipped()
            .frame(width: size, height: size, alignment: .center)
    }
}

/// Render a single thumbnail image in the thumbnail picker.
///
/// Thumbnails are square, and they expand to fill the square.  This may
/// mean some information gets cropped out -- that's okay, these are only
/// small previews, not complete images.
struct ThumbnailImage: View {
    
    @EnvironmentObject var photosLibrary: PhotosLibrary
    
    // Implementation note: the reason we pass in a bunch of individual
    // properties rather than the whole asset is because we need an
    // @EnvironmentObject (the PhotosLibrary) to create the PHAssetImage,
    // so we can stick the latter in an @ObservedObject.
    //
    // But EnvironmentObject values aren't passed down until you call the
    // `body` method, which is too late!  So instead we have the parent
    // view call into PhotosLibrary and pass in the relevant values here.
    @State var assetImage: PHAssetImage? = nil
    
    var index: Int
    @State var state: ReviewState? = nil
    var isFocused: Bool
    @State var isFavorite: Bool = false
    
    init(index: Int, isFocused: Bool) {
        print("creating thumbnail image")
        self.index = index
        self.isFocused = isFocused
    }
    
    private func size() -> CGFloat {
        isFocused ? 70 : 50
    }
    
    private func cornerRadius() -> CGFloat {
        isFocused ? 7 : 5
    }
    
    var body: some View {
        if let thisAssetImage = assetImage {
            ThumbnailImageInner(assetImage: thisAssetImage, size: size())
                .cornerRadius(cornerRadius())
                .reviewStateColor(isRejected: state == .Rejected)
                .reviewStateBorder(for: state, with: cornerRadius())
                .reviewStateIcon(for: state, isFocused)
                .favoriteHeartIcon(isFavorite, isFocused)
                
        } else {
            ProgressView()
                .onAppear {
                    let asset = photosLibrary.asset(at: index)
                    
                    self.state = photosLibrary.state(of: asset)
                    self.isFavorite = asset.isFavorite
                    
                    self.assetImage = photosLibrary.getThumbnail(for: asset)
                }
        }
        
    }
}
