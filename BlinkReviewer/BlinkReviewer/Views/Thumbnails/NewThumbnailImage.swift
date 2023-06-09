//
//  NewThumbnailImage.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 09/06/2023.
//

import SwiftUI
import Photos

struct NewThumbnailImage: View {
    var asset: PHAsset
    @ObservedObject var assetImage: PHAssetImage
    
    init(_ asset: PHAsset) {
        self.asset = asset
        self.assetImage = PHAssetImage(asset, size: CGSize(width: 70.0, height: 70.0), deliveryMode: .fastFormat)
    }
    
    var body: some View {
        Image(nsImage: assetImage.image)
    }
}
