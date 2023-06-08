//
//  ContentView.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import SwiftUI
import Photos

struct ContentView: View {
    var allPhotos: [PHAsset] {
        var photos: [PHAsset] = []
        
        PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
            .enumerateObjects({ (asset, _, _) in
                photos.append(asset)
            })
        
        return photos
    }
    
    var body: some View {
        PhotoReviewer(assets: allPhotos)
    }
}
