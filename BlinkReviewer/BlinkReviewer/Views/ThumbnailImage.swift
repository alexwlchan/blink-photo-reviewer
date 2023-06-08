//
//  ThumbnailItem.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import SwiftUI

/// Renders a square thumbnail for an image.
///
/// The image will be expanded to fill the square, and may be clipped
/// if the original aspect ratio isn't square.
struct ThumbnailImage: View {
    var thumbnail: NSImage
    var isSelected: Bool
    
    var size: CGFloat {
        isSelected ? 70.0 : 50.0
    }
    
    var body: some View {
        Image(nsImage: thumbnail)
            .resizable()
            // Note: it's taken several attempts to get this working correctly;
            // it behaves differently in the running app to the SwiftUI preview.
            //
            // Expected properties:
            //
            //    - Thumbnails are square
            //    - Thumbnails are expanded to fill the square, but they prefer
            //      to crop rather than stretch the image
            //
            .scaledToFill()
            .frame(width: size, height: size, alignment: .center)
            .clipped()
    }
}

struct ThumbnailItem_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailImage(
            thumbnail: NSImage(named: "IMG_5934")!,
            isSelected: true
        )
    }
}
