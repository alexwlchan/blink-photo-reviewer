//
//  ThumbnailList.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import SwiftUI
import Photos

struct ThumbnailList: View {
    @EnvironmentObject var photosLibrary: PhotosLibrary

    @Binding var selectedAssetIndex: Int
    
    func displaySelectedAssetIndex() -> Int {
        photosLibrary.assets.count - 1 - selectedAssetIndex
    }
    
    func displayAssets() -> [PHAsset] {
        photosLibrary.assets.reversed()
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 5) {
                    // TODO: placeholder images for start/end
                    
                    // Implementation note: we use the localIdentifier rather than the
                    // array index as the id here, because the app gets way slower if
                    // you use the array index -- it tries to regenerate a bunch of
                    // the thumbnails every time you change position.
                    ForEach(Array(displayAssets().enumerated()), id: \.element.localIdentifier) { index, asset in
                        ThumbnailImage(
                            thumbnail: asset.getThumbnail(),
                            state: asset.state(),
                            isFavorite: asset.isFavorite,
                            isSelected: displayAssets()[displaySelectedAssetIndex()].localIdentifier == asset.localIdentifier
                        ).onTapGesture {
                            selectedAssetIndex = photosLibrary.assets.count - 1 - index
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
                        .flipsForRightToLeftLayoutDirection(true)
                        .environment(\.layoutDirection, .rightToLeft)
                    }.padding()
            }
                .frame(height: 90)
                .flipsForRightToLeftLayoutDirection(true)
                .environment(\.layoutDirection, .rightToLeft)
                .onChange(of: selectedAssetIndex, perform: { newIndex in
                    withAnimation {
                        proxy.scrollTo(displayAssets()[displaySelectedAssetIndex()].localIdentifier, anchor: .center)
                    }
                })
                .onAppear {
                    proxy.scrollTo(displayAssets()[displaySelectedAssetIndex()].localIdentifier, anchor: .center)
                }
        }
    }
}
