//
//  ThumbnailItem.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import SwiftUI
import Photos

extension PHAsset {
    func getThumbnail() -> NSImage {
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
        }
        
        PHCachingImageManager()
            .requestImage(
                for: self,
                targetSize: CGSize(width: 50, height: 50),
                contentMode: .aspectFit,
                options: options,
                resultHandler: { (result, info) -> Void in
                    image = result!
                }
            )

        return image
    }
}

struct ThumbnailItem: View {
    @State var asset: PHAsset
    
    var body: some View {
        ZStack {
            Image(nsImage: asset.getThumbnail())
        }
    }
}
