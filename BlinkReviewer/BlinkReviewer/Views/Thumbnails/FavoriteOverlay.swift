import SwiftUI
import Photos

/// Renders a small heart to indicate a photo is a "Favorite".
///
/// This is meant to match the way favorite items are marked in Photos.
struct FavoriteHeartIcon: ViewModifier {
    let isFavorite: Bool
    
    init(_ isFavorite: Bool) {
        self.isFavorite = isFavorite
    }
    
    func body(content: Content) -> some View {
        if isFavorite {
            content.overlay(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.white)
                    .padding(3)
                    .shadow(radius: 2.0)
            }
        } else {
            content
        }
    }
}

extension View {
    func favoriteHeartIcon(_ isFavorite: Bool) -> some View {
        modifier(FavoriteHeartIcon(isFavorite))
    }
}
