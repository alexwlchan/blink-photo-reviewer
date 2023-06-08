//
//  AlbumInfo.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import SwiftUI
import Photos

/// This view shows the names of the albums that a given asset is in.
///
/// Each album is shown as a separate "pill" in the list, for example:
///
///     [Cats] [Cross-stitch] [Stuff I did in 2023]
///
struct AlbumInfo: View {
    var asset: PHAsset
    
    // This was chosen to match the icon used for albums in the sidebar
    // in Photos.
    private var albumImage = Image(systemName: "rectangle.stack")
    
    var body: some View {
        HStack {
            ForEach(asset.albums(), id: \.localIdentifier) { album in
                if let title = album.localizedTitle {
                    Text("\(albumImage) \(title)")
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
