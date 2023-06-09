//
//  PreviewImage.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import Photos
import SwiftUI

struct FullSizeImage: View {
    @ObservedObject var image: PHAssetImage = PHAssetImage(nil, size: PHImageManagerMaximumSize)
    
    init(asset: PHAsset) {
        print("Calling FullSizeImage.init() for \(asset.localIdentifier)")
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
                            if let asset = image.asset {
                                AlbumInfo(asset)
                            }
                        }
                        
                    Spacer()
                }
                
                Spacer()
            }.padding()
        }
    }
}
