//
//  ThumbnailItem.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import SwiftUI

struct ThumbnailItem: View {
    var thumbnail: NSImage
    var isSelected: Bool
    
    var size: CGFloat {
        isSelected ? 70.0 : 50.0
    }
    
    var body: some View {
        Image(nsImage: thumbnail)
            .resizable()
            // Note: order of properties is important, frame before aspectRatio otherwise breaks!
            // only in running app, not SwiftUI preview \_/
            .scaledToFill()
            .frame(width: size, height: size, alignment: .center)
            .clipped()
            .border(.green)
    }
}

struct ThumbnailItem_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailItem(
            thumbnail: NSImage(named: "IMG_5934")!,
            isSelected: true
        )
    }
}
