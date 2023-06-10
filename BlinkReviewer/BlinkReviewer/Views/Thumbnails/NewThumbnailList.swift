//
//  NewThumbnailList.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 10/06/2023.
//

import SwiftUI

struct NewThumbnailList: View {
    @EnvironmentObject var photosLibrary: PhotosLibrary
    @Binding var focusedAssetIndex: Int
    
    var body: some View {
        PHAssetHStack(photosLibrary.assets2) { asset, index in
            NewThumbnailImage(
                photosLibrary.getThumbnail(for: asset),
                state: photosLibrary.state(of: asset),
                isFavorite: asset.isFavorite,
                isFocused: index == focusedAssetIndex
            )
        }
    }
}
