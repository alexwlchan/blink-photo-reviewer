import SwiftUI
import Photos

struct NewThumbnailImage: View {
    
    
    // Implementation note: the reason we pass in a bunch of individual
    // properties rather than the whole asset is because we need an
    // @EnvironmentObject (the PhotosLibrary) to create the PHAssetImage,
    // so we can stick the latter in an @ObservedObject.
    //
    // But EnvironmentObject values aren't passed down until you call the
    // `body` method, which is too late!  So instead we have the parent
    // view call into PhotosLibrary and pass in the relevant values here.
    var fetchResult: PHFetchResult<PHAsset>
    var fetchResultPosition: Int
    
    @ObservedObject var phassetImage: PHAssetImage = PHAssetImage(
        nil,
        size: CGSize(width: 70, height: 70),
        deliveryMode: .opportunistic,
        generateImageAutomatically: true
    )
    
    @State var nsImage: NSImage = NSImage()
    
//    var isFocused: Bool
    var localIdentifier: String
    var state: ReviewState?
    
    private var size: CGFloat
    private var cornerRadius: CGFloat
    
    init(_ localIdentifier: String, fetchResult: PHFetchResult<PHAsset>, fetchResultPosition: Int, state: ReviewState?) {
        print("Creating ThumbnailImage...")
//        self.isFocused = isFocused
        self.localIdentifier = localIdentifier
        self.fetchResultPosition = fetchResultPosition
        
        self.size = 70
        self.cornerRadius = 7
        self.state = state
        self.fetchResult = fetchResult
    }

    @State private var asset: PHAsset? = nil
        
    var body: some View {
        Image(nsImage: self.phassetImage.image)
            .resizable()
            .scaledToFill()
            .clipped()
//            .frame(width: size, height: size, alignment: .center)
            .cornerRadius(cornerRadius)
            .reviewStateColor(isRejected: state == .Rejected)
            .reviewStateBorder(for: state, with: cornerRadius)
            .reviewStateIcon(for: state, true)
            .favoriteHeartIcon(self.asset?.isFavorite ?? false, true)
            .onAppear(perform: {
                print("calling onAppear()")
                let asset = fetchResult.object(at: fetchResultPosition)
                self.asset = asset
                
                self.phassetImage.asset = asset
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
