//
//  ThumbnailList.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import SwiftUI
import Photos

struct ThumbnailList: View {
    var assets: [PHAsset]
    @Binding var selectedAssetIndex: Int
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 5) {
                    // TODO: placeholder images for start/end
                    // TODO: Allow tapping thumbnails to jump to that
                    
                    // Implementation note: we use the localIdentifier rather than the
                    // array index as the id here, because the app gets way slower if
                    // you use the array index -- it tries to regenerate a bunch of
                    // the thumbnails every time you change position.
                    ForEach(Array(assets.enumerated()), id: \.element.localIdentifier) { index, asset in
                        ThumbnailImage(
                            thumbnail: asset.getThumbnail(),
                            isSelected: assets[selectedAssetIndex].localIdentifier == asset.localIdentifier
                        ).onTapGesture {
                            selectedAssetIndex = index
                        }
                    }
                }.padding()
            }.frame(height: 70)
                .onChange(of: selectedAssetIndex, perform: { newIndex in
                    withAnimation {
                        proxy.scrollTo(assets[newIndex].localIdentifier, anchor: .center)
                    }
                })
        }
    }
}
