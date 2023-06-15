//
//  NewThumbnailList.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 10/06/2023.
//

import SwiftUI

struct ThumbnailList: View {
    @EnvironmentObject var photosLibrary: PhotosLibrary
    @Binding var focusedAssetIndex: Int
    
    var body: some View {
        ScrollViewReader { proxy in
            PHAssetHStack(assetIdentifiers: photosLibrary.assetIdentifiers) { localIdentifier, index in
                ThumbnailImage(index: index, isFocused: index == focusedAssetIndex)
                .environmentObject(photosLibrary)
                .onTapGesture {
                    focusedAssetIndex = index
                }
            }
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
