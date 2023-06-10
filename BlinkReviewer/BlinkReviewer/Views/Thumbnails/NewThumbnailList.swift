//
//  NewThumbnailList.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 10/06/2023.
//

import SwiftUI

struct NewThumbnailList: View {
    @EnvironmentObject var photosLibrary: PhotosLibrary
    @EnvironmentObject var thumbnailManager: ThumbnailManager
    @Binding var focusedAssetIndex: Int
    
    var body: some View {
        PHAssetHStack(photosLibrary.assets2) { asset, index in
            NewThumbnailImage(asset, assetImage: thumbnailManager.getThumbnail(for: asset), isFocused: index == focusedAssetIndex)
                .environmentObject(photosLibrary)
        }
    }
}
