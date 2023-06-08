//
//  PreviewImage.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import Photos
import SwiftUI

extension PHAsset {
    func getImage() -> NSImage {
        // This implementation is based on code in a Stack Overflow answer
        // by Francois Nadeau: https://stackoverflow.com/a/48755517/1558022

        let options = PHImageRequestOptions()
        options.isSynchronous = true

        // If i don't set this value, then sometimes I get an error like
        // this in the `info` variable:
        //
        //      Error Domain=PHPhotosErrorDomain Code=3164 "(null)"
        //
        // This means that the asset is in the cloud, and by default Photos
        // isn't allowed to download assets here.  Apple's documentation
        // suggests adding this option as the fix.
        //
        // See https://developer.apple.com/documentation/photokit/phphotoserror/phphotoserrornetworkaccessrequired
        options.isNetworkAccessAllowed = true

        var image = NSImage()
        
        let start = DispatchTime.now()
        var elapsed = start

        func printElapsed(_ label: String) -> Void {
          let now = DispatchTime.now()

          let totalInterval = Double(now.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
          let elapsedInterval = Double(now.uptimeNanoseconds - elapsed.uptimeNanoseconds) / 1_000_000_000

          elapsed = DispatchTime.now()

          print("Time to \(label):\n  \(elapsedInterval) seconds (\(totalInterval) total)")
        }
        
        PHCachingImageManager()
            .requestImage(
                for: self,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options,
                resultHandler: { (result, info) -> Void in
                    image = result!
                }
            )
        
        printElapsed("getting image \(self.localIdentifier)")

        return image
    }
}

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
            }.padding()
        }
    }
}
