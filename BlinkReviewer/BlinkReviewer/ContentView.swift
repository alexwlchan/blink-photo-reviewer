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
    var allPhotos: [PHAsset] {
        var photos: [PHAsset] = []
        
        PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
            .enumerateObjects({ (asset, _, _) in
                photos.append(asset)
            })
        
        return photos
    }
    
    @State private var selectedAsset: PHAsset? = nil
    
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
                        ForEach(allPhotos, id: \.localIdentifier) { photo in
                            ThumbnailItem(label: "\(photo.localIdentifier)")
                        }
                    }.padding()
                }.frame(height: 100)
            }
            Divider()
            
            if let thisSelectedAsset = selectedAsset {
                PreviewImage(asset: thisSelectedAsset)
            }
        }.onAppear {
            selectedAsset = allPhotos[0]
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
