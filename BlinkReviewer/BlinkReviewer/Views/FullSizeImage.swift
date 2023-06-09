//
//  PreviewImage.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import Photos
import SwiftUI

struct FullSizeImage: View {
    @ObservedObject var image: PHAssetImage
    
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
                        .overlay(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
                            
                            // Render a progress indicator if we're waiting for a higher-resolution
                            // image to load; see the comment on `PHAssetImage`.
                            //
                            // `ProgressView` does have a `tint` modifier, but that doesn't seem to
                            // work on macOS 13 -- this uses some code from a Stack Overflow answer
                            // by aheze: https://stackoverflow.com/a/66568704/1558022
                            if (self.image.isDegraded) {
                                ProgressView()
                                    .colorInvert()
                                    .brightness(1)
                                    .padding()
                            }
                            
                        }
                        
                    Spacer()
                }
                
                Spacer()
            }.padding()
        }
    }
}
