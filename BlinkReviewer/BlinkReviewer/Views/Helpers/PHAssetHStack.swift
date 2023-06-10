import SwiftUI
import Photos

/// Creates an HStack of PHAssets that fills in right-to-left.
///
/// This provides lazy loading to the left-hand side, and assumes you're
/// going to start scrolled to the far right, e.g. if the last three items
/// are visible:
///
///         [9] [8] [7] [6] [5] [4] [3] [2] [1] [0]
///                                     ^^^^^^^^^^^
///
/// Then the lower-numbered items won't be rendered by SwiftUI until the
/// users scrolls to bring them into view.
///
/// This is similar to the behaviour of a LazyHStack, but if you scroll a
/// LazyHStack to the far right, it loads every element immediately.
///
/// This takes a subview which is used to render the individual entries;
/// these subviews receive the original PHAsset and the index from the
/// original PHFetchResult -- you can use this index to retrieve adjacent
/// items in the FetchResult, if necessary.
///
struct PHAssetHStack<Content: View>: View {
    var subview: (PHAsset, Int) -> Content
    var collection: PHFetchResultCollection
    
    init(
        _ fetchResult: PHFetchResult<PHAsset>,
        @ViewBuilder subview: @escaping (PHAsset, Int) -> Content
    ) {
        print("--> creating PHAssetHStack")
        self.subview = subview
        self.collection = PHFetchResultCollection(fetchResult)
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 7) {
                // Implementation note: we use the localIdentifier rather than the
                // array index as the id here, because the app gets way slower if
                // you use the PHFetchResult index -- it tries to regenerate a bunch of
                // the thumbnails every time you change position.
                ForEach(
                    Array(
                        zip(self.collection.indices, self.collection)
                    ),
                    id: \.1.localIdentifier
                ) { index, asset in
                    subview(asset, index)
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
            VStack {
                Text("view index = \(index)")
                Text("asset ID =\n\(asset.localIdentifier)")
                Text("fetchResult.object(at: \(index)) =\n\(fetchResult.object(at: index).localIdentifier)")
            }
        }
    }
}
