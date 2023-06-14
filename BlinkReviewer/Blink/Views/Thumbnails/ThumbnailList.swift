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
            ScrollView(.horizontal) {
                LazyHStack(spacing: 7) {
                    ForEach(RandomAccessLocalIdentifiers(photosLibrary.assetIdentifiers), id: \.1) {
                        (position, localIdentifier) in
                            NewThumbnailImage(
                                localIdentifier,
                                fetchResult: photosLibrary.assets,
                                fetchResultPosition: position,
                                state: photosLibrary.state(ofLocalIdentifier: localIdentifier)
                            )
                            .frame(width: position == focusedAssetIndex ? 70 : 50, height: position == focusedAssetIndex ? 70 : 50, alignment: .center)
                            .onTapGesture {
                                focusedAssetIndex = position
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
//                    withAnimation {
                        proxy.scrollTo(
                            photosLibrary.asset(at: newIndex).localIdentifier,
                            anchor: .center
                        )
//                    }
                })
        }
    }
}
