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
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                        
                    Image(nsImage: asset.getImage())
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
