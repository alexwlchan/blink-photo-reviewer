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
    
    init(_ asset: PHAsset) {
        self.asset = asset
    }
    
    var body: some View {
        HStack {
            ForEach(asset.albums(), id: \.localIdentifier) { album in
                if let title = album.localizedTitle {
                    // Don't show the names of the meta-albums used to manage
                    // review state.
                    if (title != "Approved" && title != "Rejected" && title != "Needs Action") {
                        
                        // The icon was chosen to match the one used for albums
                        // in the sidebar in Photos.
                        Text("\(Image(systemName: "rectangle.stack")) \(title)")
                            .fontWeight(.bold)
                            .font(.title2)
                            .padding(5)
                            .background(.white.opacity(0.9))
                            .cornerRadius(7.0)
                            .shadow(radius: 2.0)
                    }
                }
            }
        }.padding()
    }
}
