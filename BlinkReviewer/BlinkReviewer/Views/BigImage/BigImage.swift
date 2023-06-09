//
//  BigImage.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 09/06/2023.
//

import SwiftUI
import Photos

struct BigImage: View {
    @State var asset: PHAsset
    @ObservedObject var assetImage: PHAssetImage
    
    init(_ asset: PHAsset) {
        print("creating an instance of BigImage!")
        self.asset = asset
        self.assetImage = PHAssetImage(
            asset,
            size: PHImageManagerMaximumSize,
            deliveryMode: .highQualityFormat
        )
    }
    
    var body: some View {
        Image(nsImage: assetImage.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
