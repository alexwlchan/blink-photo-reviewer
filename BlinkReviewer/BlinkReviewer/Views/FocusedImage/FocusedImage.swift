import SwiftUI
import Photos

/// Render the big image that gets shown in the main view.
///
/// It's important to avoid a "flash" of empty space when switching between
/// images, so this View is only created once and then the parent modifies
/// the `asset` referred to by `assetImage`.  This means the image that was
/// previously being rendered sticks around until the new image loads in.
///
/// If this view was being passed the focused image directly, it'd be
/// recreated every time the focus changed, and there'd be a temporary flash
/// of empty space until an image could be loaded in.
struct FocusedImage: View {
    @ObservedObject var assetImage: PHAssetImage
    
    // We don't use anything from PhotosLibrary directly in this view, but we
    // do want to re-render it when we get a change to PhotosLibrary -- e.g.
    // when an asset is added to an album.
    @EnvironmentObject var photosLibrary: PhotosLibrary
    
    var body: some View {
        Image(nsImage: assetImage.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .albumInfo(for: assetImage.asset)
            .loadingIndicator(isLoading: assetImage.isDegraded)
    }
}
