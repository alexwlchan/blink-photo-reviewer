import SwiftUI
import Photos

struct NewThumbnailImage: View {
    var fetchResult: PHFetchResult<PHAsset>
    
    @State var nsImage: NSImage = NSImage()
    
    var isFocused: Bool
    var indexedAssetIdentifier: IndexedAssetIdentifier
    
    private var size: CGFloat
    private var cornerRadius: CGFloat
    
    init(_ indexedAssetIdentifier: IndexedAssetIdentifier, isFocused: Bool, fetchResult: PHFetchResult<PHAsset>) {
        print("creating NewTHumbnailImage...")
        
        self.isFocused = isFocused
        self.indexedAssetIdentifier = indexedAssetIdentifier
        self.fetchResult = fetchResult
        
        self.size = isFocused ? 70 : 50
        self.cornerRadius = isFocused ? 7 : 5
    }

    
//    private func size() -> CGFloat { isFocused ? 70 : 50 }
//    private func cornerRadius() -> CGFloat { isFocused ? 7 : 5 }
    
    @State private var asset: PHAsset? = nil
    
//    @State private var isFocused: Bool = false
    @State private var state: ReviewState? = nil
//    private var size: CGFloat =
    
    
    var body: some View {
//        Image(systemName: "checkmark.circle.fill")
//            .
        Image(nsImage: nsImage)
            .resizable()
            .scaledToFill()
            .clipped()
//            .frame(width: size, height: size, alignment: .center)
//            .cornerRadius(cornerRadius())
//            .reviewStateColor(isRejected: state == .Rejected)
//            .reviewStateBorder(for: state, with: cornerRadius())
//            .reviewStateIcon(for: staxte, isFocused)
//            .favoriteHeartIcon(self.asset?.isFavorite ?? false, isFocused)
            .onAppear(perform: {
                print("calling onAppear for NewThumbnailImage")
                let asset = fetchResult.object(at: indexedAssetIdentifier.position)
                self.asset = asset
                
                self.nsImage = PHAssetImage(
                    asset,
                    size: CGSize(width: size, height: size),
                    deliveryMode: .opportunistic,
                    generateImageAutomatically: true
                ).image
//                print("calling onAppear for \(assetImage.asset?.localIdentifier)")
//                assetImage.regenerateImage()
            })
    }

}

/// Render a single thumbnail image in the thumbnail picker.
///
/// Thumbnails are square, and they expand to fill the square.  This may
/// mean some information gets cropped out -- that's okay, these are only
/// small previews, not complete images.
struct ThumbnailImage: View {
    
    // Implementation note: the reason we pass in a bunch of individual
    // properties rather than the whole asset is because we need an
    // @EnvironmentObject (the PhotosLibrary) to create the PHAssetImage,
    // so we can stick the latter in an @ObservedObject.
    //
    // But EnvironmentObject values aren't passed down until you call the
    // `body` method, which is too late!  So instead we have the parent
    // view call into PhotosLibrary and pass in the relevant values here.
    @ObservedObject var assetImage: PHAssetImage
    var state: ReviewState?
    var isFocused: Bool
    var isFavorite: Bool
    
    private func size() -> CGFloat {
        isFocused ? 70 : 50
    }
    
    private func cornerRadius() -> CGFloat {
        isFocused ? 7 : 5
    }
    
    var body: some View {
//        Image(systemName: "checkmark.circle.fill")
//            .
        Image(nsImage: assetImage.image)
            .resizable()
//            .scaledToFill()
//            .clipped()
//            .frame(width: size(), height: size(), alignment: .center)
//            .cornerRadius(cornerRadius())
//            .reviewStateColor(isRejected: state == .Rejected)
//            .reviewStateBorder(for: state, with: cornerRadius())
//            .reviewStateIcon(for: state, isFocused)
//            .favoriteHeartIcon(isFavorite, isFocused)
            .onAppear(perform: {
                print("calling onAppear for \(assetImage.asset?.localIdentifier)")
                assetImage.regenerateImage()
            })
    }
        
}
