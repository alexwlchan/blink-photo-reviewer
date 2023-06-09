//
//  PreviewImage.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import Photos
import SwiftUI

struct PreviewImage: View {
    var asset: PHAsset
    
    @ObservedObject var image: PHAssetImage = PHAssetImage(nil, size: PHImageManagerMaximumSize)
    
    init(asset: PHAsset) {
        self.asset = asset
        self.image = PHAssetImage(asset, size: PHImageManagerMaximumSize)
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                        
                    Image(nsImage: self.image.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .overlay(alignment: Alignment(horizontal: .center, vertical: .top)) {
                            AlbumInfo(asset: asset)
                        }
                        
                    Spacer()
                }
                
                Spacer()
            }.padding()
        }
    }
}
