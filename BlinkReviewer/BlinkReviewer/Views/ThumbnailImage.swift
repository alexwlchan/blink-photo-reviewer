//
//  ThumbnailItem.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import SwiftUI
import Photos

/// Renders a square thumbnail for an image.
///
/// The image will be expanded to fill the square, and may be clipped
/// if the original aspect ratio isn't square.
struct ThumbnailImage: View {
    var thumbnail: NSImage
    var state: ReviewState?
    var isFavorite: Bool
    var isSelected: Bool
    
    var size: CGFloat {
        isSelected ? 70.0 : 50.0
    }
    
    var cornerRadius: CGFloat {
        return isSelected ? 7.0 : 5.0
    }
    
    var body: some View {
        Image(nsImage: thumbnail)
            .resizable()
            .saturation(state == .Rejected ? 0.0 : 1.0)
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
            .overlay(
                // https://www.appcoda.com/swiftui-border/
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        state?.color() ?? .gray.opacity(0.7),
                        lineWidth: state != nil ? 3.0 : 1.0
                    )
            )
            .cornerRadius(cornerRadius)
            .overlay(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
                if (isFavorite) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.white)
                        .padding(2)
                        .shadow(radius: 2.0)
                }
            }
            .overlay(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                if let thisState = state {
                    thisState.icon()
                        .foregroundStyle(.white, thisState.color())
                        .symbolRenderingMode(.palette)
                        .padding(2)
                        .font(.title2)
                        .shadow(radius: 2.0)
                }
            }
    }
}

struct ThumbnailImage_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailImage(
            thumbnail: NSImage(named: "IMG_5934")!,
            state: .Approved,
            isFavorite: true,
            isSelected: true
        ).previewDisplayName("approved, favorite")
        
        ThumbnailImage(
            thumbnail: NSImage(named: "IMG_5934")!,
            state: .Rejected,
            isFavorite: false,
            isSelected: false
        ).previewDisplayName("rejected")
        
        ThumbnailImage(
            thumbnail: NSImage(named: "IMG_5934")!,
            state: .NeedsAction,
            isFavorite: false,
            isSelected: false
        ).previewDisplayName("needs action")
        
        ThumbnailImage(
            thumbnail: NSImage(named: "IMG_5934")!,
            state: nil,
            isFavorite: false,
            isSelected: false
        ).previewDisplayName("no state")
    }
}
