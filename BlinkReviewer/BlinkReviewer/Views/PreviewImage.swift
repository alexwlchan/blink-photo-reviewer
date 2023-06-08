//
//  PreviewImage.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import Photos
import SwiftUI

extension PHAsset {
    /// Create an NSImage at the given size.
    func getImage(forWidth width: Double, forHeight height: Double) -> NSImage {
    // This implementation is based on code in a Stack Overflow answer
    // by Francois Nadeau: https://stackoverflow.com/a/48755517/1558022
    //
    // I've added more comments and error-handling logic.

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

    PHImageManager.default()
      .requestImage(
        for: self,
        targetSize: CGSize(width: width, height: height),
        contentMode: .aspectFit,
        options: options,
        resultHandler: { (result, info) -> Void in

          // If we fail to get a result, print a message to the user that
          // includes the value of `info`.  For information about interpreting
          // these keys, see Apple's documentation:
          // https://developer.apple.com/documentation/photokit/phimagemanager/image_result_info_keys
          switch (result, info) {
          case let (result?, _):
            image = result
          case let (.none, info?):
            fputs("Unable to create image:\n", stderr)
            fputs("\(info)\n", stderr)
            exit(1)
          case (.none, .none):
            fputs("Unable to create image:\n", stderr)
            fputs("(unknown error)\n", stderr)
            exit(1)
          }
        })

    return image
  }
}

struct PreviewImage: View {
    var asset: PHAsset
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack {
                    Spacer()
                    
                    Image(nsImage: asset.getImage(forWidth: geometry.size.width, forHeight: geometry.size.height))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    Spacer()
                }
            }
        }.padding()
    }
}
