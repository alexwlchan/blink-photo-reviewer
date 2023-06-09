import SwiftUI
import Photos

/// Renders a small heart to indicate a photo is a "Favorite".
///
/// This is meant to match the way favorite items are marked in Photos.
struct FavoriteHeartIcon: ViewModifier {
    let asset: PHAsset
    
    init(_ asset: PHAsset) {
        self.asset = asset
    }
    
    func body(content: Content) -> some View {
        content.overlay(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
            if asset.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundColor(.white)
                    .padding(3)
                    .shadow(radius: 2.0)
            }
        }
    }
}

extension View {
    func favoriteHeartIcon(for asset: PHAsset) -> some View {
        modifier(FavoriteHeartIcon(asset))
    }
}
