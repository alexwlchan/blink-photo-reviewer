//
//  Helpers.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import Foundation
import Photos
import SwiftUI

/// Returns a list of all the images in the Photos Library.
func getAllPhotos() -> [PHAsset] {
    var photos: [PHAsset] = []
    
    PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        .enumerateObjects({ (asset, _, _) in
            photos.append(asset)
        })
    
    return photos
}

extension PHAsset {
    /// Returns a list of all the albums that contain this asset.
    func albums() -> [PHAssetCollection] {
        var result: [PHAssetCollection] = []
        
        PHAssetCollection
            .fetchAssetCollectionsContaining(self, with: .album, options: nil)
            .enumerateObjects({ (collection, index, stop) in
                result.append(collection)
            })
        
        return result
    }
    
    private func getImageForSize(size: CGSize) -> NSImage {
        // This implementation is based on code in a Stack Overflow answer
        // by Francois Nadeau: https://stackoverflow.com/a/48755517/1558022

        let options = PHImageRequestOptions()
        
        // do I still need this?
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
        
        PHCachingImageManager()
            .requestImage(
                for: self,
                targetSize: size,
                contentMode: .aspectFill,
                options: options,
                resultHandler: { (result, info) -> Void in
                    image = result!
                }
            )

        return image
    }
    
    func getThumbnail() -> NSImage {
        return getImageForSize(size: CGSize(width: 70, height: 70))
    }
    
    func getImage() -> NSImage {
        return getImageForSize(size: PHImageManagerMaximumSize)
    }
}
