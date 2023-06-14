//
//  NewThumbnailList.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 10/06/2023.
//

import SwiftUI

struct IndexedAssetIdentifier {
    var position: Int
    var assetIdentifier: String
}

struct IdentifierListCollection: RandomAccessCollection {
    typealias Element = IndexedAssetIdentifier
//    typealias Subsequence = [IndexedPHAsset]
    typealias Index = Int

    let assetIdentifiers: [String]

    init(_ assetIdentifiers: [String]) {
        self.assetIdentifiers = assetIdentifiers
    }
    
    var startIndex: Int { 0 }
    var endIndex: Int { assetIdentifiers.count }

    subscript(position: Int) -> IndexedAssetIdentifier {
        IndexedAssetIdentifier(position: position, assetIdentifier: assetIdentifiers[position])
    }
    
//    subscript(bounds: Range<Int>) -> Slice<IdentifierListCollection> {
//        assetIdentifiers[bounds]
//    }
    
//    subscript(bounds: Range<Int>) -> Subsequence {
//        zip(bounds, fetchResult.objects(at: IndexSet(integersIn: bounds))).map { position, asset in
//            IndexedPHAsset(
//                position: position,
//                asset: asset
//            )
//        }
//    }
}


struct ThumbnailList: View {
    @EnvironmentObject var photosLibrary: PhotosLibrary
    @Binding var focusedAssetIndex: Int
    
    var body: some View {
        ScrollViewReader { proxy in
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
                    // PHFetchResultCollection to vend a struct with cboth the asset and the
                    // position, but now it does it by random access -- this seems faster.
                    ForEach(IdentifierListCollection(photosLibrary.assetIdentifiers) , id: \.assetIdentifier) { indexedAssetIdentifier in
                        NewThumbnailImage(isFocused: indexedAssetIdentifier.position == focusedAssetIndex, indexedAssetIdentifier: indexedAssetIdentifier).environmentObject(photosLibrary).onTapGesture {
                            focusedAssetIndex = indexedAssetIdentifier.position
                        }
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
                .onChange(of: focusedAssetIndex, perform: { newIndex in
                    withAnimation {
                        proxy.scrollTo(
                            photosLibrary.asset(at: newIndex).localIdentifier,
                            anchor: .center
                        )
                    }
                })
        }
    }
}
