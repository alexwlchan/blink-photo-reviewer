//
//  ThumbnailItem.swift
//  BlinkReviewer
//
//  Created by Alex Chan on 08/06/2023.
//

import SwiftUI
import Photos

enum ReviewState {
    case Approved
    case Rejected
    case NeedsAction
}

/// Renders a square thumbnail for an image.
///
/// The image will be expanded to fill the square, and may be clipped
/// if the original aspect ratio isn't square.
struct ThumbnailImage: View {
    var asset: PHAsset
    var isSelected: Bool
    
    var size: CGFloat {
        isSelected ? 70.0 : 50.0
    }
    
    var state: ReviewState? {
        var result: ReviewState? = nil
        
        asset.albums().forEach { album in
            switch (album.localizedTitle) {
                case "Approved":
                    result = .Approved
                case "Rejected":
                    result = .Rejected
                case "Needs Action":
                    result = .NeedsAction
                default:
                    break
            }
        }
        
        return result
    }
    
    var stateColor: Color {
        switch (state) {
            case .Approved:
                return .green
            case .Rejected:
                return .red
            case .NeedsAction:
                return .blue
            default:
                return .gray.opacity(0.5)
        }
    }
    
    var cornerRadius: CGFloat {
        return isSelected ? 7.0 : 5.0
    }
    
    var body: some View {
        Image(nsImage: asset.getThumbnail())
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
            .cornerRadius(cornerRadius)
            .overlay(
                // https://www.appcoda.com/swiftui-border/
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(stateColor, lineWidth: state != nil ? 3.0 : 1.0)
            )
            .overlay(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
                if (asset.isFavorite) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.white)
                        .padding(2)
                        .shadow(radius: 2.0)
                }
            }
            .overlay(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                if (state != nil) {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(stateColor).accentColor(.white).padding(2).font(.title2)
//                    "info.circle.fill"
//                    "trash.circle.fill
                }
            }
    }
}
