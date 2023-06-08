//
//  Helpers.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import Foundation
import Photos

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
}
