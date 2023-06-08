//
//  ContentView.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import SwiftUI
import Photos

struct AssetData: Codable, Identifiable {
    var localIdentifier: String
    var creationDate: String?
    var isFavorite: Bool
    
    var id: String {
        localIdentifier
    }
}

struct ContentView: View {
    var allPhotos: [AssetData] {
        var photos: [AssetData] = []
        
        PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
            .enumerateObjects({ (asset, _, _) in
                photos.append(
                AssetData(
                    localIdentifier: asset.localIdentifier,
                    creationDate: asset.creationDate?.ISO8601Format(),
                    isFavorite: asset.isFavorite
                )
            )
        })
        
        return photos
    }
    
    var body: some View {
        VStack {
            Divider()
            ScrollViewReader { value in
                ScrollView(.horizontal) {
                    Button("Jump to #8") {
                        value.scrollTo(8, anchor: .center)
                    }
                    .padding()
                    
                    LazyHStack(spacing: 10) {
                        ForEach(allPhotos) { photo in
                            ThumbnailItem(label: "\(photo.localIdentifier)")
                        }
                    }.padding()
                }.frame(height: 100)
            }
            
        }
        Divider()
        Spacer()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
