import SwiftUI
import Photos

struct AssetIdentifiersCollection: RandomAccessCollection, Equatable {
    typealias Element = (Int, String)
    typealias Index = Int
    
    let assetIdentifiers: [String]

    var startIndex: Int { 0 }
    var endIndex: Int { assetIdentifiers.count }

    subscript(position: Int) -> Element {
        (position, assetIdentifiers[position])
    }
}

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
/// these subviews receive the position and identifier of the original asset.
///
/// Note: this operates on a list of asset identifiers, but not the assets
/// themselves -- this is a performance optimisation.  If the user scrolls
/// deep into the list, SwiftUI will try to render lots of entries, and if
/// those are PHAsset elements, it'll go back to the Photos database, even
/// though we don't really need any Photos data in our views.
///
struct PHAssetHStack<Content: View>: View {
    var subview: (String, Int) -> Content
    var assetIdentifiers: [String]
    
    init(
        assetIdentifiers: [String],
        @ViewBuilder subview: @escaping (String, Int) -> Content
    ) {
        print("--> creating PHAssetHStack")
        self.subview = subview
        self.assetIdentifiers = assetIdentifiers
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 7) {
                // Implementation note: we use the localIdentifier rather than the
                // array index as the id here, because the app gets way slower if
                // you use the PHFetchResult index -- it tries to regenerate a bunch of
                // the thumbnails every time you change position.
                //
                // Note: an older implementation of this code had
                //
                // ```swift
                //      ForEach(
                //          Array(zip(self.collection.indices, self.collection)),
                //          id: \.1.localIdentifier
                //      )
                // ```
                //
                // For some reason this caused the app to slow to a crawl -- I think it was
                // creating the entire Array, which is quite expensive.  I switched the
                // PHFetchResultCollection to vend a struct with both the asset and the
                // position, but now it does it by random access -- this seems faster.
                //
                // Note: enumerated is okay
                ForEach(AssetIdentifiersCollection(assetIdentifiers: self.assetIdentifiers), id: \.1) { index, localIdentifier in
                    subview(localIdentifier, index)
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
