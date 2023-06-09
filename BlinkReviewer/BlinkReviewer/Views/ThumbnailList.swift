//
//  ThumbnailList.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import SwiftUI
import Photos

// https://stackoverflow.com/q/62745595/1558022
struct PHFetchResultCollection: RandomAccessCollection, Equatable {
    typealias Element = PHAsset
    typealias Index = Int

    let fetchResult: PHFetchResult<PHAsset>

    var startIndex: Int { 0 }
    var endIndex: Int { fetchResult.count }

    subscript(position: Int) -> PHAsset {
        fetchResult.object(at: position)
    }
}

struct ThumbnailList: View {
    @EnvironmentObject var photosLibrary: PhotosLibrary

    @Binding var selectedAssetIndex: Int
    
//    func displaySelectedAssetIndex() -> Int {
//        photosLibrary.assets2.count - 1 - selectedAssetIndex
//    }
//
//    func displayAssets() -> [PHAsset] {
//        photosLibrary.assets2.reversed()
//    }
    
    private var assets: PHFetchResultCollection {
        print(PHFetchResultCollection(fetchResult: photosLibrary.assets2).indices)
        return PHFetchResultCollection(fetchResult: photosLibrary.assets2)
    }
    
    
    private var thumbnails: some View {
        // Implementation note: we use the localIdentifier rather than the
        // array index as the id here, because the app gets way slower if
        // you use the array index -- it tries to regenerate a bunch of
        // the thumbnails every time you change position.
        ForEach(
            Array(zip(assets.indices, assets)), id: \.1.localIdentifier) { index, asset in
//                Text("asset \(index)")
                ThumbnailImage(
                    thumbnail: PHAssetImage(asset, size: CGSize(width: 70, height: 70), deliveryMode: .opportunistic),
                    state: photosLibrary.state(for: asset),
                    isFavorite: asset.isFavorite,
                    isSelected: photosLibrary.assets2.count - 1 - index == selectedAssetIndex
                ).onTapGesture {
                    selectedAssetIndex = photosLibrary.assets2.count - 1 - index
                }
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 5) {
                    // TODO: placeholder images for start/end
                    
                    thumbnails

                    // Note: these two uses of RTL direction are a way to get the LazyHStack
                    // to start on the right-hand side (i.e. the newest image) without loading
                    // everything else in the view.
                    //
                    // I suspect this may get easier with the new scrollPosition API, coming
                    // in the 2023 OS releases.  TODO: Investigate this new API when available.
                    //
                    // See https://developer.apple.com/documentation/swiftui/view/scrollposition(initialanchor:)
                        .flipsForRightToLeftLayoutDirection(true)
                        .environment(\.layoutDirection, .rightToLeft)
                    }.padding()
            }
                .frame(height: 90)
                .flipsForRightToLeftLayoutDirection(true)
                .environment(\.layoutDirection, .rightToLeft)
                .onChange(of: selectedAssetIndex, perform: { newIndex in
                    withAnimation {
                        proxy.scrollTo(selectedAssetIndex, anchor: .center)
                    }
                })
                .onAppear {
                    proxy.scrollTo(selectedAssetIndex, anchor: .center)
                }
        }
    }
}
