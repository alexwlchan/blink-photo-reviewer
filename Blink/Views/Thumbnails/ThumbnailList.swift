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
                ThumbnailImage(
                    index: index,
                    state: photosLibrary.state(ofLocalIdentifier: localIdentifier),
                    isFavorite: photosLibrary.isFavorite(localIdentifier: localIdentifier),
                    isFocused: index == focusedAssetIndex,
                    getAssetImage: {
                        photosLibrary.getThumbnail(for: photosLibrary.asset(at: index))
                    }
                )
                .environmentObject(photosLibrary)
                .onTapGesture {
                    focusedAssetIndex = index
                }
            }
            // When the focusedAssetIndex changes, scroll to the new position.
            //
            // By default this is an animated scroll, but if the user is scrolling
            // a long way, we skip the animation and jump straight to it -- if somebody
            // jumps over several thousand images in one go, it looks better to snap
            // rather than do a jaggy animation.
            .onChange(of: focusedAssetIndex, perform: { [oldIndex = focusedAssetIndex] newIndex in
                withAnimation(abs(newIndex - oldIndex) < 100 ? .default : nil) {
                    proxy.scrollTo(
                        photosLibrary.asset(at: newIndex).localIdentifier,
                        anchor: .center
                    )
                }
            })
        }
    }
}
