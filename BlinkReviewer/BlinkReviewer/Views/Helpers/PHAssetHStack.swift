import SwiftUI
import Photos

/// Creates an HStack of PHAssets that scrolls right-to-left.
///
/// This provides lazy loading to the left-hand side, and assumes you're
/// going to start scrolled to the far right, e.g. if the last three items
/// are visible:
///
///         [0] [1] [2] [3] [4] [5] [6] [7] [8] [9]
///                                     ^^^^^^^^^^^
///
/// Then the lower-numbered items won't be rendered by SwiftUI until the
/// users scrolls to bring them into view.
///
/// This is similar to the behaviour of a LazyHStack, but if you scroll a
/// LazyHStack to the far right, it loads every element immediately.
///
/// This takes a subview which is used to render the individual entries;
/// these subviews receive the original PHAsset and the index (counting
/// from the left, 0-indexed).
///
struct PHAssetHStack<Content: View>: View {
    var subview: (PHAsset, Int) -> Content
    var fetchResult: PHFetchResult<PHAsset>
    
    init(
        _ fetchResult: PHFetchResult<PHAsset>,
        @ViewBuilder subview: @escaping (PHAsset, Int) -> Content
    ) {
        self.subview = subview
        self.fetchResult = fetchResult
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 5) {
                // TODO: placeholder images for start/end
                
                // Implementation note: we use the localIdentifier rather than the
                // array index as the id here, because the app gets way slower if
                // you use the array index -- it tries to regenerate a bunch of
                // the thumbnails every time you change position.
                //
                // However, we do want to expose the index to the callers -- I think?
                //
                // TODO: Investigate whether we can do this entirely using the
                // localIdentiifer, and skip the index entirely.
                ForEach(
                    Array(
                        zip(PHFetchResultCollection(fetchResult).indices, PHFetchResultCollection(fetchResult))
                    ),
                    id: \.1.localIdentifier
                ) { index, asset in
                    subview(asset, fetchResult.count - index - 1)
                }
                
                // Note: these two uses of RTL direction are a way to get the LazyHStack
                // to start on the right-hand side (i.e. the newest image) without loading
                // everything else in the view.
                //
                // I suspect this may get easier with the new scrollPosition API, coming
                // in the 2023 OS releases.  TODO: Investigate this new API when available.
                //
                // See https://developer.apple.com/documentation/swiftui/view/scrollposition(initialanchor:)
                //
                // The current implementation comes from a suggestion in a Stack Overflow
                // answer by Maciek Czarnik: https://stackoverflow.com/a/64195239/1558022
                    .flipsForRightToLeftLayoutDirection(true)
                    .environment(\.layoutDirection, .rightToLeft)
                }.padding()
        }
            .flipsForRightToLeftLayoutDirection(true)
            .environment(\.layoutDirection, .rightToLeft)
    }
}

struct PHAssetHStack_Previews: PreviewProvider {
    static var fetchResult: PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = 25
        
        return PHAsset.fetchAssets(with: options)
    }
    
    static var previews: some View {
        PHAssetHStack(fetchResult) { asset, index in
            Text("Asset \(index):\n\(asset.creationDate?.ISO8601Format() ?? "(unknown)")")
        }
    }
}
