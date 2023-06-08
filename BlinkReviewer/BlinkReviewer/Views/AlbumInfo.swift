//
//  AlbumInfo.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import SwiftUI
import Photos

extension PHAsset {
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

struct AlbumInfo: View {
    var asset: PHAsset
    
    var body: some View {
        HStack {
            ForEach(asset.albums(), id: \.localIdentifier) { album in
                if let title = album.localizedTitle {
                    Text("\(Image(systemName: "rectangle.stack")) \(title)")
                        .fontWeight(.bold)
                        .font(.title2)
                        .padding(5)
                        .background(Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.9))
                        .cornerRadius(7.0)
                }
            }
        }.padding()
    }
}
