//
//  Assets.swift
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
